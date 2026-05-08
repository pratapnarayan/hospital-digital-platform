package com.hospital.auth;

import com.hospital.auth.model.User;
import com.hospital.auth.repository.UserRepository;
import com.hospital.auth.utils.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private JwtUtil jwtUtil;;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        if (userRepository.findByUsername(user.getUsername()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Username already exists");
        }

        // Role-specific validation
        if ("DOCTOR".equalsIgnoreCase(user.getRole())) {
            if (user.getHospitalId() == null || user.getHospitalId().isBlank()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("hospitalId is required for DOCTOR registration");
            }
        }

        user.setPassword(new BCryptPasswordEncoder().encode(user.getPassword()));
        userRepository.save(user);
        return ResponseEntity.ok("User registered successfully");
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        var user = userRepository.findByUsername(credentials.get("username"));
        if (user.isPresent() && new BCryptPasswordEncoder().matches(credentials.get("password"), user.get().getPassword())) {
            try {
                String token = jwtUtil.generateToken(user.get());
                Map<String, Object> response = new HashMap<>();
                response.put("token", token);
                response.put("passwordResetRequired", user.get().isPasswordResetRequired());
                return ResponseEntity.ok(response);
            } catch (IllegalArgumentException ex) {
                // Typically indicates inconsistent user profile data required to issue a valid token.
                return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(ex.getMessage());
            }
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
    }

    @PutMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String currentPassword = body.get("currentPassword");
        String newPassword = body.get("newPassword");

        if (username == null || currentPassword == null || newPassword == null) {
            return ResponseEntity.badRequest().body("username, currentPassword and newPassword are required");
        }
        if (newPassword.length() < 6) {
            return ResponseEntity.badRequest().body("New password must be at least 6 characters");
        }

        var userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty() || !new BCryptPasswordEncoder().matches(currentPassword, userOpt.get().getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
        }

        User user = userOpt.get();
        user.setPassword(new BCryptPasswordEncoder().encode(newPassword));
        user.setPasswordResetRequired(false);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of("message", "Password changed successfully"));
    }
    /*@GetMapping("/health")
    public String health() {
        return "Auth Service running";
    }

    @PostMapping("/login")
    public Map<String, String> login(@RequestBody Map<String, String> credentials) {
        // Dummy login logic
        return Map.of("token", "demo-jwt-token");
    }*/


}
