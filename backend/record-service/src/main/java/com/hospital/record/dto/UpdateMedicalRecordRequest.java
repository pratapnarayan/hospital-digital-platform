package com.hospital.record.dto;

import com.fasterxml.jackson.annotation.JsonSetter;
import com.fasterxml.jackson.annotation.Nulls;

/**
 * Request payload for updating a MedicalRecord.
 * All fields are optional; only provided fields will be updated.
 */
public class UpdateMedicalRecordRequest {
    private String title;
    private String description;
    private String diagnosis;

    public String getTitle() {
        return title;
    }

    @JsonSetter(value = "title", nulls = Nulls.FAIL)
    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }
}
