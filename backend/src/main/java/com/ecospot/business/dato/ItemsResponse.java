package com.ecospot.business.dato;

import java.util.List;

import com.ecospot.persistance.entity.Business;
import com.ecospot.persistance.entity.Experience;
import com.ecospot.persistance.entity.Rental;

public class ItemsResponse {

  private List<Experience> experiences;
  private List<Rental> rentals;
  private List<Business> businesses;

  public ItemsResponse() {
  }

  public ItemsResponse(List<Experience> experiences, List<Rental> rentals, List<Business> businesses) {
    this.experiences = experiences;
    this.rentals = rentals;
    this.businesses = businesses;
  }

  public List<Experience> getExperiences() {
    return experiences;
  }

  public void setExperiences(List<Experience> experiences) {
    this.experiences = experiences;
  }

  public List<Rental> getRentals() {
    return rentals;
  }

  public void setRentals(List<Rental> rentals) {
    this.rentals = rentals;
  }

  public List<Business> getBusinesses() {
    return businesses;
  }

  public void setBusinesses(List<Business> businesses) {
    this.businesses = businesses;
  }

}