package com.backend.aura.modules.messaging.repository;

import com.backend.aura.modules.messaging.model.Conversation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, String> {

    @Query("SELECT c FROM Conversation c WHERE " +
            "(c.participantOneId = :userId OR c.participantTwoId = :userId) " +
            "ORDER BY c.lastMessageAt DESC")
    Page<Conversation> findByParticipant(String userId, Pageable pageable);

    @Query("SELECT c FROM Conversation c WHERE " +
            "(c.participantOneId = :userA AND c.participantTwoId = :userB) OR " +
            "(c.participantOneId = :userB AND c.participantTwoId = :userA)")
    Optional<Conversation> findByParticipants(String userA, String userB);
}
