package com.hospital.auth.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Bean validation failures (@Valid on request DTOs).
     * Returns the concatenated field-level messages so clients can surface them directly.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException ex) {
        String errors = ex.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining("; "));
        return error(HttpStatus.BAD_REQUEST, errors);
    }

    /**
     * Malformed JSON body, unrecognised fields with FAIL_ON_UNKNOWN_PROPERTIES, or
     * completely missing body on an endpoint that requires one.
     * Without this handler the DispatcherServlet returns a 400 in Spring Boot's default
     * error format — which doesn't match our { success, message } shape.
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, Object>> handleUnreadableBody(HttpMessageNotReadableException ex) {
        log.warn("Unreadable request body: {}", ex.getMessage());
        return error(HttpStatus.BAD_REQUEST, "Malformed or missing request body");
    }

    /**
     * MongoDB unique-index violation.
     * The message string is parsed to give a field-aware hint; the fallback is generic
     * so we never leak internal schema details to the caller.
     */
    @ExceptionHandler(DuplicateKeyException.class)
    public ResponseEntity<Map<String, Object>> handleDuplicateKey(DuplicateKeyException ex) {
        String message = "A record with the provided details already exists";
        if (ex.getMessage() != null) {
            if (ex.getMessage().contains("phoneNumber")) {
                message = "Phone number already registered";
            } else if (ex.getMessage().contains("username")) {
                message = "Username already registered";
            }
        }
        return error(HttpStatus.CONFLICT, message);
    }

    /**
     * Caller used the wrong HTTP verb (e.g. GET instead of POST).
     * Spring returns a 405 by default but in its own error format, not ours.
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<Map<String, Object>> handleMethodNotSupported(
            HttpRequestMethodNotSupportedException ex) {
        String msg = String.format("HTTP method '%s' is not supported for this endpoint", ex.getMethod());
        return error(HttpStatus.METHOD_NOT_ALLOWED, msg);
    }

    /**
     * Path not mapped to any controller — Spring Boot 3.x throws NoResourceFoundException
     * (the older NoHandlerFoundException is no longer thrown by default).
     */
    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<Map<String, Object>> handleNotFound(NoResourceFoundException ex) {
        return error(HttpStatus.NOT_FOUND, "The requested resource was not found");
    }

    /**
     * Explicit IllegalArgumentExceptions thrown from service/controller logic
     * (e.g. JwtUtil rejecting a PATIENT without a patientId).
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalArgument(IllegalArgumentException ex) {
        return error(HttpStatus.BAD_REQUEST, ex.getMessage());
    }

    /**
     * Catch-all. Logs the full stack trace so ops can investigate; returns a generic
     * message to the client so internal details are never exposed.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGeneric(Exception ex) {
        log.error("Unhandled exception: {}", ex.getMessage(), ex);
        return error(HttpStatus.INTERNAL_SERVER_ERROR, "An unexpected error occurred");
    }

    private ResponseEntity<Map<String, Object>> error(HttpStatus status, String message) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", false);
        body.put("message", message);
        return new ResponseEntity<>(body, status);
    }
}
