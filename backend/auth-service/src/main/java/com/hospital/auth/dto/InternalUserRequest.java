package com.hospital.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class InternalUserRequest {

    @NotBlank(message = "Email is required")
    private String email;       // used as username

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    @NotBlank(message = "Role is required")
    @Pattern(
        regexp = "(?i)PATIENT|DOCTOR|ADMIN|NURSE",
        message = "Role must be one of: PATIENT, DOCTOR, ADMIN, NURSE"
    )
    private String role;

    private String patientId;
    private String hospitalId;

    /**
     * Patient's phone number, forwarded from patient-service.
     * For patients, this equals the email/username field since phone is the login identifier.
     * Optional in the wire format to remain backward-compatible with older callers,
     * but patient-service always provides it as of this release.
     */
    private String phoneNumber;
}
