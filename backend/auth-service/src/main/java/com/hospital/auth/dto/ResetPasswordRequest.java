package com.hospital.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ResetPasswordRequest {

    @NotBlank(message = "Phone number is required")
    @Pattern(
        regexp = "^[+]?[0-9]{7,15}$",
        message = "Phone number must be 7–15 digits with an optional leading +"
    )
    private String phoneNumber;

    @NotBlank(message = "Reset code is required")
    @Size(min = 6, max = 10, message = "Reset code must be between 6 and 10 characters")
    private String resetToken;

    @NotBlank(message = "New password is required")
    @Size(min = 8, message = "New password must be at least 8 characters")
    private String newPassword;
}
