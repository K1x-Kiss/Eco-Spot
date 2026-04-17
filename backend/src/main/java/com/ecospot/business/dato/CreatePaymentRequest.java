package com.ecospot.business.dato;

import java.util.UUID;

public class CreatePaymentRequest {

  private UUID reservationId;
  private Double amount;

  public CreatePaymentRequest() {
  }

  public UUID getReservationId() {
    return reservationId;
  }

  public void setReservationId(UUID reservationId) {
    this.reservationId = reservationId;
  }

  public Double getAmount() {
    return amount;
  }

  public void setAmount(Double amount) {
    this.amount = amount;
  }

}