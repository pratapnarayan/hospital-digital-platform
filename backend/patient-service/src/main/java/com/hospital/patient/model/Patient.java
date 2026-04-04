package com.hospital.patient.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;


import java.time.Instant;

@Document(collection = "patients")
public class Patient {

    @Id
    private String id;

    // Simplified schema fields
    private String hospitalId;
    private String name;
    private int age;
    private String gender;
    private String phone;
    
    private Instant createdAt;
    private Instant updatedAt;

    public Patient() { }

    public Patient(String hospitalId, String name, int age, String gender, String phone) {
        this.hospitalId = hospitalId;
        this.name = name;
        this.age = age;
        this.gender = gender;
        this.phone = phone;
        Instant now = Instant.now();
        this.createdAt = now;
        this.updatedAt = now;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getHospitalId() { return hospitalId; }
    public void setHospitalId(String hospitalId) { this.hospitalId = hospitalId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    public void touchUpdatedAt() { this.updatedAt = Instant.now(); }
}
