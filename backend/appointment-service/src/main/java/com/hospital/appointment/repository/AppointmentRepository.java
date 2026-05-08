package com.hospital.appointment.repository;

import com.hospital.appointment.model.Appointment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface AppointmentRepository extends MongoRepository<Appointment, String> {

    // Overlap Query: existing.start < new.end AND existing.end > new.start
    @Query("{ 'hospitalId': ?0, 'doctorId': ?1, 'status': { $ne: 'CANCELLED' }, 'appointmentTime': { $lt: ?3 }, 'appointmentEndTime': { $gt: ?2 } }")
    List<Appointment> findOverlappingAppointments(String hospitalId, String doctorId, Instant newStart, Instant newEnd);

    // Doctor pagination (optionally filtered by Day using strict temporal ranges)
    @Query("{ 'hospitalId': ?0, 'doctorId': { $in: [?1, 'DOC-DEFAULT'] }, 'status': { $ne: 'CANCELLED' }, 'appointmentTime': { $gte: ?2, $lte: ?3 } }")
    Page<Appointment> findByHospitalIdAndDoctorIdAndDateRange(String hospitalId, String doctorId, Instant startOfDay, Instant endOfDay, Pageable pageable);

    // Patient pagination
    @Query("{ 'hospitalId': ?0, 'patientId': ?1, 'status': { $ne: 'CANCELLED' } }")
    Page<Appointment> findByHospitalIdAndPatientId(String hospitalId, String patientId, Pageable pageable);
}
