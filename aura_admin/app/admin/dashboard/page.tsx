"use client";

import { useEffect, useState } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";
import { authStorage } from "@/app/modules/auth/services/auth-storage";
import { apiClient } from "@/app/core/network/api-client";

interface DashboardStats {
    totalUsers: number;
    activeToday: number;
    activitiesLogged: number;
    sosAlerts: number;
    wellnessCheckins: number;
    dailyGoals: number;
    socialConnections: number;
    safetyContacts: number;
}

interface StatCardProps {
    title: string;
    value: string | number;
    icon: string;
    color: string;
    description?: string;
    isDark: boolean;
}

function StatCard({ title, value, icon, color, description, isDark }: StatCardProps) {
    return (
        <div
            className="rounded-xl p-6 shadow-lg transition-all duration-300 hover:-translate-y-1"
            style={{
                backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                border: `1px solid ${color}`,
            }}
        >
            <div className="flex items-center justify-between">
                <div className="flex-1">
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="mb-2 text-sm">
                        {title}
                    </p>
                    <h3
                        className="text-2xl font-bold"
                        style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                    >
                        {value}
                    </h3>
                    {description && (
                        <p style={{ color: isDark ? "#6b7280" : "#9ca3af" }} className="text-xs mt-1">
                            {description}
                        </p>
                    )}
                </div>
                <div className="text-3xl">{icon}</div>
            </div>
        </div>
    );
}

export default function AdminDashboardPage() {
    const { isDark } = useTheme();
    const user = authStorage.getUser();
    const [stats, setStats] = useState<DashboardStats>({
        totalUsers: 0,
        activeToday: 0,
        activitiesLogged: 0,
        sosAlerts: 0,
        wellnessCheckins: 0,
        dailyGoals: 0,
        socialConnections: 0,
        safetyContacts: 0,
    });
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchStats();
    }, []);

    const fetchStats = async () => {
        try {
            const response = await apiClient.get<DashboardStats>("/api/admin/stats");
            if (response.success && response.data) {
                setStats(response.data);
            }
        } catch (error) {
            console.error("Failed to fetch stats:", error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6">
            <div className="mb-6">
                <h2
                    className="text-2xl font-bold mb-2"
                    style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                >
                    Welcome back, {user?.name || "Admin"}!
                </h2>
                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                    Here&apos;s an overview of your platform.
                </p>
            </div>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4 mb-8">
                <StatCard
                    title="Total Users"
                    value={loading ? "..." : stats.totalUsers}
                    icon="👥"
                    color={appColors.accent}
                    description="Registered users"
                    isDark={isDark}
                />
                <StatCard
                    title="Active Today"
                    value={loading ? "..." : stats.activeToday}
                    icon="📊"
                    color={appColors.success}
                    description="Daily active users"
                    isDark={isDark}
                />
                <StatCard
                    title="Activities Logged"
                    value={loading ? "..." : stats.activitiesLogged}
                    icon="📝"
                    color={appColors.warning}
                    description="Today's activities"
                    isDark={isDark}
                />
                <StatCard
                    title="SOS Alerts"
                    value={loading ? "..." : stats.sosAlerts}
                    icon="🚨"
                    color={appColors.error}
                    description="Active alerts"
                    isDark={isDark}
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div
                    className="rounded-xl p-6 shadow-xl"
                    style={{
                        backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                    }}
                >
                    <h3
                        className="text-xl font-bold mb-4 flex items-center gap-2"
                        style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                    >
                        ⚡ Quick Actions
                    </h3>
                    <div className="space-y-3">
                        {[
                            { label: "Manage Activity Types", icon: "📋", path: "/admin/activities" },
                            { label: "View SOS Alerts", icon: "🚨", path: "/admin/sos-events" },
                            { label: "Moderate Wellness Feed", icon: "✨", path: "/admin/wellness" },
                            { label: "Manage Users", icon: "👥", path: "/admin/users" },
                        ].map((action, index) => (
                            <a
                                key={index}
                                href={action.path}
                                className="w-full flex items-center gap-3 p-3 rounded-lg text-left transition-all duration-200 hover:opacity-80"
                                style={{
                                    color: isDark ? "#f3f4f6" : "#374151",
                                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                                    backgroundColor: "transparent",
                                }}
                            >
                                <span className="text-xl">{action.icon}</span>
                                <span>{action.label}</span>
                                <span className="ml-auto" style={{ color: isDark ? "#6b7280" : "#9ca3af" }}>→</span>
                            </a>
                        ))}
                    </div>
                </div>

                <div
                    className="rounded-xl p-6 shadow-xl"
                    style={{
                        backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                    }}
                >
                    <h3
                        className="text-xl font-bold mb-4 flex items-center gap-2"
                        style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                    >
                        📊 Platform Statistics
                    </h3>
                    <div className="grid grid-cols-2 gap-4">
                        {[
                            { label: "Wellness Check-ins", value: stats.wellnessCheckins, icon: "🧘" },
                            { label: "Daily Goals Set", value: stats.dailyGoals, icon: "🎯" },
                            { label: "Social Connections", value: stats.socialConnections, icon: "🤝" },
                            { label: "Safety Contacts", value: stats.safetyContacts, icon: "🛡️" },
                        ].map((stat, index) => (
                            <div
                                key={index}
                                className="text-center p-4 rounded-lg"
                                style={{ backgroundColor: `${appColors.accent}15` }}
                            >
                                <span className="text-2xl block mb-2">{stat.icon}</span>
                                <p
                                    className="text-2xl font-bold"
                                    style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                                >
                                    {loading ? "..." : stat.value}
                                </p>
                                <p
                                    className="text-xs"
                                    style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                                >
                                    {stat.label}
                                </p>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}
