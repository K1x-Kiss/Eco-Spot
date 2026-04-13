package com.ecospot.presentation;

import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ecospot.business.service.UserService;
import com.ecospot.business.dato.UpdateLocationRequest;
import com.ecospot.persistance.entity.User;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

  private final UserService userService;

  public UserController(UserService userService) {
    this.userService = userService;
  }

  @GetMapping("/me")
  public ResponseEntity<User> getCurrentUser(
      @RequestHeader("Authorization") String authorizationHeader) {

    String token = authorizationHeader.replace("Bearer ", "");
    Optional<User> user = userService.getUserByToken(token);

    return user.map(ResponseEntity::ok)
               .orElse(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
  }

  @PatchMapping("/location")
  public ResponseEntity<Void> updateLocation(
      @RequestHeader("Authorization") String authorizationHeader,
      @RequestBody UpdateLocationRequest request) {

    if (request.getCity() == null || request.getCity().isEmpty() ||
        request.getCountry() == null || request.getCountry().isEmpty()) {
      return ResponseEntity.badRequest().build();
    }

    String token = authorizationHeader.replace("Bearer ", "");
    boolean updated = userService.updateLocation(token, request.getCity(), request.getCountry());

    if (!updated) {
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    return ResponseEntity.ok().build();
  }
}