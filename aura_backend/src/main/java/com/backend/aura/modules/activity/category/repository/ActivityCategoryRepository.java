package com.backend.aura.modules.activity.category.repository;

import com.backend.aura.modules.activity.category.model.ActivityCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ActivityCategoryRepository extends JpaRepository<ActivityCategory, UUID> {

    List<ActivityCategory> findByIsActiveTrueOrderByNameAsc();

    Optional<ActivityCategory> findByName(String name);

    boolean existsByName(String name);

    boolean existsByNameAndIdNot(String name, UUID id);
}
