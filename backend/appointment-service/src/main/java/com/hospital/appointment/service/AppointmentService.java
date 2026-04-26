package com.hospital.appointment.service;

import com.hospital.appointment.dto.AppointmentRequest;
import com.hospital.appointment.dto.AppointmentResponse;
import com.hospital.appointment.dto.AppointmentStatusUpdateRequest;
import com.hospital.appointment.model.Appointment;
import com.hospital.appointment.repository.AppointmentRepository;
import com.hospital.common.security.JwtClaimsAccessor;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.extern.slf4j.Slf4j;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppointmentService {

    private final AppointmentRepository appointmentRepository;
    private final DoctorLockService lockService;

    public AppointmentResponse createAppointment(AppointmentRequest request) {
        log.info("Creating appointment for patient {}", request.getPatientId());
        String role = JwtClaimsAccessor.role().orElseThrow(() -> new SecurityException("Role is missing"));
        if (!"DOCTOR".equalsIgnoreCase(role) && !"PATIENT".equalsIgnoreCase(role)) {
            throw new SecurityException("Only DOCTOR or PATIENT role can create appointments");
        }

        String hospitalId = JwtClaimsAccessor.hospitalId().orElseThrow(() -> new SecurityException("Hospital ID missing from token"));
        
        String doctorId;
        if ("PATIENT".equalsIgnoreCase(role)) {
            doctorId = request.getDoctorId() != null && !request.getDoctorId().isEmpty() ? request.getDoctorId() : "DOC-DEFAULT";
        } else {
            doctorId = JwtClaimsAccessor.userId().orElseThrow(() -> new SecurityException("Doctor User ID missing from token"));
        }

        Instant start = request.getAppointmentTime();
        Instant end = start.plus(request.getDurationMinutes(), ChronoUnit.MINUTES);

        boolean lockAcquired = false;
        try {
            // Acquire lock (wait up to 3 seconds preventing strict deadlocks securely)
            lockAcquired = lockService.tryLock(doctorId, 3, TimeUnit.SECONDS);
            if (!lockAcquired) {
                log.warn("Failed to acquire lock for doctor {} at {}", doctorId, start);
                throw new IllegalStateException("System busy scheduling for this doctor. Please try again.");
            }
            log.info("Lock acquired successfully for doctor {}", doctorId);

            // Conflict check using optimized MongoDB querying avoiding full-day aggregations in memory
            List<Appointment> overlaps = appointmentRepository.findOverlappingAppointments(hospitalId, doctorId, start, end);
            if (!overlaps.isEmpty()) {
                log.warn("Overlap detected for doctor {} between {} and {}", doctorId, start, end);
                throw new IllegalStateException("Appointment slot overlaps with an existing booking");
            }

            Appointment appointment = Appointment.builder()
                    .hospitalId(hospitalId)
                    .doctorId(doctorId)
                    .patientId(request.getPatientId())
                    .appointmentTime(start)
                    .durationMinutes(request.getDurationMinutes())
                    .appointmentEndTime(end)
                    .status("SCHEDULED")
                    .reason(request.getReason())
                    .build();

            try {
                Appointment saved = appointmentRepository.save(appointment);
                log.info("Appointment {} created successfully", saved.getId());
                return AppointmentResponse.fromEntity(saved);
            } catch (DuplicateKeyException e) {
                log.warn("Concurrent duplicate key detected for doctor {} at {}", doctorId, start);
                throw new IllegalStateException("Appointment slot overlaps or is already booked");
            }

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Scheduling interrupted", e);
        } finally {
            if (lockAcquired) {
                lockService.unlock(doctorId);
                log.info("Lock released for doctor {}", doctorId);
            }
        }
    }

    public Page<AppointmentResponse> getDoctorAppointments(Instant startOfDay, Instant endOfDay, Pageable pageable) {
        String role = JwtClaimsAccessor.role().orElseThrow(() -> new SecurityException("Role is missing"));
        if (!"DOCTOR".equalsIgnoreCase(role)) {
            throw new SecurityException("Only DOCTOR role can access doctor appointments list");
        }

        String hospitalId = JwtClaimsAccessor.hospitalId().orElseThrow(() -> new SecurityException("Hospital ID missing"));
        String doctorId = JwtClaimsAccessor.userId().orElseThrow(() -> new SecurityException("User ID missing"));

        // If date range missing, optionally set defaults. For now assume Controller handles it.
        Page<Appointment> page = appointmentRepository.findByHospitalIdAndDoctorIdAndDateRange(hospitalId, doctorId, startOfDay, endOfDay, pageable);
        return page.map(AppointmentResponse::fromEntity);
    }

    public Page<AppointmentResponse> getPatientAppointments(Pageable pageable) {
        String role = JwtClaimsAccessor.role().orElseThrow(() -> new SecurityException("Role is missing"));
        if (!"PATIENT".equalsIgnoreCase(role)) {
            throw new SecurityException("Only PATIENT role can access patient appointments list");
        }

        String hospitalId = JwtClaimsAccessor.hospitalId().orElseThrow(() -> new SecurityException("Hospital ID missing"));
        String patientId = JwtClaimsAccessor.patientId().orElseThrow(() -> new SecurityException("Patient ID missing"));

        Page<Appointment> page = appointmentRepository.findByHospitalIdAndPatientId(hospitalId, patientId, pageable);
        return page.map(AppointmentResponse::fromEntity);
    }

    @Transactional
    public AppointmentResponse updateAppointmentStatus(String appointmentId, AppointmentStatusUpdateRequest request) {
        String hospitalId = JwtClaimsAccessor.hospitalId().orElseThrow(() -> new SecurityException("Hospital ID missing"));
        String role = JwtClaimsAccessor.role().orElseThrow(() -> new SecurityException("Role is missing"));

        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new IllegalArgumentException("Appointment not found"));

        if (!appointment.getHospitalId().equals(hospitalId)) {
            throw new SecurityException("Not authorized for this hospital's data");
        }
        
        String currentStatus = appointment.getStatus();
        String newStatus = request.getStatus().toUpperCase();

        // 4. Past Appointment Protection
        if (appointment.getAppointmentTime().isBefore(Instant.now())) {
            if (!("COMPLETED".equals(newStatus) || "NO_SHOW".equals(newStatus) || "CANCELLED".equals(newStatus))) {
                throw new IllegalArgumentException("Cannot modify past appointments to active statuses");
            }
        }

        // 3. Status Transition strict validation
        if (!"SCHEDULED".equals(currentStatus) && !"CANCELLED".equals(newStatus)) {
            // Already finalized
            if ("COMPLETED".equals(currentStatus) || "CANCELLED".equals(currentStatus) || "NO_SHOW".equals(currentStatus)) {
                throw new IllegalArgumentException("Cannot transition from finalized status: " + currentStatus);
            }
        }

        // Strict role validation
        if ("PATIENT".equalsIgnoreCase(role)) {
            String patientId = JwtClaimsAccessor.patientId().orElseThrow(() -> new SecurityException("Patient ID missing"));
            if (!appointment.getPatientId().equals(patientId)) {
                throw new SecurityException("Not authorized to modify this appointment");
            }
            if (!"CANCELLED".equals(newStatus)) {
                throw new SecurityException("Patients can only CANCEL appointments");
            }
        } else if ("DOCTOR".equalsIgnoreCase(role)) {
            String doctorId = JwtClaimsAccessor.userId().orElseThrow(() -> new SecurityException("Doctor User ID missing"));
            if (!appointment.getDoctorId().equals(doctorId)) {
                throw new SecurityException("Not authorized to modify this appointment");
            }
        } else {
            throw new SecurityException("Unknown role trying to update appointment");
        }

        appointment.setStatus(newStatus);
        
        log.info("Updating appointment {} status to {}", appointmentId, newStatus);
        return AppointmentResponse.fromEntity(appointmentRepository.save(appointment));
    }

    @Transactional
    public void deleteAppointment(String appointmentId) {
        // Implementation: Soft Delete via Cancel. Only accessible by DOCTOR practically, mapping logic cleanly.
        AppointmentStatusUpdateRequest req = new AppointmentStatusUpdateRequest();
        req.setStatus("CANCELLED");
        updateAppointmentStatus(appointmentId, req);
    }
}
