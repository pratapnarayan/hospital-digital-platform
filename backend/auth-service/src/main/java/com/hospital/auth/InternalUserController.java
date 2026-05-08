package com.hospital.auth;

import com.hospital.auth.dto.InternalUserRequest;
import com.hospital.auth.model.User;
import com.hospital.auth.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/internal")
public class InternalUserController {

    private static final Logger log = LoggerFactory.getLogger(InternalUserController.class);

    private static final BCryptPasswordEncoder PASSWORD_ENCODER = new BCryptPasswordEncoder();

    @Autowired
    private UserRepository userRepository;

    @Value("${hospital.internal-secret:default-secret-key-123}")
    private String internalSecret;

    /**
     * Creates a user account on behalf of another service (e.g. patient-service).
     * This endpoint is secured by a shared internal secret header, not a JWT.
     *
     * Backward-compatible: phoneNumber is optional in the request payload.
     * New callers (patient-service) always supply it; legacy callers that don't
     * will simply create a user without a phoneNumber (allowed by the sparse index).
     */
    @PostMapping("/users")
    public ResponseEntity<?> createInternalUser(
            @RequestHeader("X-Internal-Secret") String secretHeader,
            @RequestBody InternalUserRequest request) {

        if (!internalSecret.equals(secretHeader)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid Internal Secret");
        }

        // Idempotency: reject duplicate username.
        if (userRepository.findByUsername(request.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("User email already exists");
        }

        // Phone uniqueness guard (only when phoneNumber is provided).
        if (request.getPhoneNumber() != null && !request.getPhoneNumber().isBlank()) {
            if (userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
                return ResponseEntity.status(HttpStatus.CONFLICT)
                        .body("Phone number already registered");
            }
        } else {
            // Log a warning so ops can identify callers that haven't been updated yet.
            log.warn("Internal user created without phoneNumber for email={} role={}",
                    request.getEmail(), request.getRole());
        }

        User user = new User();
        user.setUsername(request.getEmail());
        user.setPassword(PASSWORD_ENCODER.encode(request.getPassword()));
        user.setRole(request.getRole() != null ? request.getRole() : "PATIENT");
        user.setPatientId(request.getPatientId());
        user.setHospitalId(request.getHospitalId());
        user.setPasswordResetRequired(true);

        // Store phoneNumber only when present — sparse index handles uniqueness.
        if (request.getPhoneNumber() != null && !request.getPhoneNumber().isBlank()) {
            user.setPhoneNumber(request.getPhoneNumber().trim());
        }

        userRepository.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body("Internal User created successfully");
    }

    // ------------------------------------------------------------------
    // TASK 11 — Admin migration: backfill phoneNumber on legacy users
    //
    // Called by ops/admin tooling to add phone numbers to accounts created
    // before this field was introduced. Protected by the internal secret.
    // Idempotent: calling it again with the same phone is a no-op if the
    // phone already matches what is stored.
    // ------------------------------------------------------------------
    @PutMapping("/users/{userId}/phone-number")
    public ResponseEntity<?> backfillPhoneNumber(
            @RequestHeader("X-Internal-Secret") String secretHeader,
            @PathVariable String userId,
            @RequestBody Map<String, String> body) {

        if (!internalSecret.equals(secretHeader)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid Internal Secret");
        }

        String phoneNumber = body.get("phoneNumber");
        if (phoneNumber == null || phoneNumber.isBlank()) {
            return ResponseEntity.badRequest().body("phoneNumber is required");
        }
        phoneNumber = phoneNumber.trim();

        var userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        // Uniqueness guard — another user may already have this phone.
        var conflict = userRepository.findByPhoneNumber(phoneNumber);
        if (conflict.isPresent() && !conflict.get().getId().equals(userId)) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("Phone number already registered to another account");
        }

        User user = userOpt.get();
        user.setPhoneNumber(phoneNumber);
        userRepository.save(user);

        log.info("Backfilled phoneNumber for userId={}", userId);
        return ResponseEntity.ok(Map.of("success", true, "message", "Phone number updated"));
    }
}
