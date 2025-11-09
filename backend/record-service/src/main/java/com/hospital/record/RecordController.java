package com.hospital.record;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/record")
public class RecordController {

    @GetMapping("/health")
    public String health() {
        return "Record Service running";
    }

    @GetMapping("/list")
    public List<Map<String, String>> getRecords() {
        return List.of(
            Map.of("id", "rec-001", "details", "Annual Checkup"),
            Map.of("id", "rec-002", "details", "Flu Shot")
        );
    }
}
