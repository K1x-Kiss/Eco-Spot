package com.ecospot.persistance.entity;

import java.time.LocalDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "experiences")
public class Experience {

  @Id
  @Column(name = "id", nullable = false, columnDefinition = "UUID DEFAULT gen_random_uuid()")
  private UUID id = UUID.randomUUID();

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
  private LocalDateTime createdAt;

  @ManyToOne
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @Column(name = "is_enable", nullable = false)
  private boolean isEnable = true;

  @Column(name = "starting_date", nullable = false)
  private LocalDateTime startingDate;

  @Column(name = "end_date", nullable = false)
  private LocalDateTime endDate;

  @Column(name = "name", nullable = false, length = 100)
  private String name = "";

  @Column(name = "description", nullable = true, length = 300)
  private String description = "";

  @Column(name = "contact", nullable = false, length = 10)
  private String contact = "";

  @Column(name = "city", nullable = false, length = 80)
  private String city = "";

  @Column(name = "country", nullable = false, length = 80)
  private String country = "";

  @Column(name = "location", nullable = true, columnDefinition = "TEXT")
  private String location = "";

  @Column(name = "value", nullable = false)
  private Double value = 0.0;

  public Experience() {
  }

  public Experience(User user, LocalDateTime startingDate, LocalDateTime endDate, String name,
      String description, String contact, String city, String country, String location, Double value) {
    this.user = user;
    this.startingDate = startingDate;
    this.endDate = endDate;
    this.name = name;
    this.description = description;
    this.contact = contact;
    this.city = city != null ? city.toUpperCase() : "";
    this.country = country != null ? country.toUpperCase() : "";
    this.location = location;
    this.value = value;
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public LocalDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(LocalDateTime createdAt) {
    this.createdAt = createdAt;
  }

  public User getUser() {
    return user;
  }

  public void setUser(User user) {
    this.user = user;
  }

  public boolean isEnable() {
    return isEnable;
  }

  public void setEnable(boolean isEnable) {
    this.isEnable = isEnable;
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

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public String getContact() {
    return contact;
  }

  public void setContact(String contact) {
    this.contact = contact;
  }

  public String getCity() {
    return city;
  }

  public void setCity(String city) {
    this.city = city != null ? city.toUpperCase() : "";
  }

  public String getCountry() {
    return country;
  }

  public void setCountry(String country) {
    this.country = country != null ? country.toUpperCase() : "";
  }

  public String getLocation() {
    return location;
  }

  public void setLocation(String location) {
    this.location = location;
  }

  public Double getValue() {
    return value;
  }

  public void setValue(Double value) {
    this.value = value;
  }

}
