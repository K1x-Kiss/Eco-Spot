package com.ecospot.business.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.ecospot.business.dato.CreateExperienceRequest;
import com.ecospot.business.dato.ExperienceResponse;
import com.ecospot.business.dato.ExperienceResponse.ImageInfo;
import com.ecospot.persistance.entity.Experience;
import com.ecospot.persistance.entity.Image;
import com.ecospot.persistance.entity.User;
import com.ecospot.persistance.repository.ExperienceRepository;
import com.ecospot.persistance.repository.ImageRepository;
import com.ecospot.persistance.repository.UserRepository;
import com.ecospot.util.ImageStorage;
import com.ecospot.util.ImageStorage.SavedImage;
import com.ecospot.util.JWT;

@Service
public class ExperienceService {
  private static final Logger logger = LoggerFactory.getLogger(ExperienceService.class);

  private final JWT jwt;
  private final UserRepository userRepository;
  private final ExperienceRepository experienceRepository;
  private final ImageRepository imageRepository;
  private final ImageStorage imageStorage;

  public ExperienceService(JWT jwt, UserRepository userRepository, ExperienceRepository experienceRepository,
      ImageRepository imageRepository, ImageStorage imageStorage) {
    this.jwt = jwt;
    this.userRepository = userRepository;
    this.experienceRepository = experienceRepository;
    this.imageRepository = imageRepository;
    this.imageStorage = imageStorage;
  }

  private boolean isValidExperienceToken(String token) {
    if (!jwt.validateToken(token)) {
      logger.warn("Invalid token provided for experience operation");
      return false;
    }
    return "EXPERIENCE".equals(jwt.getRol(token));
  }

  private boolean isValidExperienceOrAdminToken(String token) {
    if (!jwt.validateToken(token)) {
      logger.warn("Invalid token provided for experience operation");
      return false;
    }
    String role = jwt.getRol(token);
    return "EXPERIENCE".equals(role) || "ADMIN".equals(role);
  }

  public boolean createExperience(String token, CreateExperienceRequest request) {
    if (!isValidExperienceToken(token)) {
      logger.warn("Invalid or non-EXPERIENCE token for createExperience");
      return false;
    }

    UUID userId = jwt.getUserId(token);
    Optional<User> userOpt = userRepository.findById(userId);
    if (userOpt.isEmpty()) {
      logger.warn("User not found: {}", userId);
      return false;
    }

    List<MultipartFile> images = request.getImages();
    List<SavedImage> savedImages = new ArrayList<>();

    if (images != null && !images.isEmpty()) {
      if (images.size() > 3) {
        logger.warn("Maximum 3 images allowed, got: {}", images.size());
        return false;
      }

      for (MultipartFile file : images) {
        SavedImage saved = imageStorage.saveImage(file);
        if (saved == null) {
          for (SavedImage s : savedImages) {
            imageStorage.deleteImage(s.getId(), s.getExtension());
          }
          logger.warn("Failed to save image, rolling back all images");
          return false;
        }
        savedImages.add(saved);
      }
    }

    try {
      User user = userOpt.get();
      Experience experience = new Experience(
          user,
          request.getStartingDate(),
          request.getEndDate(),
          request.getName(),
          request.getDescription() != null ? request.getDescription() : "",
          request.getContact(),
          request.getCity(),
          request.getCountry(),
          request.getLocation(),
          request.getPrice());

      Experience savedExperience = experienceRepository.save(experience);

      for (SavedImage saved : savedImages) {
        Image image = new Image(saved.getId(), saved.getExtension(), savedExperience);
        imageRepository.save(image);
      }

      logger.info("Experience created successfully: {}", savedExperience.getId());
      return true;

    } catch (Exception e) {
      for (SavedImage saved : savedImages) {
        imageStorage.deleteImage(saved.getId(), saved.getExtension());
      }
      logger.error("Error creating experience: {}", e.getMessage(), e);
      return false;
    }
  }

