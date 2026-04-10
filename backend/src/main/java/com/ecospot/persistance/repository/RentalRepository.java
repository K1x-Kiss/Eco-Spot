
package com.ecospot.persistance.repository;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ecospot.persistance.entity.Rental;

@Repository
public interface RentalRepository extends JpaRepository<Rental, UUID> {

}
