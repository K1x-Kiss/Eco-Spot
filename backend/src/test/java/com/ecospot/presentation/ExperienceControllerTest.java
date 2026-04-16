package com.ecospot.presentation;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.util.UUID;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import com.ecospot.business.dato.Roles;
import com.ecospot.persistance.entity.Experience;
import com.ecospot.persistance.entity.User;
import com.ecospot.persistance.repository.ExperienceRepository;
import com.ecospot.persistance.repository.UserRepository;
import com.ecospot.util.JWT;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootTest
@TestPropertySource(properties = {
    "jwt.secret=EcoSpot2026SecretKeyForJWTTokenGen12345678901234567890123456789012345678901234567890",
    "jwt.expiration=864000"
})
public class ExperienceControllerTest {

  @Autowired
  private WebApplicationContext context;

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private ExperienceRepository experienceRepository;

  @Autowired
  private JWT jwt;

  @Autowired
  private PasswordEncoder passwordEncoder;

  private MockMvc mockMvc;
  private User testUser;
  private String validToken;

  @BeforeEach
  void setUp() {
    mockMvc = MockMvcBuilders.webAppContextSetup(context).build();
    experienceRepository.deleteAll();
    userRepository.deleteAll();

    testUser = new User("Test", "User", "test@example.com", passwordEncoder.encode("password123"), "Madrid", "ESPAÑA",
        Roles.EXPERIENCE);
    testUser = userRepository.save(testUser);

    validToken = jwt.generateToken(testUser.getId(), "EXPERIENCE");
  }

  @AfterEach
  void tearDown() {
    experienceRepository.deleteAll();
    userRepository.deleteAll();
  }

  @Test
  void createExperience_withValidData_returnsCreated() throws Exception {
    mockMvc.perform(multipart("/api/v1/experiences")
        .param("name", "Test Experience")
        .param("description", "A test experience")
        .param("contact", "1234567890")
        .param("city", "Madrid")
        .param("country", "ESPAÑA")
        .param("location", "Calle Test 123")
        .param("price", "50.0")
        .param("startingDate", "2026-06-01")
        .param("endDate", "2026-06-10")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isCreated());
  }

