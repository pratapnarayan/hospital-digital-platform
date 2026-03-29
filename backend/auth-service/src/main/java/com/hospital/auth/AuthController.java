package com.hospital.auth;

import com.hospital.auth.model.User;
import com.hospital.auth.repository.UserRepository;
import com.hospital.auth.utils.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

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
                return ResponseEntity.ok(Map.of("token", token));
            } catch (IllegalArgumentException ex) {
                // Typically indicates inconsistent user profile data required to issue a valid token.
                return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(ex.getMessage());
            }
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
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
