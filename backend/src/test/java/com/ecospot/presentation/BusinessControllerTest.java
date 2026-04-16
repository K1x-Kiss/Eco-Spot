package com.ecospot.presentation;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

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
import com.ecospot.persistance.entity.User;
import com.ecospot.persistance.repository.BusinessRepository;
import com.ecospot.persistance.repository.UserRepository;
import com.ecospot.util.JWT;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootTest
@TestPropertySource(properties = {
    "jwt.secret=EcoSpot2026SecretKeyForJWTTokenGen12345678901234567890123456789012345678901234567890",
    "jwt.expiration=864000"
})
public class BusinessControllerTest {

  @Autowired
  private WebApplicationContext context;

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private BusinessRepository businessRepository;

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
    businessRepository.deleteAll();
    userRepository.deleteAll();

    testUser = new User("Test", "User", "test@example.com", passwordEncoder.encode("password123"), "Madrid", "ESPAÑA",
        Roles.BUSINESS);
    testUser = userRepository.save(testUser);

    validToken = jwt.generateToken(testUser.getId(), "BUSINESS");
  }

  @AfterEach
  void tearDown() {
    businessRepository.deleteAll();
    userRepository.deleteAll();
  }

  @Test
  void createBusiness_withValidData_returnsCreated() throws Exception {
    mockMvc.perform(multipart("/api/v1/businesses")
        .param("name", "Test Business")
        .param("description", "A test business")
        .param("contact", "1234567890")
        .param("city", "Madrid")
        .param("country", "ESPAÑA")
        .param("location", "Calle Test 123")
        .param("menu", "Test menu")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isCreated());
  }

  @Test
  void createBusiness_withoutAuthorization_returns400() throws Exception {
    mockMvc.perform(multipart("/api/v1/businesses")
        .param("name", "Test Business")
        .param("contact", "1234567890")
        .param("city", "Madrid")
        .param("country", "ESPAÑA"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void createBusiness_withInvalidToken_returnsUnauthorized() throws Exception {
    mockMvc.perform(multipart("/api/v1/businesses")
        .param("name", "Test Business")
        .param("contact", "1234567890")
        .param("city", "Madrid")
        .param("country", "ESPAÑA")
        .header("Authorization", "Bearer invalid-token"))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void createBusiness_withMissingRequiredFields_returnsBadRequest() throws Exception {
    mockMvc.perform(multipart("/api/v1/businesses")
        .param("name", "Test Business")
        .header("Authorization", "Bearer " + validToken))
        .andExpect(status().isBadRequest());
  }

  @Test
  void createBusiness_withNonBusinessToken_returnsUnauthorized() throws Exception {
    User touristUser = new User("Tourist", "User", "tourist@example.com", passwordEncoder.encode("password123"),
        "Madrid", "ESPAÑA", Roles.TOURIST);
    touristUser = userRepository.save(touristUser);
    String touristToken = jwt.generateToken(touristUser.getId(), "TOURIST");

    mockMvc.perform(multipart("/api/v1/businesses")
        .param("name", "Test Business")
        .param("contact", "1234567890")
        .param("city", "Madrid")
        .param("country", "ESPAÑA")
        .header("Authorization", "Bearer " + touristToken))
        .andExpect(status().isUnauthorized());
  }

}