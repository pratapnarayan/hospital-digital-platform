package com.hospital.patient;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/patient")
public class PatientController {

    @GetMapping("/health")
    public String health() {
        return "Patient Service running";
    }

    @GetMapping("/list")
    public List<Map<String, String>> getPatients() {
        return List.of(
            Map.of("id", "1", "name", "John Doe"),
            Map.of("id", "2", "name", "Jane Smith")
        );
    }
}
