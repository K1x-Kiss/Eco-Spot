package com.ecospot.persistance.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ecospot.persistance.entity.Review;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {

  List<Review> findByRentalId(UUID rentalId);

}