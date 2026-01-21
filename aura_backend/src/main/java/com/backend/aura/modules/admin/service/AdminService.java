package com.backend.aura.modules.admin.service;

import com.backend.aura.modules.admin.dto.AdminProfileDTO;
import com.backend.aura.modules.admin.dto.AdminStatsDTO;
import com.backend.aura.modules.admin.model.Admin;
import com.backend.aura.modules.admin.repository.AdminRepository;
import com.backend.aura.modules.sos.repository.SOSEventRepository;
import com.backend.aura.modules.sos.model.enums.SOSEventStatus;
import com.backend.aura.modules.user.repository.UserRepository;
import com.backend.aura.modules.wellness.repository.WellnessUpdateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final AdminRepository adminRepository;
    private final UserRepository userRepository;
    private final SOSEventRepository sosEventRepository;
    private final WellnessUpdateRepository wellnessUpdateRepository;

    public AdminStatsDTO getDashboardStats() {
        LocalDateTime todayStart = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);

        long totalUsers = userRepository.count();
        long activeToday = userRepository.countByLastLoginAtAfter(todayStart);
        long sosAlerts = sosEventRepository
                .countByStatusIn(List.of(SOSEventStatus.TRIGGERED, SOSEventStatus.ACKNOWLEDGED));
        long wellnessCheckins = wellnessUpdateRepository.count();

        return AdminStatsDTO.builder()
                .totalUsers(totalUsers)
                .activeToday(activeToday)
                .activitiesLogged(0)
                .sosAlerts(sosAlerts)
                .wellnessCheckins(wellnessCheckins)
                .dailyGoals(0)
                .socialConnections(0)
                .safetyContacts(0)
                .build();
    }

    public Optional<AdminProfileDTO> getProfile(String adminId) {
        return adminRepository.findById(UUID.fromString(adminId))
                .map(admin -> AdminProfileDTO.builder()
                        .id(admin.getId().toString())
                        .name(admin.getName())
                        .email(admin.getEmail())
                        .createdAt(admin.getCreatedAt().toString())
                        .build());
    }

    public Optional<AdminProfileDTO> updateProfile(String adminId, String name, String email) {
        return adminRepository.findById(UUID.fromString(adminId))
                .map(admin -> {
                    if (name != null && !name.isBlank()) {
                        admin.setName(name);
                    }
                    if (email != null && !email.isBlank()) {
                        admin.setEmail(email);
                    }
                    Admin saved = adminRepository.save(admin);
                    return AdminProfileDTO.builder()
                            .id(saved.getId().toString())
                            .name(saved.getName())
                            .email(saved.getEmail())
                            .createdAt(saved.getCreatedAt().toString())
                            .build();
                });
    }
}
