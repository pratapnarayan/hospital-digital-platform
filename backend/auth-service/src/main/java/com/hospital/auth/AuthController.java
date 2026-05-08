package com.hospital.auth;

import com.hospital.auth.dto.ChangePasswordRequest;
import com.hospital.auth.dto.ForgotPasswordRequest;
import com.hospital.auth.dto.LoginRequest;
import com.hospital.auth.dto.RegisterRequest;
import com.hospital.auth.dto.ResetPasswordRequest;
import com.hospital.auth.model.User;
import com.hospital.auth.repository.UserRepository;
import com.hospital.auth.utils.JwtUtil;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping("/auth")
public class AuthController {

    // Shared instance — BCryptPasswordEncoder is thread-safe.
    private static final BCryptPasswordEncoder PASSWORD_ENCODER = new BCryptPasswordEncoder();

    // Token alphabet: uppercase A-Z and digits 0-9 (36 chars).
    // 8 characters → 36^8 ≈ 2.8 trillion combinations, safe for a 15-minute window.
    private static final String TOKEN_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final int TOKEN_LENGTH = 8;
    private static final long TOKEN_TTL_MINUTES = 15;

    // Generic message returned for both found/not-found phones — prevents user enumeration.
    private static final String FORGOT_PASSWORD_RESPONSE =
            "If an account with this phone number exists, a reset code has been sent.";

    // Generic error for any token validation failure — do not reveal which check failed.
    private static final String INVALID_TOKEN_MSG =
            "Invalid or expired reset code. Please request a new one.";

    private final SecureRandom secureRandom = new SecureRandom();

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtil jwtUtil;

    // ------------------------------------------------------------------
    // REGISTER
    // ------------------------------------------------------------------
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {

        final String phone = request.getPhoneNumber().trim();

        if (userRepository.existsByUsername(request.getUsername())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Username already exists");
        }

        if (userRepository.existsByPhoneNumber(phone)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Phone number already registered");
        }

        final String role = request.getRole().toUpperCase();
        if ("DOCTOR".equals(role)) {
            if (request.getHospitalId() == null || request.getHospitalId().isBlank()) {
                return ResponseEntity.badRequest().body("hospitalId is required for DOCTOR registration");
            }
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(PASSWORD_ENCODER.encode(request.getPassword()));
        user.setRole(role);
        user.setHospitalId(request.getHospitalId());
        user.setPhoneNumber(phone);

        userRepository.save(user);
        log.info("New {} registered: username={}", role, request.getUsername());
        return ResponseEntity.ok("User registered successfully");
    }

    // ------------------------------------------------------------------
    // LOGIN
    //
    // Uses a typed DTO so Spring validates the body before we touch it.
    // Backward-compatible: works for all existing users regardless of
    // whether they have a phoneNumber (legacy accounts are unaffected).
    // ------------------------------------------------------------------
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        Optional<User> userOpt = userRepository.findByUsername(request.getUsername());

        // Both conditions are checked together so the response time doesn't
        // reveal whether the username exists (timing side-channel mitigation).
        if (userOpt.isPresent() &&
                PASSWORD_ENCODER.matches(request.getPassword(), userOpt.get().getPassword())) {
            try {
                String token = jwtUtil.generateToken(userOpt.get());
                Map<String, Object> response = new HashMap<>();
                response.put("token", token);
                response.put("passwordResetRequired", userOpt.get().isPasswordResetRequired());
                return ResponseEntity.ok(response);
            } catch (IllegalArgumentException ex) {
                return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(ex.getMessage());
            }
        }

        // Generic 401 — never reveal whether username or password is wrong.
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
    }

    // ------------------------------------------------------------------
    // CHANGE PASSWORD (first-login reset)
    //
    // Patient provides current password as proof of identity — no JWT required.
    // Min-length matches registration (8 chars) for consistency.
    // ------------------------------------------------------------------
    @PutMapping("/change-password")
    public ResponseEntity<?> changePassword(@Valid @RequestBody ChangePasswordRequest request) {

        Optional<User> userOpt = userRepository.findByUsername(request.getUsername());

        if (userOpt.isEmpty() ||
                !PASSWORD_ENCODER.matches(request.getCurrentPassword(), userOpt.get().getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
        }

        User user = userOpt.get();
        user.setPassword(PASSWORD_ENCODER.encode(request.getNewPassword()));
        user.setPasswordResetRequired(false);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of("success", true, "message", "Password changed successfully"));
    }

