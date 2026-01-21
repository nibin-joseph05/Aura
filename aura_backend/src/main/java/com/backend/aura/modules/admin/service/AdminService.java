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
import org.springframework.security.crypto.password.PasswordEncoder;
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
    private final PasswordEncoder passwordEncoder;

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
                .map(this::toProfileDTO);
    }

    public Optional<AdminProfileDTO> updateProfileName(String adminId, String name) {
        return adminRepository.findById(UUID.fromString(adminId))
                .map(admin -> {
                    if (name != null && !name.isBlank()) {
                        admin.setName(name);
                    }
                    Admin saved = adminRepository.save(admin);
                    return toProfileDTO(saved);
                });
    }

    public Optional<AdminProfileDTO> updateEmail(String adminId, String email) {
        return adminRepository.findById(UUID.fromString(adminId))
                .map(admin -> {
                    if (email != null && !email.isBlank()) {
                        admin.setEmail(email);
                    }
                    Admin saved = adminRepository.save(admin);
                    return toProfileDTO(saved);
                });
    }

    public boolean changePassword(String adminId, String currentPassword, String newPassword) {
        return adminRepository.findById(UUID.fromString(adminId))
                .map(admin -> {
                    if (passwordEncoder.matches(currentPassword, admin.getPassword())) {
                        admin.setPassword(passwordEncoder.encode(newPassword));
                        adminRepository.save(admin);
                        return true;
                    }
                    return false;
                })
                .orElse(false);
    }

    private AdminProfileDTO toProfileDTO(Admin admin) {
        return AdminProfileDTO.builder()
                .id(admin.getId().toString())
                .name(admin.getName())
                .email(admin.getEmail())
                .createdAt(admin.getCreatedAt().toString())
                .build();
    }
}
