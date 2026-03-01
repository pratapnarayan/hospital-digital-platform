package com.hospital.record.repository;

import com.hospital.record.model.MedicalRecord;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface MedicalRecordRepository extends MongoRepository<MedicalRecord, String> {
    List<MedicalRecord> findByPatientId(String patientId);
    List<MedicalRecord> findByDoctorId(String doctorId);
}
