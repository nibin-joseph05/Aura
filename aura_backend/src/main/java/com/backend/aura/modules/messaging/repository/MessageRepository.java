package com.backend.aura.modules.messaging.repository;

import com.backend.aura.modules.messaging.model.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MessageRepository extends JpaRepository<Message, String> {

    Page<Message> findByConversationIdOrderBySentAtDesc(String conversationId, Pageable pageable);

    long countByConversationIdAndSenderIdNotAndStatusNot(
            String conversationId, String userId, Message.MessageStatus status);
}
