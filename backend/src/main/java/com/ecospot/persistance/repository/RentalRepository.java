
package com.ecospot.persistance.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ecospot.persistance.entity.Rental;

@Repository
public interface RentalRepository extends JpaRepository<Rental, UUID> {

  List<Rental> findByCityAndCountry(String city, String country);

  List<Rental> findByNameContainingIgnoreCase(String name);

  List<Rental> findByUserId(UUID userId);

}