  @Test
  void createExperience_withoutAuthorization_returns400() throws Exception {
    mockMvc.perform(multipart("/api/v1/experiences")
        .param("name", "Test Experience")
        .param("contact", "1234567890")
        .param("city", "Madrid")
        .param("country", "ESPAÑA")
        .param("price", "50.0")
        .param("startingDate", "2026-06-01")
        .param("endDate", "2026-06-10"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void createExperience_withInvalidToken_returnsUnauthorized() throws Exception {
    mockMvc.perform(multipart("/api/v1/experiences")
        .param("name", "Test Experience")
        .param("contact", "1234567890")
        .param("city", "Madrid")
        .param("country", "ESPAÑA")
        .param("price", "50.0")
        .param("startingDate", "2026-06-01")
        .param("endDate", "2026-06-10")
        .header("Authorization", "Bearer invalid-token"))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void createExperience_withMissingRequiredFields_returnsBadRequest() throws Exception {
    mockMvc.perform(multipart("/api/v1/experiences")
        .param("name", "Test Experience")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isBadRequest());
  }

  @Test
  void createExperience_withNonExperienceToken_returnsUnauthorized() throws Exception {
    User touristUser = new User("Tourist", "User", "tourist@example.com", passwordEncoder.encode("password123"),
        "Madrid", "ESPAÑA", Roles.TOURIST);
    touristUser = userRepository.save(touristUser);
    String touristToken = jwt.generateToken(touristUser.getId(), "TOURIST");

    mockMvc.perform(multipart("/api/v1/experiences")
        .param("name", "Test Experience")
        .param("contact", "1234567890")
        .param("city", "Madrid")
        .param("country", "ESPAÑA")
        .param("price", "50.0")
        .param("startingDate", "2026-06-01")
        .param("endDate", "2026-06-10")
        .header("Authorization", "Bearer " + touristToken))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void updateExperience_withValidData_returnsOk() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Original Name", "Original description", "1111111111", "Madrid", "ESPAÑA", "Original location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(put("/api/v1/experiences/" + experience.getId())
        .param("name", "Updated Experience")
        .param("description", "Updated description")
        .param("contact", "2222222222")
        .param("city", "Barcelona")
        .param("country", "ESPAÑA")
        .param("location", "Updated location")
        .param("price", "75.0")
        .param("startingDate", "2026-07-01")
        .param("endDate", "2026-07-10")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isOk());
  }

  @Test
  void updateExperience_withoutAuthorization_returnsBadRequest() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Original Name", "Original description", "1111111111", "Madrid", "ESPAÑA", "Original location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(put("/api/v1/experiences/" + experience.getId())
        .param("name", "Updated Experience")
        .param("contact", "2222222222")
        .param("city", "Barcelona")
        .param("country", "ESPAÑA")
        .param("price", "75.0")
        .param("startingDate", "2026-07-01")
        .param("endDate", "2026-07-10"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void updateExperience_withInvalidToken_returnsForbidden() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Original Name", "Original description", "1111111111", "Madrid", "ESPAÑA", "Original location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(put("/api/v1/experiences/" + experience.getId())
        .param("name", "Updated Experience")
        .param("contact", "2222222222")
        .param("city", "Barcelona")
        .param("country", "ESPAÑA")
        .param("price", "75.0")
        .param("startingDate", "2026-07-01")
        .param("endDate", "2026-07-10")
        .header("Authorization", "Bearer invalid-token"))
        .andExpect(status().isForbidden());
  }

  @Test
  void updateExperience_withMissingRequiredFields_returnsBadRequest() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Original Name", "Original description", "1111111111", "Madrid", "ESPAÑA", "Original location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(put("/api/v1/experiences/" + experience.getId())
        .param("name", "Updated Experience")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isBadRequest());
  }

  @Test
  void updateExperience_withNonOwnerToken_returnsForbidden() throws Exception {
    User otherUser = new User("Other", "User", "other@example.com", passwordEncoder.encode("password123"), "Madrid", "ESPAÑA",
        Roles.EXPERIENCE);
    otherUser = userRepository.save(otherUser);
    String otherToken = jwt.generateToken(otherUser.getId(), "EXPERIENCE");

    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Original Name", "Original description", "1111111111", "Madrid", "ESPAÑA", "Original location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(put("/api/v1/experiences/" + experience.getId())
        .param("name", "Updated Experience")
        .param("contact", "2222222222")
        .param("city", "Barcelona")
        .param("country", "ESPAÑA")
        .param("price", "75.0")
        .param("startingDate", "2026-07-01")
        .param("endDate", "2026-07-10")
        .header("Authorization", "Bearer " + otherToken))
        .andExpect(status().isForbidden());
  }

  @Test
  void setExperienceEnabled_withValidOwnerToken_enable_returnsOk() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Test Experience", "Description", "1111111111", "Madrid", "ESPAÑA", "Location", 50.0);
    experience.setEnable(false);
    experience = experienceRepository.save(experience);

    mockMvc.perform(patch("/api/v1/experiences/" + experience.getId())
        .param("enabled", "true")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isOk());
  }

  @Test
  void setExperienceEnabled_withValidOwnerToken_disable_returnsOk() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Test Experience", "Description", "1111111111", "Madrid", "ESPAÑA", "Location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(patch("/api/v1/experiences/" + experience.getId())
        .param("enabled", "false")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isOk());
  }

  @Test
  void setExperienceEnabled_withoutAuthorization_returnsBadRequest() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Test Experience", "Description", "1111111111", "Madrid", "ESPAÑA", "Location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(patch("/api/v1/experiences/" + experience.getId())
        .param("enabled", "true"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void setExperienceEnabled_withNonOwnerToken_returnsForbidden() throws Exception {
    User otherUser = new User("Other", "User", "other@example.com", passwordEncoder.encode("password123"), "Madrid", "ESPAÑA",
        Roles.EXPERIENCE);
    otherUser = userRepository.save(otherUser);
    String otherToken = jwt.generateToken(otherUser.getId(), "EXPERIENCE");

    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Test Experience", "Description", "1111111111", "Madrid", "ESPAÑA", "Location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(patch("/api/v1/experiences/" + experience.getId())
        .param("enabled", "false")
        .header("Authorization", "Bearer " + otherToken))
        .andExpect(status().isForbidden());
  }

  @Test
  void deleteExperience_withValidOwnerToken_returnsOk() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Test Experience", "Description", "1111111111", "Madrid", "ESPAÑA", "Location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(delete("/api/v1/experiences/" + experience.getId())
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isOk());
  }

  @Test
  void deleteExperience_withoutAuthorization_returnsBadRequest() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Test Experience", "Description", "1111111111", "Madrid", "ESPAÑA", "Location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(delete("/api/v1/experiences/" + experience.getId()))
        .andExpect(status().isBadRequest());
  }

  @Test
  void deleteExperience_withNonOwnerToken_returnsForbidden() throws Exception {
    User otherUser = new User("Other", "User", "other@example.com", passwordEncoder.encode("password123"), "Madrid", "ESPAÑA",
        Roles.EXPERIENCE);
    otherUser = userRepository.save(otherUser);
    String otherToken = jwt.generateToken(otherUser.getId(), "EXPERIENCE");

    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Test Experience", "Description", "1111111111", "Madrid", "ESPAÑA", "Location", 50.0);
    experience = experienceRepository.save(experience);

    mockMvc.perform(delete("/api/v1/experiences/" + experience.getId())
        .header("Authorization", "Bearer " + otherToken))
        .andExpect(status().isForbidden());
  }

  @Test
  void deleteExperience_withNonExistentExperience_returnsForbidden() throws Exception {
    UUID nonExistentId = UUID.randomUUID();

    mockMvc.perform(delete("/api/v1/experiences/" + nonExistentId)
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isForbidden());
  }

  @Test
  void getExperiences_withValidToken_returnsOk() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Test Experience", "Description", "1111111111", "Madrid", "ESPAÑA", "Location", 50.0);
    experienceRepository.save(experience);

    mockMvc.perform(get("/api/v1/experiences")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isOk());
  }

  @Test
  void getExperiences_withoutAuthorization_returnsBadRequest() throws Exception {
    mockMvc.perform(get("/api/v1/experiences"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void getExperiences_withIncludeDisabledTrue_returnsOk() throws Exception {
    Experience experience = new Experience(
        testUser, LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 10),
        "Test Experience", "Description", "1111111111", "Madrid", "ESPAÑA", "Location", 50.0);
    experience.setEnable(false);
    experienceRepository.save(experience);

    mockMvc.perform(get("/api/v1/experiences")
        .param("includeDisabled", "true")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isOk());
  }

}