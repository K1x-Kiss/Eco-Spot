package com.ecospot.business.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.ecospot.business.dato.CreateBusinessRequest;
import com.ecospot.persistance.entity.Business;
import com.ecospot.persistance.entity.Image;
import com.ecospot.persistance.entity.User;
import com.ecospot.persistance.repository.BusinessRepository;
import com.ecospot.persistance.repository.ImageRepository;
import com.ecospot.persistance.repository.UserRepository;
import com.ecospot.util.ImageStorage;
import com.ecospot.util.ImageStorage.SavedImage;
import com.ecospot.util.JWT;

@Service
public class BusinessService {
  private static final Logger logger = LoggerFactory.getLogger(BusinessService.class);

  private final JWT jwt;
  private final UserRepository userRepository;
  private final BusinessRepository businessRepository;
  private final ImageRepository imageRepository;
  private final ImageStorage imageStorage;

  public BusinessService(JWT jwt, UserRepository userRepository, BusinessRepository businessRepository,
      ImageRepository imageRepository, ImageStorage imageStorage) {
    this.jwt = jwt;
    this.userRepository = userRepository;
    this.businessRepository = businessRepository;
    this.imageRepository = imageRepository;
    this.imageStorage = imageStorage;
  }

  private boolean isValidBusinessToken(String token) {
    if (!jwt.validateToken(token)) {
      logger.warn("Invalid token provided for business operation");
      return false;
    }
    return "BUSINESS".equals(jwt.getRol(token));
  }

  public boolean createBusiness(String token, CreateBusinessRequest request) {
    if (!isValidBusinessToken(token)) {
      logger.warn("Invalid or non-BUSINESS token for createBusiness");
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
      Business business = new Business(
          user,
          request.getName(),
          request.getDescription() != null ? request.getDescription() : "",
          request.getContact(),
          request.getCity(),
          request.getCountry(),
          request.getLocation(),
          request.getMenu());

      Business savedBusiness = businessRepository.save(business);

      for (SavedImage saved : savedImages) {
        Image image = new Image(saved.getId(), saved.getExtension(), savedBusiness);
        imageRepository.save(image);
      }

      logger.info("Business created successfully: {}", savedBusiness.getId());
      return true;

    } catch (Exception e) {
      for (SavedImage saved : savedImages) {
        imageStorage.deleteImage(saved.getId(), saved.getExtension());
      }
      logger.error("Error creating business: {}", e.getMessage(), e);
      return false;
    }
  }

}