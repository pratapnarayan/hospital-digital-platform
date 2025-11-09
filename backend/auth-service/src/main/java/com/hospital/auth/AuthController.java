package com.hospital.auth;

import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @GetMapping("/health")
    public String health() {
        return "Auth Service running";
    }

    @PostMapping("/login")
    public Map<String, String> login(@RequestBody Map<String, String> credentials) {
        // Dummy login logic
        return Map.of("token", "demo-jwt-token");
    }
}
