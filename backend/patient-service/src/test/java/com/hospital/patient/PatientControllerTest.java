package com.hospital.patient;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hospital.patient.dto.CreatePatientRequest;
import com.hospital.patient.model.Patient;
import com.hospital.patient.repository.PatientRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureWebMvc
public class PatientControllerTest {

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    private PatientRepository patientRepository;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        objectMapper = new ObjectMapper();
        patientRepository.deleteAll();
    }

    @Test
    void testPatientRegistration() throws Exception {
        CreatePatientRequest request = new CreatePatientRequest();
        request.setFirstName("John");
        request.setLastName("Doe");
        request.setEmail("john.doe@example.com");
        request.setPhone("1234567890");
        request.setDateOfBirth("1990-01-01");
        request.setGender("Male");
        request.setAddress("123 Main St");
        request.setEmergencyContact("Jane Doe");
        request.setEmergencyPhone("0987654321");
        request.setBloodType("O+");
        request.setAllergies("None");
        request.setMedicalHistory("No significant medical history");

        mockMvc.perform(post("/patient/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.firstName").value("John"))
                .andExpect(jsonPath("$.lastName").value("Doe"))
                .andExpect(jsonPath("$.email").value("john.doe@example.com"));
    }

    @Test
    void testGetAllPatients() throws Exception {
        mockMvc.perform(get("/patient/list"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }

    @Test
    void testHealthEndpoint() throws Exception {
        mockMvc.perform(get("/patient/health"))
                .andExpect(status().isOk())
                .andExpect(content().string("Patient Service running"));
    }

    @Test
    void testDuplicateEmailRegistration() throws Exception {
        // Register first patient
        CreatePatientRequest request1 = new CreatePatientRequest();
        request1.setFirstName("John");
        request1.setLastName("Doe");
        request1.setEmail("john.doe@example.com");
        request1.setDateOfBirth("1990-01-01");
        request1.setGender("Male");

        mockMvc.perform(post("/patient/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request1)))
                .andExpect(status().isCreated());

        // Try to register with same email
        CreatePatientRequest request2 = new CreatePatientRequest();
        request2.setFirstName("Jane");
        request2.setLastName("Smith");
        request2.setEmail("john.doe@example.com");
        request2.setDateOfBirth("1992-02-02");
        request2.setGender("Female");

        mockMvc.perform(post("/patient/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request2)))
                .andExpect(status().isConflict());
    }

    @Test
    void testMissingRequiredFields() throws Exception {
        CreatePatientRequest request = new CreatePatientRequest();
        request.setFirstName("John");
        // Missing lastName, email, dateOfBirth, gender

        mockMvc.perform(post("/patient/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }
}
