package com.hospital.record;

import com.hospital.record.dto.CreateMedicalRecordRequest;
import com.hospital.record.dto.UpdateMedicalRecordRequest;
import com.hospital.record.model.MedicalRecord;
import com.hospital.record.repository.MedicalRecordRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
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

    /**
     * Create a new medical record.
     */
    @PostMapping
    public ResponseEntity<MedicalRecord> createRecord(@RequestBody CreateMedicalRecordRequest request) {
        if (request == null
                || request.getPatientId() == null
                || request.getDoctorId() == null
                || request.getTitle() == null) {
            return ResponseEntity.badRequest().build();
        }

        MedicalRecord record = new MedicalRecord();
        record.setPatientId(request.getPatientId());
        record.setDoctorId(request.getDoctorId());
        record.setTitle(request.getTitle());
        record.setDescription(request.getDescription());
        record.setDiagnosis(request.getDiagnosis());

        Instant now = Instant.now();
        record.setCreatedAt(now);
        record.setUpdatedAt(now);

        MedicalRecord saved = medicalRecordRepository.save(record);
        return ResponseEntity.ok(saved);
    }

    /**
     * Update an existing medical record (partial update).
     */
    @PutMapping("/{recordId}")
    public ResponseEntity<MedicalRecord> updateRecord(@PathVariable String recordId,
                                                      @RequestBody UpdateMedicalRecordRequest request) {
        if (request == null) {
            return ResponseEntity.badRequest().build();
        }

        var existingOpt = medicalRecordRepository.findById(recordId);
        if (existingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        MedicalRecord existing = existingOpt.get();

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

    /**
     * Return all medical records.
     * Empty DB returns an empty list.
     */
    @GetMapping("/list")
    public List<MedicalRecord> getRecords() {
        return medicalRecordRepository.findAll();
    }

    /**
     * Return a medical record by its ID.
     */
    @GetMapping("/{recordId}")
    public ResponseEntity<MedicalRecord> getRecordById(@PathVariable String recordId) {
        return medicalRecordRepository.findById(recordId)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * Delete a medical record by its ID.
     */
    @DeleteMapping("/{recordId}")
    public ResponseEntity<Void> deleteRecord(@PathVariable String recordId) {
        if (!medicalRecordRepository.existsById(recordId)) {
            return ResponseEntity.notFound().build();
        }
        medicalRecordRepository.deleteById(recordId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Return all records for a given patient.
     * Empty DB returns an empty list.
     */
    @GetMapping("/patient/{patientId}")
    public List<MedicalRecord> getRecordsByPatientId(@PathVariable String patientId) {
        return medicalRecordRepository.findByPatientId(patientId);
    }
}
