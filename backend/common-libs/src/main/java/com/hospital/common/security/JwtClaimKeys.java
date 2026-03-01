package com.hospital.common.security;

/**
 * Standard JWT claim keys shared across services.
 */
public final class JwtClaimKeys {
    private JwtClaimKeys() {
    }

    public static final String USER_ID = "userId";
    public static final String ROLE = "role";
    public static final String PATIENT_ID = "patientId";
    public static final String HOSPITAL_ID = "hospitalId";
}
