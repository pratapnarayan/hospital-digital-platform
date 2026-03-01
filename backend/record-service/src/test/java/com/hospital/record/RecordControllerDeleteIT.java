package com.hospital.record;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.MongoDBContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@Testcontainers
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
class RecordControllerDeleteIT {

    @Container
    static final MongoDBContainer mongo = new MongoDBContainer("mongo:7.0.5");

    @DynamicPropertySource
    static void mongoProps(DynamicPropertyRegistry registry) {
        registry.add("spring.data.mongodb.uri", mongo::getReplicaSetUrl);
    }

    @Autowired
    MockMvc mockMvc;

    @Autowired
    ObjectMapper objectMapper;

    @BeforeEach
    void verifyContainerRunning() {
        assertThat(mongo.isRunning()).isTrue();
    }

    @Test
    void createThenDeleteThenVerifyNotFoundAndListDoesNotContain() throws Exception {
        // 1) Create
        String createJson = objectMapper.writeValueAsString(Map.of(
                "patientId", "p-1",
                "doctorId", "d-1",
                "title", "Initial title",
                "description", "desc",
                "diagnosis", "diag"
        ));

        String createdResponse = mockMvc.perform(post("/record")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createJson))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andReturn()
                .getResponse()
                .getContentAsString();

        @SuppressWarnings("unchecked")
        Map<String, Object> created = objectMapper.readValue(createdResponse, Map.class);
        Object idObj = created.get("id");
        assertThat(idObj).as("created record id").isNotNull();
        String recordId = idObj.toString();

        // Sanity: record appears in list
        String listBefore = mockMvc.perform(get("/record/list"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        assertThat(listBefore).contains(recordId);

        // 2) Delete
        mockMvc.perform(delete("/record/{recordId}", recordId))
                .andExpect(status().isNoContent());

        // 3) GET by id returns 404
        mockMvc.perform(get("/record/{recordId}", recordId))
                .andExpect(status().isNotFound());

        // 4) List no longer includes deleted record
        String listAfter = mockMvc.perform(get("/record/list"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        assertThat(listAfter).doesNotContain(recordId);

        // 5) Deleting again returns 404
        mockMvc.perform(delete("/record/{recordId}", recordId))
                .andExpect(status().isNotFound());
    }
}
