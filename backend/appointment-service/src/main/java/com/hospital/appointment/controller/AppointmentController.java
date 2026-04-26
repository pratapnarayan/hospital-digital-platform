package com.hospital.appointment.controller;

import com.hospital.appointment.dto.AppointmentRequest;
import com.hospital.appointment.dto.AppointmentResponse;
import com.hospital.appointment.dto.AppointmentStatusUpdateRequest;
import com.hospital.appointment.service.AppointmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;

@RestController
@RequestMapping("/appointment")
@RequiredArgsConstructor
public class AppointmentController {

    private final AppointmentService appointmentService;

    // 1. Create Appointment (Restricted to DOCTOR inside Service logic)
    @PostMapping
    public ResponseEntity<AppointmentResponse> createAppointment(@Valid @RequestBody AppointmentRequest request) {
        AppointmentResponse response = appointmentService.createAppointment(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    // 2. Get Doctor Appointments (Optional strict Date ranges + Pagination)
    @GetMapping("/doctor")
    public ResponseEntity<Page<AppointmentResponse>> getDoctorAppointments(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "appointmentTime") String sortStr,
            @RequestParam(defaultValue = "asc") String direction) {

        Sort sort = Sort.by(Sort.Direction.fromString(direction), sortStr);
        Pageable pageable = PageRequest.of(page, size, sort);

        Instant startOfDay = null;
        Instant endOfDay = null;

        if (date != null) {
            startOfDay = date.atStartOfDay().toInstant(ZoneOffset.UTC);
            endOfDay = date.plusDays(1).atStartOfDay().toInstant(ZoneOffset.UTC).minusMillis(1);
        } else {
            // Unbounded check natively fetching standard lists
            startOfDay = Instant.EPOCH;
            endOfDay = Instant.now().plus(3650, java.time.temporal.ChronoUnit.DAYS);
        }

        Page<AppointmentResponse> response = appointmentService.getDoctorAppointments(startOfDay, endOfDay, pageable);
        return ResponseEntity.ok(response);
    }

    // 3. Get Patient Appointments (Pagination setup)
    @GetMapping("/patient")
    public ResponseEntity<Page<AppointmentResponse>> getPatientAppointments(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "appointmentTime") String sortStr,
            @RequestParam(defaultValue = "asc") String direction) {

        Sort sort = Sort.by(Sort.Direction.fromString(direction), sortStr);
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<AppointmentResponse> response = appointmentService.getPatientAppointments(pageable);
        return ResponseEntity.ok(response);
    }

    // 4. Update Status (Cancel, Completing, etc.)
    @PutMapping("/{id}/status")
    public ResponseEntity<AppointmentResponse> updateStatus(
            @PathVariable String id,
            @Valid @RequestBody AppointmentStatusUpdateRequest request) {
        AppointmentResponse response = appointmentService.updateAppointmentStatus(id, request);
        return ResponseEntity.ok(response);
    }

    // 5. Delete (Soft cancellation wrapping)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> cancelAppointment(@PathVariable String id) {
        appointmentService.deleteAppointment(id);
        return ResponseEntity.noContent().build();
    }
}
