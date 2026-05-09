package com.hospital.auth.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Document(collection = "users")
@AllArgsConstructor
@NoArgsConstructor
public class User {
    @Id
    private String id;

    private String username;
    private String password;
    private String role; // ADMIN, DOCTOR, NURSE, PATIENT

    /**
     * Globally unique phone number. Mandatory for all NEW registrations.
     *
     * sparse = true → documents that have no phoneNumber (null/missing) are
     * excluded from the unique index entirely, so existing legacy records are
     * not affected and can still be read/written without a phone number.
     *
     * Migration note: old users can log in normally. They will be prompted to
     * add a phone number the first time they access a feature that requires it
     * (e.g. forgot-password). Use PUT /auth/users/{id}/phone-number to backfill.
     */
    @Indexed(unique = true, sparse = true)
    private String phoneNumber;

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

    /**
     * Opaque, cryptographically-random token set during a forgot-password flow.
     * Stored in plaintext — the token has 128-bit effective entropy so plaintext
     * storage is acceptable. Cleared immediately after a successful reset.
     *
     * In production this should be sent to the user via SMS (notification-service).
     * For the MVP it is returned in the forgot-password API response.
     */
    private String resetToken;

    /**
     * Absolute expiry instant for the reset token.
     * Any comparison against Instant.now() must use server time, not client time.
     */
    private Instant resetTokenExpiry;
}
