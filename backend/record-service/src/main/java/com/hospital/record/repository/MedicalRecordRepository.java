package com.hospital.record.repository;

import com.hospital.record.model.MedicalRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MedicalRecordRepository extends MongoRepository<MedicalRecord, String> {
    List<MedicalRecord> findByPatientIdAndHospitalId(String patientId, String hospitalId);
    Page<MedicalRecord> findByHospitalId(String hospitalId, Pageable pageable);
}
