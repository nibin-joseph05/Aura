package com.backend.aura.modules.sos.repository;

import com.backend.aura.modules.sos.model.LiveLocationSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface LiveLocationRepository extends JpaRepository<LiveLocationSession, UUID> {

    Optional<LiveLocationSession> findByUserIdAndActiveTrue(String userId);

    List<LiveLocationSession> findByUserIdOrderByStartedAtDesc(String userId);

    List<LiveLocationSession> findByActiveTrue();
}
