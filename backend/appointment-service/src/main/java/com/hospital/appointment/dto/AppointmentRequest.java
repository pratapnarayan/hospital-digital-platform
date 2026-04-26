package com.hospital.appointment.dto;

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.Instant;

@Data
public class AppointmentRequest {

    @NotBlank(message = "Patient ID is required")
    private String patientId;

    private String doctorId;

    @NotNull(message = "Appointment time is required")
    @FutureOrPresent(message = "Appointment must be in the present or future")
    private Instant appointmentTime;

    @NotNull(message = "Duration is required")
    @Min(value = 15, message = "Duration must be at least 15 minutes")
    private Integer durationMinutes;

    @NotBlank(message = "Reason for appointment is required")
    private String reason;
}
