package com.hospital.auth;

import com.hospital.auth.dto.InternalUserRequest;
import com.hospital.auth.model.User;
import com.hospital.auth.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/internal")
public class InternalUserController {

    @Autowired
    private UserRepository userRepository;

    @Value("${hospital.internal-secret:default-secret-key-123}")
    private String internalSecret;

    @PostMapping("/users")
    public ResponseEntity<?> createInternalUser(
            @RequestHeader("X-Internal-Secret") String secretHeader,
            @RequestBody InternalUserRequest request) {

        // 1. Secure the endpoint using an internal API key header
        if (!internalSecret.equals(secretHeader)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid Internal Secret");
        }

        // 2. Idempotency & Conflict Check
        if (userRepository.findByUsername(request.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("User email already exists");
        }

        // 3. Create User
        User user = new User();
        user.setUsername(request.getEmail());
        user.setPassword(new BCryptPasswordEncoder().encode(request.getPassword()));
        user.setRole(request.getRole() != null ? request.getRole() : "PATIENT");
        user.setPatientId(request.getPatientId());
        user.setHospitalId(request.getHospitalId());
        user.setPasswordResetRequired(true);

        userRepository.save(user);

        return ResponseEntity.status(HttpStatus.CREATED).body("Internal User created successfully");
    }
}
