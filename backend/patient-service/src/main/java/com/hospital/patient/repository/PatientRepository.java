package com.hospital.patient.repository;

import com.hospital.patient.model.Patient;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PatientRepository extends MongoRepository<Patient, String> {
    /**
     * Find patients by hospital ID
     */
    java.util.List<Patient> findByHospitalId(String hospitalId);
    
    /**
     * Find patient by phone within a hospital
     */
    Optional<Patient> findByPhoneAndHospitalId(String phone, String hospitalId);
    
    /**
     * Check if a patient exists with the given phone in a hospital
     */
    boolean existsByPhoneAndHospitalId(String phone, String hospitalId);
}
