package com.hospital.patient.dto;

import com.hospital.patient.model.Patient;
import java.util.Map;

public class PatientRegistrationResult {
    private Patient patient;
    private Map<String, String> credentials;

    public PatientRegistrationResult(Patient patient, Map<String, String> credentials) {
        this.patient = patient;
        this.credentials = credentials;
    }

    public Patient getPatient() {
        return patient;
    }
    
    public Map<String, String> getCredentials() {
        return credentials;
    }
}