  public boolean updateExperience(String token, UUID experienceId, CreateExperienceRequest request) {
    if (!isValidExperienceOrAdminToken(token)) {
      logger.warn("Invalid token for updateExperience");
      return false;
    }

    UUID userId = jwt.getUserId(token);
    Optional<User> userOpt = userRepository.findById(userId);
    if (userOpt.isEmpty()) {
      logger.warn("User not found: {}", userId);
      return false;
    }

    Optional<Experience> experienceOpt = experienceRepository.findById(experienceId);
    if (experienceOpt.isEmpty()) {
      logger.warn("Experience not found: {}", experienceId);
      return false;
    }

    Experience experience = experienceOpt.get();
    String userRole = jwt.getRol(token);

    boolean isOwner = experience.getUser().getId().equals(userId);
    boolean isAdmin = "ADMIN".equals(userRole);

    if (!isOwner && !isAdmin) {
      logger.warn("User {} is not authorized to update experience {}", userId, experienceId);
      return false;
    }

    if (request.getName() == null || request.getName().isEmpty() ||
        request.getContact() == null || request.getContact().isEmpty() ||
        request.getCity() == null || request.getCity().isEmpty() ||
        request.getCountry() == null || request.getCountry().isEmpty() ||
        request.getPrice() == null ||
        request.getStartingDate() == null ||
        request.getEndDate() == null) {
      logger.warn("Missing required fields for update");
      return false;
    }

    List<Image> existingImages = imageRepository.findByExperienceId(experienceId);
    for (Image img : existingImages) {
      imageStorage.deleteImage(img.getId(), img.getExtension());
      imageRepository.delete(img);
    }

    List<MultipartFile> images = request.getImages();
    List<SavedImage> savedImages = new ArrayList<>();

    if (images != null && !images.isEmpty()) {
      if (images.size() > 3) {
        logger.warn("Maximum 3 images allowed, got: {}", images.size());
        return false;
      }

      for (MultipartFile file : images) {
        SavedImage saved = imageStorage.saveImage(file);
        if (saved == null) {
          for (SavedImage s : savedImages) {
            imageStorage.deleteImage(s.getId(), s.getExtension());
          }
          logger.warn("Failed to save image during update, rolling back");
          return false;
        }
        savedImages.add(saved);
      }
    }

    try {
      experience.setName(request.getName());
      experience.setDescription(request.getDescription() != null ? request.getDescription() : "");
      experience.setContact(request.getContact());
      experience.setCity(request.getCity().toUpperCase());
      experience.setCountry(request.getCountry().toUpperCase());
      experience.setLocation(request.getLocation());
      experience.setPrice(request.getPrice());
      experience.setStartingDate(request.getStartingDate());
      experience.setEndDate(request.getEndDate());

      Experience savedExperience = experienceRepository.save(experience);

      for (SavedImage saved : savedImages) {
        Image image = new Image(saved.getId(), saved.getExtension(), savedExperience);
        imageRepository.save(image);
      }

      logger.info("Experience updated successfully: {}", savedExperience.getId());
      return true;

    } catch (Exception e) {
      for (SavedImage saved : savedImages) {
        imageStorage.deleteImage(saved.getId(), saved.getExtension());
      }
      logger.error("Error updating experience: {}", e.getMessage(), e);
      return false;
    }
  }

  public boolean setExperienceEnabled(String token, UUID experienceId, boolean enabled) {
    if (!isValidExperienceOrAdminToken(token)) {
      logger.warn("Invalid token for setExperienceEnabled");
      return false;
    }

    UUID userId = jwt.getUserId(token);
    Optional<Experience> experienceOpt = experienceRepository.findById(experienceId);
    if (experienceOpt.isEmpty()) {
      logger.warn("Experience not found: {}", experienceId);
      return false;
    }

    Experience experience = experienceOpt.get();
    String userRole = jwt.getRol(token);

    boolean isOwner = experience.getUser().getId().equals(userId);
    boolean isAdmin = "ADMIN".equals(userRole);

    if (!isOwner && !isAdmin) {
      logger.warn("User {} is not authorized to set experience {} enabled status", userId, experienceId);
      return false;
    }

    try {
      experience.setEnable(enabled);
      experienceRepository.save(experience);

      if (enabled) {
        logger.info("Experience enabled successfully: {}", experienceId);
      } else {
        logger.info("Experience disabled successfully: {}", experienceId);
      }
      return true;

    } catch (Exception e) {
      logger.error("Error setting experience enabled status: {}", e.getMessage(), e);
      return false;
    }
  }

  public boolean deleteExperience(String token, UUID experienceId) {
    if (!isValidExperienceOrAdminToken(token)) {
      logger.warn("Invalid token for deleteExperience");
      return false;
    }

    UUID userId = jwt.getUserId(token);
    Optional<Experience> experienceOpt = experienceRepository.findById(experienceId);
    if (experienceOpt.isEmpty()) {
      logger.warn("Experience not found: {}", experienceId);
      return false;
    }

    Experience experience = experienceOpt.get();
    String userRole = jwt.getRol(token);

    boolean isOwner = experience.getUser().getId().equals(userId);
    boolean isAdmin = "ADMIN".equals(userRole);

    if (!isOwner && !isAdmin) {
      logger.warn("User {} is not authorized to delete experience {}", userId, experienceId);
      return false;
    }

    try {
      List<Image> existingImages = imageRepository.findByExperienceId(experienceId);
      for (Image img : existingImages) {
        imageStorage.deleteImage(img.getId(), img.getExtension());
        imageRepository.delete(img);
      }

      experienceRepository.delete(experience);
      logger.info("Experience deleted successfully: {}", experienceId);
      return true;

    } catch (Exception e) {
      logger.error("Error deleting experience: {}", e.getMessage(), e);
      return false;
    }
  }

  public List<ExperienceResponse> getExperiencesByToken(String token, boolean includeDisabled) {
    if (!jwt.validateToken(token)) {
      logger.warn("Invalid token for getExperiencesByToken");
      return List.of();
    }

    UUID userId = jwt.getUserId(token);
    List<Experience> experiences = experienceRepository.findByUserId(userId);

    if (!includeDisabled) {
      experiences = experiences.stream()
          .filter(Experience::isEnable)
          .toList();
    }

    return experiences.stream()
        .map(this::toExperienceResponse)
        .toList();
  }

  private ExperienceResponse toExperienceResponse(Experience experience) {
    List<ImageInfo> images = imageRepository.findByExperienceId(experience.getId()).stream()
        .map(img -> new ImageInfo(img.getId(), img.getExtension()))
        .toList();

    String startDateStr = experience.getStartingDate() != null ? experience.getStartingDate().toString() : null;
    String endDateStr = experience.getEndDate() != null ? experience.getEndDate().toString() : null;

    return new ExperienceResponse(
        experience.getId(),
        experience.getName(),
        experience.getDescription(),
        experience.getContact(),
        experience.getCity(),
        experience.getCountry(),
        experience.getLocation(),
        experience.getPrice(),
        startDateStr,
        endDateStr,
        experience.isEnable(),
        images);
  }

}