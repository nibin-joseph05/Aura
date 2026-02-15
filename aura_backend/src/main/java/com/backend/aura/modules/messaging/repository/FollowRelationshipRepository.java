package com.backend.aura.modules.messaging.repository;

import com.backend.aura.modules.messaging.model.FollowRelationship;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FollowRelationshipRepository extends JpaRepository<FollowRelationship, String> {

    Optional<FollowRelationship> findByFollowerIdAndFollowingId(String followerId, String followingId);

    List<FollowRelationship> findByFollowingIdAndStatus(String followingId, FollowRelationship.FollowStatus status);

    Page<FollowRelationship> findByFollowingIdAndStatus(
            String followingId, FollowRelationship.FollowStatus status, Pageable pageable);

    List<FollowRelationship> findByFollowerIdAndStatus(String followerId, FollowRelationship.FollowStatus status);

    boolean existsByFollowerIdAndFollowingIdAndStatus(
            String followerId, String followingId, FollowRelationship.FollowStatus status);

    long countByFollowingIdAndStatus(String followingId, FollowRelationship.FollowStatus status);
}
