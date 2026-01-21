package com.backend.aura.modules.sos.repository;

import com.backend.aura.modules.sos.model.SOSSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface SOSSettingsRepository extends JpaRepository<SOSSettings, UUID> {

    Optional<SOSSettings> findByUserId(String userId);

    boolean existsByUserId(String userId);
}
