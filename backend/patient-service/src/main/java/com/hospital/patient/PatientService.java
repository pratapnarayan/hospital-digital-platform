package com.hospital.patient;

import com.hospital.common.security.JwtClaimsAccessor;
import com.hospital.patient.dto.PatientRequest;
import com.hospital.patient.model.Patient;
import com.hospital.patient.repository.PatientRepository;
import org.springframework.stereotype.Service;

import com.hospital.patient.dto.PatientRegistrationResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.security.SecureRandom;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Service
public class PatientService {

    private final PatientRepository patientRepository;
    private final RestTemplate restTemplate;

    @Value("${hospital.auth-service.url}")
    private String authServiceUrl;

    @Value("${hospital.internal-secret}")
    private String internalSecret;

    public PatientService(PatientRepository patientRepository, RestTemplate restTemplate) {
        this.patientRepository = patientRepository;
        this.restTemplate = restTemplate;
    }

    private String generateRandomString(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder(length);
        for(int i = 0; i < length; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }

    private String generateNumericPassword(int length) {
        String digits = "0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder(length);
        for(int i = 0; i < length; i++) {
            sb.append(digits.charAt(random.nextInt(digits.length())));
        }
        return sb.toString();
    }

    public PatientRegistrationResult createPatient(PatientRequest request) {
        String hospitalId = JwtClaimsAccessor.hospitalId().orElseThrow(() -> new RuntimeException("Hospital ID missing from token"));
        String role = JwtClaimsAccessor.role().orElse("");
        if (!"DOCTOR".equalsIgnoreCase(role)) {
            throw new RuntimeException("Only DOCTOR role can create patients");
        }

        if (request.getPhone() == null || request.getPhone().trim().isEmpty()) {
            throw new IllegalArgumentException("Phone number is required for patient login");
        }

        Patient patient = new Patient(
                hospitalId,
                request.getName(),
                request.getAge(),
                request.getGender(),
                request.getPhone()
        );

        Patient savedPatient = patientRepository.save(patient);

        // Prepare Authentication Object mapping phone to backend 'email/username'
        String mappedPhone = savedPatient.getPhone();
        String generatedPassword = generateNumericPassword(6);

        Map<String, String> payload = new HashMap<>();
        payload.put("email", mappedPhone);           // phone is the patient's login username
        payload.put("phoneNumber", mappedPhone);     // also stored as phoneNumber for forgot-password flow
        payload.put("password", generatedPassword);
        payload.put("role", "PATIENT");
        payload.put("patientId", savedPatient.getId());
        payload.put("hospitalId", savedPatient.getHospitalId());

        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Secret", internalSecret);
        headers.set("Content-Type", "application/json");

        HttpEntity<Map<String, String>> entity = new HttpEntity<>(payload, headers);

        try {
            ResponseEntity<String> authResponse = restTemplate.exchange(
                    authServiceUrl + "/internal/users",
                    HttpMethod.POST,
                    entity,
                    String.class
            );

            if (!authResponse.getStatusCode().is2xxSuccessful()) {
                throw new RuntimeException("Auth-service rejected internal user creation.");
            }
        } catch (Exception e) {
            // Clean rollback to prevent orphaned DB states
            patientRepository.deleteById(savedPatient.getId());
            throw new RuntimeException("Failed to automatically provision login credentials: " + e.getMessage());
        }

        Map<String, String> credentials = new HashMap<>();
        credentials.put("phone", mappedPhone);
        credentials.put("email", mappedPhone); // Backward compatibility
        credentials.put("password", generatedPassword);

        return new PatientRegistrationResult(savedPatient, credentials);
    }

    public List<Patient> getPatientsByHospital() {
        String hospitalId = JwtClaimsAccessor.hospitalId().orElseThrow(() -> new RuntimeException("Hospital ID missing from token"));
        return patientRepository.findByHospitalId(hospitalId);
    }

    public Optional<Patient> getPatientById(String id) {
        String role = JwtClaimsAccessor.role().orElse("");
        
        Optional<Patient> patientOpt = patientRepository.findById(id);
        if (patientOpt.isEmpty()) {
            return Optional.empty();
        }

        Patient patient = patientOpt.get();

        if ("DOCTOR".equalsIgnoreCase(role)) {
            String hospitalId = JwtClaimsAccessor.hospitalId().orElse("");
            if (!hospitalId.equals(patient.getHospitalId())) {
                return Optional.empty(); // Not in this doctor's hospital
            }
        } else if ("PATIENT".equalsIgnoreCase(role)) {
            String tokenPatientId = JwtClaimsAccessor.patientId().orElse("");
            if (!tokenPatientId.equals(patient.getId())) {
                return Optional.empty(); // Cannot view other patients
            }
        }

        return Optional.of(patient);
    }

    public Optional<Patient> updatePatient(String id, PatientRequest request) {
        String hospitalId = JwtClaimsAccessor.hospitalId().orElseThrow(() -> new RuntimeException("Hospital ID missing from token"));
        String role = JwtClaimsAccessor.role().orElse("");
        if (!"DOCTOR".equalsIgnoreCase(role)) {
            throw new RuntimeException("Only DOCTOR role can update patients");
        }

        Optional<Patient> patientOpt = patientRepository.findById(id);
        if (patientOpt.isEmpty() || !patientOpt.get().getHospitalId().equals(hospitalId)) {
            return Optional.empty();
        }

        Patient patient = patientOpt.get();
        if (request.getName() != null) patient.setName(request.getName());
        if (request.getAge() > 0) patient.setAge(request.getAge());
        if (request.getGender() != null) patient.setGender(request.getGender());
        if (request.getPhone() != null) patient.setPhone(request.getPhone());
        
        patient.touchUpdatedAt();
        return Optional.of(patientRepository.save(patient));
    }

    public boolean deletePatient(String id) {
        String hospitalId = JwtClaimsAccessor.hospitalId().orElseThrow(() -> new RuntimeException("Hospital ID missing from token"));
        String role = JwtClaimsAccessor.role().orElse("");
        if (!"DOCTOR".equalsIgnoreCase(role)) {
            throw new RuntimeException("Only DOCTOR role can delete patients");
        }

        Optional<Patient> patientOpt = patientRepository.findById(id);
        if (patientOpt.isEmpty() || !patientOpt.get().getHospitalId().equals(hospitalId)) {
            return false;
        }

        patientRepository.deleteById(id);
        return true;
    }
}
