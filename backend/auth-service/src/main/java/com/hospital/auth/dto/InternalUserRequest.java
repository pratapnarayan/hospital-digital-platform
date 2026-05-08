package com.hospital.auth.dto;

import lombok.Data;

@Data
public class InternalUserRequest {
    private String email;       // used as username
    private String password;
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
