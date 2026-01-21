package com.backend.aura.modules.activity.type.repository;

import com.backend.aura.modules.activity.type.model.ActivityType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ActivityTypeRepository extends JpaRepository<ActivityType, UUID> {

    List<ActivityType> findByIsActiveTrueOrderByNameAsc();

    List<ActivityType> findByCategoryIdAndIsActiveTrue(UUID categoryId);

    List<ActivityType> findByCategoryId(UUID categoryId);

    List<ActivityType> findByIsGymActivityTrue();

    boolean existsByNameAndCategoryId(String name, UUID categoryId);

    boolean existsByNameAndCategoryIdAndIdNot(String name, UUID categoryId, UUID id);
}
