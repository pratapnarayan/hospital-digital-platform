package com.hospital.patient;

import com.hospital.patient.dto.PatientRequest;
import com.hospital.patient.dto.PatientResponse;
import com.hospital.patient.model.Patient;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/patient")
public class PatientController {

    private final PatientService patientService;

    public PatientController(PatientService patientService) {
        this.patientService = patientService;
    }

    @GetMapping("/health")
    public String health() {
        return "Patient Service running with Real DB";
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerPatient(@RequestBody PatientRequest request) {
        try {
            if (request.getName() == null || request.getName().trim().isEmpty()) {
                return ResponseEntity.badRequest().body("Missing required field: name");
            }
            var result = patientService.createPatient(request);
            
            PatientResponse patientResponse = mapToResponse(result.getPatient());
            
            com.hospital.patient.dto.RegistrationResponse registrationResponse = 
                    new com.hospital.patient.dto.RegistrationResponse(patientResponse, result.getCredentials());

            return ResponseEntity.status(HttpStatus.CREATED).body(registrationResponse);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        }
    }

    @GetMapping("/list")
    public ResponseEntity<?> getAllPatients() {
        try {
            List<PatientResponse> responses = patientService.getPatientsByHospital()
                    .stream()
                    .map(this::mapToResponse)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(responses);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        }
    }

    @GetMapping("/{patientId}")
    public ResponseEntity<?> getPatientById(@PathVariable String patientId) {
        return patientService.getPatientById(patientId)
                .map(this::mapToResponse)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PutMapping("/{patientId}")
    public ResponseEntity<?> updatePatient(@PathVariable String patientId,
                                           @RequestBody PatientRequest request) {
        try {
            return patientService.updatePatient(patientId, request)
                    .map(this::mapToResponse)
                    .map(ResponseEntity::ok)
                    .orElseGet(() -> ResponseEntity.notFound().build());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        }
    }

    @DeleteMapping("/{patientId}")
    public ResponseEntity<?> deletePatient(@PathVariable String patientId) {
        try {
            boolean deleted = patientService.deletePatient(patientId);
            if (deleted) {
                return ResponseEntity.noContent().build();
            }
            return ResponseEntity.notFound().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        }
    }

    private PatientResponse mapToResponse(Patient patient) {
        return new PatientResponse(
                patient.getId(),
                patient.getName(),
                patient.getAge(),
                patient.getGender(),
                patient.getPhone()
        );
    }
}
