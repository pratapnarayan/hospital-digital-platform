package com.hospital.auth.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document(collection = "users")
@AllArgsConstructor
@NoArgsConstructor
public class User {
    @Id
    private String id;
    private String username;
    private String password;
    private String role; // e.g., ADMIN, DOCTOR, NURSE, PATIENT

    /**
     * For role=PATIENT, this must be present and will be emitted into the JWT.
     */
    private String patientId;

    /**
     * Nullable for now, required later. Emitted into the JWT even if null.
     */
    private String hospitalId;

    /**
     * True for auto-provisioned patient accounts until they complete first-time password reset.
     */
    private boolean passwordResetRequired;
}
