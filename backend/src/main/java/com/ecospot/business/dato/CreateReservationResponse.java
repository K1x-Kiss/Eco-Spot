package com.ecospot.business.dato;

import java.util.UUID;

public class CreateReservationResponse {

  private UUID id;
  private Double totalPrice;

  public CreateReservationResponse() {
  }

  public CreateReservationResponse(UUID id, Double totalPrice) {
    this.id = id;
    this.totalPrice = totalPrice;
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public Double getTotalPrice() {
    return totalPrice;
  }

  public void setTotalPrice(Double totalPrice) {
    this.totalPrice = totalPrice;
  }

}