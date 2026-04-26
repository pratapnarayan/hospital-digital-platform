package com.hospital.appointment.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AppointmentStatusUpdateRequest {
    
    @NotBlank(message = "Status cannot be blank")
    private String status;
}
