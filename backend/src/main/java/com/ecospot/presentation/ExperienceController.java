package com.ecospot.presentation;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.ecospot.business.dato.CreateExperienceRequest;
import com.ecospot.business.dato.ExperienceResponse;
import com.ecospot.business.service.ExperienceService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class ExperienceController {

  private final ExperienceService experienceService;

  public ExperienceController(ExperienceService experienceService) {
    this.experienceService = experienceService;
  }

  @GetMapping("/experiences")
  public ResponseEntity<List<ExperienceResponse>> getExperiences(
      @RequestHeader("Authorization") String authorizationHeader,
      @RequestParam(value = "includeDisabled", required = false) boolean includeDisabled) {

    String token = authorizationHeader.replace("Bearer ", "");
    List<ExperienceResponse> experiences = experienceService.getExperiencesByToken(token, includeDisabled);

    return ResponseEntity.ok(experiences);
  }

  @PostMapping("/experiences")
  public ResponseEntity<Void> createExperience(
      @RequestHeader("Authorization") String authorizationHeader,
      @ModelAttribute CreateExperienceRequest request,
      @RequestParam(value = "images", required = false) List<MultipartFile> images) {

    if (request.getName() == null || request.getName().isEmpty() ||
        request.getContact() == null || request.getContact().isEmpty() ||
        request.getCity() == null || request.getCity().isEmpty() ||
        request.getCountry() == null || request.getCountry().isEmpty() ||
        request.getPrice() == null ||
        request.getStartingDate() == null ||
        request.getEndDate() == null) {
      return ResponseEntity.badRequest().build();
    }

    if (images != null && images.size() > 3) {
      return ResponseEntity.badRequest().build();
    }

    request.setImages(images);

    String token = authorizationHeader.replace("Bearer ", "");
    boolean created = experienceService.createExperience(token, request);

    if (!created) {
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    return ResponseEntity.status(HttpStatus.CREATED).build();
  }

  @PutMapping("/experiences/{experienceId}")
  public ResponseEntity<Void> updateExperience(
      @RequestHeader("Authorization") String authorizationHeader,
      @PathVariable UUID experienceId,
      @ModelAttribute CreateExperienceRequest request,
      @RequestParam(value = "images", required = false) List<MultipartFile> images) {

    if (request.getName() == null || request.getName().isEmpty() ||
        request.getContact() == null || request.getContact().isEmpty() ||
        request.getCity() == null || request.getCity().isEmpty() ||
        request.getCountry() == null || request.getCountry().isEmpty() ||
        request.getPrice() == null ||
        request.getStartingDate() == null ||
        request.getEndDate() == null) {
      return ResponseEntity.badRequest().build();
    }

    if (images != null && images.size() > 3) {
      return ResponseEntity.badRequest().build();
    }

    request.setImages(images);

    String token = authorizationHeader.replace("Bearer ", "");
    boolean updated = experienceService.updateExperience(token, experienceId, request);

    if (!updated) {
      return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }

    return ResponseEntity.ok().build();
  }

  @PatchMapping("/experiences/{experienceId}")
  public ResponseEntity<Void> setExperienceEnabled(
      @RequestHeader("Authorization") String authorizationHeader,
      @PathVariable UUID experienceId,
      @RequestParam(value = "enabled") boolean enabled) {

    String token = authorizationHeader.replace("Bearer ", "");
    boolean updated = experienceService.setExperienceEnabled(token, experienceId, enabled);

    if (!updated) {
      return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }

    return ResponseEntity.ok().build();
  }

  @DeleteMapping("/experiences/{experienceId}")
  public ResponseEntity<Void> deleteExperience(
      @RequestHeader("Authorization") String authorizationHeader,
      @PathVariable UUID experienceId) {

    String token = authorizationHeader.replace("Bearer ", "");
    boolean deleted = experienceService.deleteExperience(token, experienceId);

    if (!deleted) {
      return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }

    return ResponseEntity.ok().build();
  }

}
