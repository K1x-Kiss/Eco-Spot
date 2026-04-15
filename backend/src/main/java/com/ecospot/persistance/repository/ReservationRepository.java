package com.ecospot.persistance.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ecospot.persistance.entity.Reservation;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, UUID> {

  List<Reservation> findByRentalIdAndStartingDateAfter(UUID rentalId, LocalDateTime dateTime);

  List<Reservation> findByRentalIdAndStartingDateAfterAndIsCancelledFalse(UUID rentalId, LocalDateTime dateTime);

  List<Reservation> findByRentalIdAndStartingDateBefore(UUID rentalId, LocalDateTime dateTime);

  List<Reservation> findByRentalIdAndStartingDateBeforeAndIsCancelledFalse(UUID rentalId, LocalDateTime dateTime);

}