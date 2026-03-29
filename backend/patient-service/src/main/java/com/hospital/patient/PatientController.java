package com.hospital.patient;

import com.hospital.patient.dto.CreatePatientRequest;
import com.hospital.patient.dto.UpdatePatientRequest;
import com.hospital.patient.model.Patient;
import com.hospital.patient.repository.PatientRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/patient")
public class PatientController {

    private final PatientRepository patientRepository;

    public PatientController(PatientRepository patientRepository) {
        this.patientRepository = patientRepository;
    }

    @GetMapping("/health")
    public String health() {
        return "Patient Service running";
    }

    /**
     * Register a new patient
     */
    @PostMapping("/register")
    public ResponseEntity<?> registerPatient(@RequestBody CreatePatientRequest request) {
        // Validate required fields
        if (request.getFirstName() == null || request.getFirstName().trim().isEmpty() ||
            request.getLastName() == null || request.getLastName().trim().isEmpty() ||
            request.getEmail() == null || request.getEmail().trim().isEmpty() ||
            request.getDateOfBirth() == null || request.getDateOfBirth().trim().isEmpty() ||
            request.getGender() == null || request.getGender().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Missing required fields: firstName, lastName, email, dateOfBirth, gender");
        }

        // Check if email already exists
        if (patientRepository.existsByEmail(request.getEmail())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Email already registered");
        }

        // Check if phone already exists (if provided)
        if (request.getPhone() != null && !request.getPhone().trim().isEmpty() &&
            patientRepository.existsByPhone(request.getPhone())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Phone number already registered");
        }

        try {
            // Parse date of birth
            LocalDate dateOfBirth = LocalDate.parse(request.getDateOfBirth(), DateTimeFormatter.ISO_LOCAL_DATE);

            // Create new patient
            Patient patient = new Patient();
            patient.setFirstName(request.getFirstName().trim());
            patient.setLastName(request.getLastName().trim());
            patient.setEmail(request.getEmail().trim().toLowerCase());
            patient.setPhone(request.getPhone() != null ? request.getPhone().trim() : null);
            patient.setDateOfBirth(dateOfBirth);
            patient.setGender(request.getGender().trim());
            patient.setAddress(request.getAddress());
            patient.setEmergencyContact(request.getEmergencyContact());
            patient.setEmergencyPhone(request.getEmergencyPhone());
            patient.setBloodType(request.getBloodType());
            patient.setAllergies(request.getAllergies());
            patient.setMedicalHistory(request.getMedicalHistory());

            Instant now = Instant.now();
            patient.setCreatedAt(now);
            patient.setUpdatedAt(now);

            Patient savedPatient = patientRepository.save(patient);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedPatient);

        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Invalid date format. Use yyyy-MM-dd format");
        }
    }

    /**
     * Get all patients
     */
    @GetMapping("/list")
    public List<Patient> getAllPatients() {
        return patientRepository.findAll();
    }

    /**
     * Get patient by ID
     */
    @GetMapping("/{patientId}")
    public ResponseEntity<Patient> getPatientById(@PathVariable String patientId) {
        return patientRepository.findById(patientId)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * Update patient information (partial update)
     */
    @PutMapping("/{patientId}")
    public ResponseEntity<Patient> updatePatient(@PathVariable String patientId,
                                                 @RequestBody UpdatePatientRequest request) {
        Optional<Patient> existingOpt = patientRepository.findById(patientId);
        if (existingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Patient existing = existingOpt.get();

        // Update provided fields only
        if (request.getFirstName() != null) {
            existing.setFirstName(request.getFirstName().trim());
        }
        if (request.getLastName() != null) {
            existing.setLastName(request.getLastName().trim());
        }
        if (request.getPhone() != null) {
            String newPhone = request.getPhone().trim();
            if (!newPhone.isEmpty() && !newPhone.equals(existing.getPhone())) {
                // Check if new phone already exists
                if (patientRepository.existsByPhone(newPhone)) {
                    return ResponseEntity.status(HttpStatus.CONFLICT).build();
                }
                existing.setPhone(newPhone);
            }
        }
        if (request.getAddress() != null) {
            existing.setAddress(request.getAddress());
        }
        if (request.getEmergencyContact() != null) {
            existing.setEmergencyContact(request.getEmergencyContact());
        }
        if (request.getEmergencyPhone() != null) {
            existing.setEmergencyPhone(request.getEmergencyPhone());
        }
        if (request.getBloodType() != null) {
            existing.setBloodType(request.getBloodType());
        }
        if (request.getAllergies() != null) {
            existing.setAllergies(request.getAllergies());
        }
        if (request.getMedicalHistory() != null) {
            existing.setMedicalHistory(request.getMedicalHistory());
        }

        existing.touchUpdatedAt();
        Patient saved = patientRepository.save(existing);
        return ResponseEntity.ok(saved);
    }

    /**
     * Delete patient by ID
     */
    @DeleteMapping("/{patientId}")
    public ResponseEntity<Void> deletePatient(@PathVariable String patientId) {
        if (!patientRepository.existsById(patientId)) {
            return ResponseEntity.notFound().build();
        }
        patientRepository.deleteById(patientId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Search patients by name
     */
    @GetMapping("/search")
    public ResponseEntity<List<Patient>> searchPatients(
            @RequestParam(required = false) String firstName,
            @RequestParam(required = false) String lastName) {
        
        if (firstName != null && lastName != null) {
            List<Patient> patients = patientRepository.findByFirstNameIgnoreCaseAndLastNameIgnoreCase(
                firstName.trim(), lastName.trim());
            return ResponseEntity.ok(patients);
        } else if (firstName != null) {
            List<Patient> patients = patientRepository.findByFirstNameIgnoreCase(firstName.trim());
            return ResponseEntity.ok(patients);
        } else if (lastName != null) {
            List<Patient> patients = patientRepository.findByLastNameIgnoreCase(lastName.trim());
            return ResponseEntity.ok(patients);
        } else {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Get patient by email
     */
    @GetMapping("/email/{email}")
    public ResponseEntity<Patient> getPatientByEmail(@PathVariable String email) {
        return patientRepository.findByEmail(email.toLowerCase())
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
