package com.ecospot.business.dato;

import java.time.LocalDateTime;
import java.util.UUID;

public class ReservationResponse {

  private UUID id;
  private UUID rentalId;
  private String rentalName;
  private String userName;
  private String userSurname;
  private LocalDateTime startingDate;
  private LocalDateTime endDate;
  private boolean isCancelled;

  public ReservationResponse() {
  }

  public ReservationResponse(UUID id, UUID rentalId, String rentalName, String userName,
      String userSurname, LocalDateTime startingDate, LocalDateTime endDate, boolean isCancelled) {
    this.id = id;
    this.rentalId = rentalId;
    this.rentalName = rentalName;
    this.userName = userName;
    this.userSurname = userSurname;
    this.startingDate = startingDate;
    this.endDate = endDate;
    this.isCancelled = isCancelled;
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public UUID getRentalId() {
    return rentalId;
  }

  public void setRentalId(UUID rentalId) {
    this.rentalId = rentalId;
  }

  public String getRentalName() {
    return rentalName;
  }

  public void setRentalName(String rentalName) {
    this.rentalName = rentalName;
  }

  public String getUserName() {
    return userName;
  }

  public void setUserName(String userName) {
    this.userName = userName;
  }

  public String getUserSurname() {
    return userSurname;
  }

  public void setUserSurname(String userSurname) {
    this.userSurname = userSurname;
  }

  public LocalDateTime getStartingDate() {
    return startingDate;
  }

  public void setStartingDate(LocalDateTime startingDate) {
    this.startingDate = startingDate;
  }

  public LocalDateTime getEndDate() {
    return endDate;
  }

  public void setEndDate(LocalDateTime endDate) {
    this.endDate = endDate;
  }

  public boolean isCancelled() {
    return isCancelled;
  }

  public void setCancelled(boolean cancelled) {
    isCancelled = cancelled;
  }
}