package com.ecospot.business.dato;

import java.util.List;
import java.util.UUID;

public class RentalResponse {

  private UUID id;
  private String name;
  private String description;
  private String contact;
  private int size;
  private int peopleQuantity;
  private int rooms;
  private int bathrooms;
  private String city;
  private String country;
  private String location;
  private double valueNight;
  private boolean isEnable;
  private double reviewAverage;
  private List<ImageInfo> images;

  public RentalResponse() {
  }

  public RentalResponse(UUID id, String name, String description, String contact, int size,
      int peopleQuantity, int rooms, int bathrooms, String city, String country,
      String location, double valueNight, boolean isEnable, double reviewAverage, List<ImageInfo> images) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.contact = contact;
    this.size = size;
    this.peopleQuantity = peopleQuantity;
    this.rooms = rooms;
    this.bathrooms = bathrooms;
    this.city = city;
    this.country = country;
    this.location = location;
    this.valueNight = valueNight;
    this.isEnable = isEnable;
    this.reviewAverage = reviewAverage;
    this.images = images;
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
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

  public int getSize() {
    return size;
  }

  public void setSize(int size) {
    this.size = size;
  }

  public int getPeopleQuantity() {
    return peopleQuantity;
  }

  public void setPeopleQuantity(int peopleQuantity) {
    this.peopleQuantity = peopleQuantity;
  }

  public int getRooms() {
    return rooms;
  }

  public void setRooms(int rooms) {
    this.rooms = rooms;
  }

  public int getBathrooms() {
    return bathrooms;
  }

  public void setBathrooms(int bathrooms) {
    this.bathrooms = bathrooms;
  }

  public String getCity() {
    return city;
  }

  public void setCity(String city) {
    this.city = city;
  }

  public String getCountry() {
    return country;
  }

  public void setCountry(String country) {
    this.country = country;
  }

  public String getLocation() {
    return location;
  }

  public void setLocation(String location) {
    this.location = location;
  }

  public double getValueNight() {
    return valueNight;
  }

  public void setValueNight(double valueNight) {
    this.valueNight = valueNight;
  }

  public boolean isEnable() {
    return isEnable;
  }

  public void setEnable(boolean isEnable) {
    this.isEnable = isEnable;
  }

  public double getReviewAverage() {
    return reviewAverage;
  }

  public void setReviewAverage(double reviewAverage) {
    this.reviewAverage = reviewAverage;
  }

  public List<ImageInfo> getImages() {
    return images;
  }

  public void setImages(List<ImageInfo> images) {
    this.images = images;
  }

  public static class ImageInfo {
    private UUID id;
    private String extension;

    public ImageInfo() {
    }

    public ImageInfo(UUID id, String extension) {
      this.id = id;
      this.extension = extension;
    }

    public UUID getId() {
      return id;
    }

    public void setId(UUID id) {
      this.id = id;
    }

    public String getExtension() {
      return extension;
    }

    public void setExtension(String extension) {
      this.extension = extension;
    }
  }
}