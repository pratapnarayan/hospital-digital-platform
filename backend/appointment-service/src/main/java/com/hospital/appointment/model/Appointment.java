package com.hospital.appointment.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "appointments")
@CompoundIndex(name = "doctor_time_idx", def = "{'doctorId': 1, 'appointmentTime': 1}", unique = true)
public class Appointment {

    @Id
    private String id;

    @Indexed
    private String hospitalId;

    @Indexed
    private String doctorId;

    @Indexed
    private String patientId;

    private Instant appointmentTime;

    private Integer durationMinutes;

    private Instant appointmentEndTime;

    private String status;

    private String reason;

    private String notes;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}
