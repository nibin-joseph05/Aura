package com.backend.aura.modules.sos.service;

import com.backend.aura.modules.sos.dto.*;
import com.backend.aura.modules.sos.model.SOSEvent;
import com.backend.aura.modules.sos.model.SOSSettings;
import com.backend.aura.modules.sos.model.TrustedContact;
import com.backend.aura.modules.sos.model.enums.SOSEventStatus;
import com.backend.aura.modules.sos.repository.SOSEventRepository;
import com.backend.aura.modules.sos.repository.SOSSettingsRepository;
import com.backend.aura.modules.sos.repository.TrustedContactRepository;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SOSService {

    private final SOSSettingsRepository sosSettingsRepository;
    private final TrustedContactRepository trustedContactRepository;
    private final SOSEventRepository sosEventRepository;
    private final UserRepository userRepository;

    @Transactional
    public SOSSettingsResponse getOrCreateSOSSettings(String userId) {
        SOSSettings settings = sosSettingsRepository.findByUserId(userId)
                .orElseGet(() -> {
                    SOSSettings newSettings = new SOSSettings();
                    newSettings.setUserId(userId);
                    return sosSettingsRepository.save(newSettings);
                });

        List<TrustedContactResponse> contacts = trustedContactRepository
                .findByUserIdAndIsActiveTrueOrderByPriorityAsc(userId)
                .stream()
                .map(this::mapToContactResponse)
                .collect(Collectors.toList());

        SOSSettingsResponse response = new SOSSettingsResponse();
        response.setId(settings.getId());
        response.setUserId(settings.getUserId());
        response.setCustomMessage(settings.getCustomMessage());
        response.setIsActive(settings.getIsActive());
        response.setContacts(contacts);
        response.setTotalContacts(contacts.size());

        return response;
    }

    @Transactional
    public SOSSettingsResponse updateSOSMessage(String userId, String customMessage) {
        SOSSettings settings = sosSettingsRepository.findByUserId(userId)
                .orElseGet(() -> {
                    SOSSettings newSettings = new SOSSettings();
                    newSettings.setUserId(userId);
                    return sosSettingsRepository.save(newSettings);
                });

        settings.setCustomMessage(customMessage);
        sosSettingsRepository.save(settings);

        return getOrCreateSOSSettings(userId);
    }

    public List<TrustedContactResponse> getTrustedContacts(String userId) {
        return trustedContactRepository.findByUserIdAndIsActiveTrueOrderByPriorityAsc(userId)
                .stream()
                .map(this::mapToContactResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public TrustedContactResponse addTrustedContact(String userId, CreateTrustedContactRequest request) {
        SOSSettings settings = sosSettingsRepository.findByUserId(userId)
                .orElseGet(() -> {
                    SOSSettings newSettings = new SOSSettings();
                    newSettings.setUserId(userId);
                    return sosSettingsRepository.save(newSettings);
                });

        if (trustedContactRepository.existsByUserIdAndPhone(userId, request.getPhone())) {
            throw new IllegalArgumentException("Contact with this phone number already exists");
        }

        int currentCount = trustedContactRepository.countByUserIdAndIsActiveTrue(userId);

        TrustedContact contact = new TrustedContact();
        contact.setSosSettingsId(settings.getId());
        contact.setUserId(userId);
        contact.setName(request.getName());
        contact.setPhone(request.getPhone());
        contact.setEmail(request.getEmail());
        contact.setRelationship(request.getRelationship());
        contact.setPriority(request.getPriority() != null ? request.getPriority() : currentCount + 1);

        TrustedContact saved = trustedContactRepository.save(contact);
        return mapToContactResponse(saved);
    }

    @Transactional
    public void removeTrustedContact(String userId, UUID contactId) {
        TrustedContact contact = trustedContactRepository.findById(contactId)
                .orElseThrow(() -> new IllegalArgumentException("Contact not found"));

        if (!contact.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Contact does not belong to this user");
        }

        contact.setIsActive(false);
        trustedContactRepository.save(contact);
    }

    @Transactional
    public SOSEventResponse triggerSOS(String userId, TriggerSOSRequest request) {
        User user = userRepository.findById(userId).orElse(null);

        SOSSettings settings = sosSettingsRepository.findByUserId(userId).orElse(null);
        String message = request.getCustomMessage();
        if ((message == null || message.isEmpty()) && settings != null) {
            message = settings.getCustomMessage();
        }
        if (message == null || message.isEmpty()) {
            message = "I need help! This is an emergency.";
        }

        SOSEvent event = new SOSEvent();
        event.setUserId(userId);
        event.setUserName(user != null ? user.getName() : null);
        event.setUserPhone(user != null ? user.getPhone() : null);
        event.setLatitude(request.getLatitude());
        event.setLongitude(request.getLongitude());
        event.setAddress(request.getAddress());
        event.setMessage(message);
        event.setContactsNotified(request.getContactsNotified() != null ? request.getContactsNotified() : 0);
        event.setStatus(SOSEventStatus.TRIGGERED);
        event.setTriggeredAt(request.getTriggeredAt() != null ? request.getTriggeredAt() : LocalDateTime.now());
        event.setSyncedFromOffline(request.getSyncedFromOffline() != null && request.getSyncedFromOffline());
        event.setDeviceInfo(request.getDeviceInfo());

        SOSEvent saved = sosEventRepository.save(event);
        return mapToEventResponse(saved);
    }

    public Page<SOSEventResponse> getAllEvents(Pageable pageable) {
        return sosEventRepository.findAllByOrderByTriggeredAtDesc(pageable)
                .map(this::mapToEventResponse);
    }

    public Page<SOSEventResponse> getEventsByStatus(SOSEventStatus status, Pageable pageable) {
        return sosEventRepository.findByStatusOrderByTriggeredAtDesc(status, pageable)
                .map(this::mapToEventResponse);
    }

    public SOSEventResponse getEventById(UUID eventId) {
        SOSEvent event = sosEventRepository.findById(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Event not found"));
        return mapToEventResponse(event);
    }

    @Transactional
    public SOSEventResponse acknowledgeEvent(UUID eventId) {
        SOSEvent event = sosEventRepository.findById(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Event not found"));

        event.setStatus(SOSEventStatus.ACKNOWLEDGED);
        event.setAcknowledgedAt(LocalDateTime.now());

        SOSEvent saved = sosEventRepository.save(event);
        return mapToEventResponse(saved);
    }

    @Transactional
    public SOSEventResponse resolveEvent(UUID eventId, String adminId, ResolveSOSRequest request) {
        SOSEvent event = sosEventRepository.findById(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Event not found"));

        event.setStatus(SOSEventStatus.RESOLVED);
        event.setResolvedAt(LocalDateTime.now());
        event.setResolvedBy(adminId);
        event.setResolutionNotes(request != null ? request.getResolutionNotes() : null);

        SOSEvent saved = sosEventRepository.save(event);
        return mapToEventResponse(saved);
    }

    public SOSStatsResponse getStats() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startOfDay = now.with(LocalTime.MIN);
        LocalDateTime startOfWeek = now.minusDays(7);
        LocalDateTime startOfMonth = now.minusDays(30);

        SOSStatsResponse stats = new SOSStatsResponse();
        stats.setTotalEvents(sosEventRepository.count());
        stats.setActiveEvents(sosEventRepository.countByStatus(SOSEventStatus.TRIGGERED) +
                sosEventRepository.countByStatus(SOSEventStatus.ACKNOWLEDGED));
        stats.setResolvedEvents(sosEventRepository.countByStatus(SOSEventStatus.RESOLVED));
        stats.setEventsToday(sosEventRepository.countEventsSince(startOfDay));
        stats.setEventsThisWeek(sosEventRepository.countEventsSince(startOfWeek));
        stats.setEventsThisMonth(sosEventRepository.countEventsSince(startOfMonth));

        return stats;
    }

    public List<SOSEventResponse> getUserEvents(String userId) {
        return sosEventRepository.findByUserIdOrderByTriggeredAtDesc(userId)
                .stream()
                .map(this::mapToEventResponse)
                .collect(Collectors.toList());
    }

    private TrustedContactResponse mapToContactResponse(TrustedContact contact) {
        TrustedContactResponse response = new TrustedContactResponse();
        response.setId(contact.getId());
        response.setName(contact.getName());
        response.setPhone(contact.getPhone());
        response.setEmail(contact.getEmail());
        response.setRelationship(contact.getRelationship());
        response.setPriority(contact.getPriority());
        response.setIsActive(contact.getIsActive());
        return response;
    }

    private SOSEventResponse mapToEventResponse(SOSEvent event) {
        SOSEventResponse response = new SOSEventResponse();
        response.setId(event.getId());
        response.setUserId(event.getUserId());
        response.setUserName(event.getUserName());
        response.setUserPhone(event.getUserPhone());
        response.setLatitude(event.getLatitude());
        response.setLongitude(event.getLongitude());
        response.setAddress(event.getAddress());
        response.setMessage(event.getMessage());
        response.setContactsNotified(event.getContactsNotified());
        response.setStatus(event.getStatus());
        response.setTriggeredAt(event.getTriggeredAt());
        response.setAcknowledgedAt(event.getAcknowledgedAt());
        response.setResolvedAt(event.getResolvedAt());
        response.setResolvedBy(event.getResolvedBy());
        response.setResolutionNotes(event.getResolutionNotes());
        response.setSyncedFromOffline(event.getSyncedFromOffline());
        response.setMapsUrl("https://www.google.com/maps?q=" + event.getLatitude() + "," + event.getLongitude());
        return response;
    }
}
