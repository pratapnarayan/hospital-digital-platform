package com.hospital.patient.repository;

import com.hospital.patient.model.Patient;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PatientRepository extends MongoRepository<Patient, String> {
    
    /**
     * Find a patient by email address
     */
    Optional<Patient> findByEmail(String email);
    
    /**
     * Find a patient by phone number
     */
    Optional<Patient> findByPhone(String phone);
    
    /**
     * Find patients by first name (case-insensitive)
     */
    java.util.List<Patient> findByFirstNameIgnoreCase(String firstName);
    
    /**
     * Find patients by last name (case-insensitive)
     */
    java.util.List<Patient> findByLastNameIgnoreCase(String lastName);
    
    /**
     * Find patients by first name and last name (case-insensitive)
     */
    java.util.List<Patient> findByFirstNameIgnoreCaseAndLastNameIgnoreCase(String firstName, String lastName);
    
    /**
     * Check if a patient exists with the given email
     */
    boolean existsByEmail(String email);
    
    /**
     * Check if a patient exists with the given phone
     */
    boolean existsByPhone(String phone);
}
