package com.hospital.patient.dto;

import java.util.Map;

public class RegistrationResponse {
    private PatientResponse patient;
    private Map<String, String> credentials;

    public RegistrationResponse(PatientResponse patient, Map<String, String> credentials) {
        this.patient = patient;
        this.credentials = credentials;
    }

    public PatientResponse getPatient() {
        return patient;
    }

    public Map<String, String> getCredentials() {
        return credentials;
    }
}
