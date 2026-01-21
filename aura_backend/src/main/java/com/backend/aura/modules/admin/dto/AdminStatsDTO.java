package com.backend.aura.modules.admin.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminStatsDTO {
    private long totalUsers;
    private long activeToday;
    private long activitiesLogged;
    private long sosAlerts;
    private long wellnessCheckins;
    private long dailyGoals;
    private long socialConnections;
    private long safetyContacts;
}
