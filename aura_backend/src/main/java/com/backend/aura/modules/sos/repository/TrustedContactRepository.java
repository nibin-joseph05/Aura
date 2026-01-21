package com.backend.aura.modules.sos.repository;

import com.backend.aura.modules.sos.model.TrustedContact;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TrustedContactRepository extends JpaRepository<TrustedContact, UUID> {

    List<TrustedContact> findByUserIdAndIsActiveTrueOrderByPriorityAsc(String userId);

    List<TrustedContact> findByUserIdOrderByPriorityAsc(String userId);

    List<TrustedContact> findBySosSettingsIdOrderByPriorityAsc(UUID sosSettingsId);

    int countByUserIdAndIsActiveTrue(String userId);

    boolean existsByUserIdAndPhone(String userId, String phone);
}
