package com.hospital.auth.dto;

import lombok.Data;

@Data
public class InternalUserRequest {
    private String email;
    private String password;
    private String role;
    private String patientId;
    private String hospitalId;
}
