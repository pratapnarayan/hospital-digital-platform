package com.hospital.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "Username is required")
    private String username;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    @NotBlank(message = "Role is required")
    @Pattern(
        regexp = "(?i)PATIENT|DOCTOR|ADMIN|NURSE",
        message = "Role must be one of: PATIENT, DOCTOR, ADMIN, NURSE"
    )
    private String role;

    // Required when role = DOCTOR; validated in service logic.
    private String hospitalId;

    /**
     * Mandatory for all new registrations. Stored with a sparse unique index —
     * existing legacy users without a phone number are unaffected.
     *
     * Accepted formats: 7–15 digits, optional leading +
     * Examples: 9876543210  |  +919876543210  |  +12125551234
     */
    @NotBlank(message = "Phone number is required")
    @Pattern(
        regexp = "^[+]?[0-9]{7,15}$",
        message = "Phone number must be 7–15 digits with an optional leading +"
    )
    private String phoneNumber;
}
