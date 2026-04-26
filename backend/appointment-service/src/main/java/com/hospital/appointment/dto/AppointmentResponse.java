package com.hospital.appointment.dto;

import com.hospital.appointment.model.Appointment;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;

@Data
@Builder
public class AppointmentResponse {
    private String id;
    private String hospitalId;
    private String doctorId;
    private String patientId;
    private Instant appointmentTime;
    private Integer durationMinutes;
    private Instant appointmentEndTime;
    private String status;
    private String reason;
    private String notes;
    private Instant createdAt;

    public static AppointmentResponse fromEntity(Appointment obj) {
        return AppointmentResponse.builder()
                .id(obj.getId())
                .hospitalId(obj.getHospitalId())
                .doctorId(obj.getDoctorId())
                .patientId(obj.getPatientId())
                .appointmentTime(obj.getAppointmentTime())
                .durationMinutes(obj.getDurationMinutes())
                .appointmentEndTime(obj.getAppointmentEndTime())
                .status(obj.getStatus())
                .reason(obj.getReason())
                .notes(obj.getNotes())
                .createdAt(obj.getCreatedAt())
                .build();
    }
}
