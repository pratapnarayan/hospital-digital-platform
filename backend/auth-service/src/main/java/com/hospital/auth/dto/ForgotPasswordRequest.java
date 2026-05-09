package com.hospital.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class ForgotPasswordRequest {

    @NotBlank(message = "Phone number is required")
    @Pattern(
        regexp = "^[+]?[0-9]{7,15}$",
        message = "Phone number must be 7–15 digits with an optional leading +"
    )
    private String phoneNumber;
}
