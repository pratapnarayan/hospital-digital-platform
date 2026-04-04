package com.hospital.record;

import com.hospital.common.security.JwtClaimsAccessor;
import com.hospital.record.dto.CreateMedicalRecordRequest;
import com.hospital.record.dto.UpdateMedicalRecordRequest;
import com.hospital.record.model.MedicalRecord;
import com.hospital.record.repository.MedicalRecordRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/record")
public class RecordController {

    private final MedicalRecordRepository medicalRecordRepository;

    public RecordController(MedicalRecordRepository medicalRecordRepository) {
        this.medicalRecordRepository = medicalRecordRepository;
    }

    @GetMapping("/health")
    public String health() {
        return "Record Service running";
    }

    @PostMapping
    public ResponseEntity<?> createRecord(@RequestBody CreateMedicalRecordRequest request) {
        String role = JwtClaimsAccessor.role().orElse("");
        if (!"DOCTOR".equalsIgnoreCase(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only doctors can create records");
        }
        
        String hospitalId = JwtClaimsAccessor.hospitalId().orElse("");
        String doctorId = JwtClaimsAccessor.userId().orElse("");

        if (request == null || request.getPatientId() == null || request.getTitle() == null) {
            return ResponseEntity.badRequest().body("PatientId and Title are required");
        }

        MedicalRecord record = new MedicalRecord();
        record.setHospitalId(hospitalId);
        record.setPatientId(request.getPatientId());
        record.setDoctorId(doctorId);
        record.setTitle(request.getTitle());
        record.setDescription(request.getDescription());
        record.setDiagnosis(request.getDiagnosis());

        Instant now = Instant.now();
        record.setCreatedAt(now);
        record.setUpdatedAt(now);

        MedicalRecord saved = medicalRecordRepository.save(record);
        return ResponseEntity.ok(saved);
    }

    @PutMapping("/{recordId}")
    public ResponseEntity<?> updateRecord(@PathVariable String recordId,
                                          @RequestBody UpdateMedicalRecordRequest request) {
        String role = JwtClaimsAccessor.role().orElse("");
        if (!"DOCTOR".equalsIgnoreCase(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only doctors can update records");
        }
        
        String hospitalId = JwtClaimsAccessor.hospitalId().orElse("");

        if (request == null) {
            return ResponseEntity.badRequest().build();
        }

        var existingOpt = medicalRecordRepository.findById(recordId);
        if (existingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        MedicalRecord existing = existingOpt.get();
        if (!hospitalId.equals(existing.getHospitalId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        // Update provided fields only
        if (request.getTitle() != null) {
            existing.setTitle(request.getTitle());
        }
        if (request.getDescription() != null) {
            existing.setDescription(request.getDescription());
        }
        if (request.getDiagnosis() != null) {
            existing.setDiagnosis(request.getDiagnosis());
        }

        existing.setUpdatedAt(Instant.now());
        MedicalRecord saved = medicalRecordRepository.save(existing);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/list")
    public ResponseEntity<?> getRecords(@RequestParam(defaultValue = "0") int page,
                                        @RequestParam(defaultValue = "10") int size) {
        String role = JwtClaimsAccessor.role().orElse("");
        if (!"DOCTOR".equalsIgnoreCase(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only doctors can list all records");
        }
        String hospitalId = JwtClaimsAccessor.hospitalId().orElse("");
        return ResponseEntity.ok(medicalRecordRepository.findByHospitalId(hospitalId, PageRequest.of(page, size)));
    }

    @GetMapping("/{recordId}")
    public ResponseEntity<?> getRecordById(@PathVariable String recordId) {
        var existingOpt = medicalRecordRepository.findById(recordId);
        if (existingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        MedicalRecord existing = existingOpt.get();
        
        String role = JwtClaimsAccessor.role().orElse("");
        if ("DOCTOR".equalsIgnoreCase(role)) {
            String hospitalId = JwtClaimsAccessor.hospitalId().orElse("");
            if (!hospitalId.equals(existing.getHospitalId())) return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        } else if ("PATIENT".equalsIgnoreCase(role)) {
            String patientId = JwtClaimsAccessor.patientId().orElse("");
            if (!patientId.equals(existing.getPatientId())) return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        
        return ResponseEntity.ok(existing);
    }

    @DeleteMapping("/{recordId}")
    public ResponseEntity<?> deleteRecord(@PathVariable String recordId) {
        String role = JwtClaimsAccessor.role().orElse("");
        if (!"DOCTOR".equalsIgnoreCase(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        String hospitalId = JwtClaimsAccessor.hospitalId().orElse("");
        
        var existingOpt = medicalRecordRepository.findById(recordId);
        if (existingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        if (!hospitalId.equals(existingOpt.get().getHospitalId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        medicalRecordRepository.deleteById(recordId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/patient/{patientId}")
    public ResponseEntity<?> getRecordsByPatientId(@PathVariable String patientId) {
        String role = JwtClaimsAccessor.role().orElse("");
        
        if ("DOCTOR".equalsIgnoreCase(role)) {
            String hospitalId = JwtClaimsAccessor.hospitalId().orElse("");
            return ResponseEntity.ok(medicalRecordRepository.findByPatientIdAndHospitalId(patientId, hospitalId));
        } else if ("PATIENT".equalsIgnoreCase(role)) {
            String tokenPatientId = JwtClaimsAccessor.patientId().orElse("");
            String hospitalId = JwtClaimsAccessor.hospitalId().orElse("");
            if (!tokenPatientId.equals(patientId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Collections.emptyList());
            }
            return ResponseEntity.ok(medicalRecordRepository.findByPatientIdAndHospitalId(patientId, hospitalId));
        }
        return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }
}
