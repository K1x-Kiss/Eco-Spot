package com.ecospot.persistance.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ecospot.persistance.entity.Image;

@Repository
public interface ImageRepository extends JpaRepository<Image, UUID> {

  List<Image> findByRentalId(UUID rentalId);

  List<Image> findByBusinessId(UUID businessId);

  List<Image> findByExperienceId(UUID experienceId);

}