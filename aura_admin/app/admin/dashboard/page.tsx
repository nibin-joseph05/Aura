"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { adminAuthService } from "@/app/modules/auth/services/admin-auth.service";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import PageLoader from "@/app/components/loaders/PageLoader";
import Sidebar from "@/app/components/layout/Sidebar";
import AdminHeader from "@/app/components/layout/AdminHeader";
import { appColors } from "@/app/core/constants/colors";
import { AdminResponse } from "@/app/modules/auth/models/admin.model";

interface StatCardProps {
    title: string;
    value: string | number;
    icon: string;
    color: string;
    description?: string;
}

function StatCard({ title, value, icon, color, description }: StatCardProps) {
    const { isDark } = useTheme();

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
                        style={{ color: isDark ? "white" : "#1f2937" }}
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
    const router = useRouter();
    const { isDark } = useTheme();
    const [isLoading, setIsLoading] = useState(true);
    const [user, setUser] = useState<AdminResponse | null>(null);

    useEffect(() => {
        const checkAuth = async () => {
            if (!adminAuthService.isAuthenticated()) {
                router.push("/admin/login");
                return;
            }

            const currentUser = await adminAuthService.getCurrentUser();
            if (!currentUser) {
                router.push("/admin/login");
                return;
            }

            setUser(currentUser);
            setIsLoading(false);
        };

        checkAuth();
    }, [router]);

    if (isLoading) {
        return <PageLoader message="Loading dashboard..." />;
    }

    return (
        <div
            className="min-h-screen transition-colors duration-500"
            style={{
                backgroundColor: isDark ? appColors.splashDark : "#f0f4f8",
            }}
        >
            <Sidebar />

            <div className="ml-0 transition-all duration-300 md:ml-[80px] lg:ml-[260px]">
                <div
                    className="sticky top-0 z-30 p-4 md:p-6"
                    style={{
                        backgroundColor: isDark ? appColors.splashDark : "#f0f4f8",
                    }}
                >
                    <AdminHeader title="Admin Dashboard" />
                </div>

                <main className="p-4 pt-0 md:p-6 md:pt-0">
                    <div className="mx-auto max-w-7xl">
                        <div className="mb-6">
                            <h2
                                className="text-2xl font-bold mb-2"
                                style={{ color: isDark ? "white" : "#1f2937" }}
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
                                value="0"
                                icon="👥"
                                color={appColors.accent}
                                description="Registered users"
                            />
                            <StatCard
                                title="Active Today"
                                value="0"
                                icon="📊"
                                color={appColors.success}
                                description="Daily active users"
                            />
                            <StatCard
                                title="Activities Logged"
                                value="0"
                                icon="📝"
                                color={appColors.warning}
                                description="Today's activities"
                            />
                            <StatCard
                                title="SOS Alerts"
                                value="0"
                                icon="🚨"
                                color={appColors.error}
                                description="Emergency alerts"
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
                                    style={{ color: isDark ? "white" : "#1f2937" }}
                                >
                                    ⚡ Quick Actions
                                </h3>
                                <div className="space-y-3">
                                    {[
                                        { label: "Manage Activity Types", icon: "📋", path: "/admin/activities" },
                                        { label: "View User Reports", icon: "📈", path: "/admin/reports" },
                                        { label: "Emergency Settings", icon: "⚙️", path: "/admin/settings" },
                                        { label: "Manage Users", icon: "👥", path: "/admin/users" },
                                    ].map((action, index) => (
                                        <button
                                            key={index}
                                            onClick={() => router.push(action.path)}
                                            className="w-full flex items-center gap-3 p-3 rounded-lg text-left transition-all duration-200"
                                            style={{
                                                color: isDark ? "white" : "#374151",
                                                border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                                                backgroundColor: "transparent",
                                            }}
                                            onMouseEnter={(e) => {
                                                e.currentTarget.style.backgroundColor = isDark ? "rgba(255,255,255,0.1)" : "#f3f4f6";
                                            }}
                                            onMouseLeave={(e) => {
                                                e.currentTarget.style.backgroundColor = "transparent";
                                            }}
                                        >
                                            <span className="text-xl">{action.icon}</span>
                                            <span>{action.label}</span>
                                            <span className="ml-auto" style={{ color: isDark ? "#6b7280" : "#9ca3af" }}>→</span>
                                        </button>
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
                                    style={{ color: isDark ? "white" : "#1f2937" }}
                                >
                                    🕒 Recent Activity
                                </h3>
                                <div className="flex items-center justify-center h-32">
                                    <div className="text-center" style={{ color: isDark ? "#6b7280" : "#9ca3af" }}>
                                        <span className="text-4xl block mb-2">📭</span>
                                        <p>No recent activity to display</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div
                            className="mt-6 rounded-xl p-6 shadow-xl"
                            style={{
                                backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                                border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                            }}
                        >
                            <h3
                                className="text-xl font-bold mb-4 flex items-center gap-2"
                                style={{ color: isDark ? "white" : "#1f2937" }}
                            >
                                📊 Platform Statistics
                            </h3>
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                {[
                                    { label: "Wellness Check-ins", value: "0", icon: "🧘" },
                                    { label: "Daily Goals Set", value: "0", icon: "🎯" },
                                    { label: "Social Connections", value: "0", icon: "🤝" },
                                    { label: "Safety Contacts", value: "0", icon: "🛡️" },
                                ].map((stat, index) => (
                                    <div
                                        key={index}
                                        className="text-center p-4 rounded-lg"
                                        style={{ backgroundColor: `${appColors.accent}15` }}
                                    >
                                        <span className="text-2xl block mb-2">{stat.icon}</span>
                                        <p
                                            className="text-2xl font-bold"
                                            style={{ color: isDark ? "white" : "#1f2937" }}
                                        >
                                            {stat.value}
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
                </main>
            </div>
        </div>
    );
}
