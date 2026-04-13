package com.ecospot.persistance.entity;

import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "images")
public class Image {

  @Id
  @Column(name = "id", nullable = false, columnDefinition = "UUID DEFAULT gen_random_uuid()")
  private UUID id = UUID.randomUUID();

  @ManyToOne
  @JoinColumn(name = "rental_id", nullable = true)
  private Rental rental;

  @ManyToOne
  @JoinColumn(name = "business_id", nullable = true)
  private Business business;

  @ManyToOne
  @JoinColumn(name = "experience_id", nullable = true)
  private Experience experience;

  public Image() {
  }

  public Image(Rental rental) {
    this.rental = rental;
  }

  public Image(Business business) {
    this.business = business;
  }

  public Image(Experience experience) {
    this.experience = experience;
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public Rental getRental() {
    return rental;
  }

  public void setRental(Rental rental) {
    this.rental = rental;
  }

  public Business getBusiness() {
    return business;
  }

  public void setBusiness(Business business) {
    this.business = business;
  }

  public Experience getExperience() {
    return experience;
  }

  public void setExperience(Experience experience) {
    this.experience = experience;
  }

}