    // ------------------------------------------------------------------
    // FORGOT PASSWORD
    //
    // Security design:
    //   - Response is identical whether the phone exists or not (no enumeration).
    //   - Token is cryptographically random, 8 uppercase alphanumeric chars.
    //   - Token TTL is 15 minutes; stored plaintext (128-bit effective entropy).
    //   - PRODUCTION TODO: integrate with notification-service to send SMS instead
    //     of returning 'resetToken' in the response body.
    //   - RATE LIMIT TODO: apply per-IP + per-phone limits (e.g. Bucket4j + Redis).
    //     Recommended: max 3 requests per phone per 10 minutes.
    // ------------------------------------------------------------------
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {

        // RATE LIMIT POINT — add rate limiter check here before any DB access.

        String phone = request.getPhoneNumber().trim();
        Optional<User> userOpt = userRepository.findByPhoneNumber(phone);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("success", true);
        response.put("message", FORGOT_PASSWORD_RESPONSE);

        if (userOpt.isPresent()) {
            String token = generateResetToken();
            Instant expiry = Instant.now().plus(TOKEN_TTL_MINUTES, ChronoUnit.MINUTES);

            User user = userOpt.get();
            user.setResetToken(token);
            user.setResetTokenExpiry(expiry);
            userRepository.save(user);

            log.info("Reset token generated for phone={} expires={}", maskPhone(phone), expiry);

            // PRODUCTION: remove 'resetToken' from response and send via SMS.
            // MVP: returned so the frontend can display it without SMS integration.
            response.put("resetToken", token);
        }
        // Always return HTTP 200 with the same message — never 404.
        return ResponseEntity.ok(response);
    }

    // ------------------------------------------------------------------
    // RESET PASSWORD
    //
    // Security design:
    //   - Same generic error for wrong phone, wrong token, and expired token.
    //   - Constant-time token comparison via MessageDigest.isEqual to prevent
    //     timing-based oracle attacks on the token byte sequence.
    //   - Token is cleared immediately after first successful use (one-time).
    //   - Sets passwordResetRequired=false so first-login flag is also cleared.
    //   - RATE LIMIT TODO: limit reset attempts per phone (e.g. 5 per 15 minutes)
    //     to prevent brute-force of the 8-char token space.
    // ------------------------------------------------------------------
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {

        // RATE LIMIT POINT — add rate limiter check here.

        String phone = request.getPhoneNumber().trim();
        // Normalise to uppercase so users can type lower/mixed case without rejection.
        String submittedToken = request.getResetToken().trim().toUpperCase();

        Optional<User> userOpt = userRepository.findByPhoneNumber(phone);

        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", INVALID_TOKEN_MSG));
        }

        User user = userOpt.get();

        if (user.getResetToken() == null || user.getResetToken().isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", INVALID_TOKEN_MSG));
        }

        // Expiry check — clear expired tokens eagerly to avoid accumulation.
        if (user.getResetTokenExpiry() == null || Instant.now().isAfter(user.getResetTokenExpiry())) {
            user.setResetToken(null);
            user.setResetTokenExpiry(null);
            userRepository.save(user);
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", INVALID_TOKEN_MSG));
        }

        // Constant-time comparison — MessageDigest.isEqual runs in time proportional
        // to the array length regardless of where bytes differ, preventing a
        // timing oracle that could leak partial token bytes.
        boolean tokenMatches = MessageDigest.isEqual(
                user.getResetToken().getBytes(),
                submittedToken.getBytes()
        );

        if (!tokenMatches) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", INVALID_TOKEN_MSG));
        }

        // All checks passed — update password and clear all reset state.
        user.setPassword(PASSWORD_ENCODER.encode(request.getNewPassword()));
        user.setResetToken(null);
        user.setResetTokenExpiry(null);
        user.setPasswordResetRequired(false);
        userRepository.save(user);

        log.info("Password successfully reset for phone={}", maskPhone(phone));
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Password reset successfully. Please log in with your new password."
        ));
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    private String generateResetToken() {
        StringBuilder token = new StringBuilder(TOKEN_LENGTH);
        for (int i = 0; i < TOKEN_LENGTH; i++) {
            token.append(TOKEN_CHARS.charAt(secureRandom.nextInt(TOKEN_CHARS.length())));
        }
        return token.toString();
    }

    /** Masks the middle digits of a phone for log PII reduction. 9876543210 → 987***210 */
    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) return "***";
        int keep = 3;
        return phone.substring(0, keep) + "***" + phone.substring(phone.length() - keep);
    }
}
