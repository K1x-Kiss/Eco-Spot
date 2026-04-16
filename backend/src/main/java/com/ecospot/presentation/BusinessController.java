package com.ecospot.presentation;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.ecospot.business.dato.CreateBusinessRequest;
import com.ecospot.business.service.BusinessService;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class BusinessController {

  private final BusinessService businessService;

  public BusinessController(BusinessService businessService) {
    this.businessService = businessService;
  }

  @PostMapping("/businesses")
  public ResponseEntity<Void> createBusiness(
      @RequestHeader("Authorization") String authorizationHeader,
      @ModelAttribute CreateBusinessRequest request,
      @RequestParam(value = "images", required = false) List<MultipartFile> images) {

    if (request.getName() == null || request.getName().isEmpty() ||
        request.getContact() == null || request.getContact().isEmpty() ||
        request.getCity() == null || request.getCity().isEmpty() ||
        request.getCountry() == null || request.getCountry().isEmpty()) {
      return ResponseEntity.badRequest().build();
    }

    if (images != null && images.size() > 3) {
      return ResponseEntity.badRequest().build();
    }

    request.setImages(images);

    String token = authorizationHeader.replace("Bearer ", "");
    boolean created = businessService.createBusiness(token, request);

    if (!created) {
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    return ResponseEntity.status(HttpStatus.CREATED).build();
  }

}