"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { adminAuthService } from "@/app/modules/auth/services/admin-auth.service";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import PageLoader from "@/app/components/loaders/PageLoader";
import Sidebar from "@/app/components/layout/Sidebar";
import AdminHeader from "@/app/components/layout/AdminHeader";
import Button from "@/app/components/ui/Button";
import { appColors } from "@/app/core/constants/colors";

interface ActivityType {
    id: string;
    name: string;
    description: string;
    icon: string;
    isActive: boolean;
}

const mockActivityTypes: ActivityType[] = [
    { id: "1", name: "Wellness Check-in", description: "Daily mood and wellness tracking", icon: "🧘", isActive: true },
    { id: "2", name: "Exercise", description: "Physical activity logging", icon: "🏃", isActive: true },
    { id: "3", name: "Sleep Tracking", description: "Monitor sleep patterns", icon: "😴", isActive: true },
    { id: "4", name: "Medication Reminder", description: "Track medication intake", icon: "💊", isActive: true },
    { id: "5", name: "Social Activity", description: "Social engagement tracking", icon: "👥", isActive: true },
    { id: "6", name: "Mindfulness", description: "Meditation and mindfulness sessions", icon: "🧠", isActive: false },
];

export default function ActivityTypesPage() {
    const router = useRouter();
    const { isDark } = useTheme();
    const [isLoading, setIsLoading] = useState(true);
    const [activityTypes, setActivityTypes] = useState<ActivityType[]>([]);
    const [searchQuery, setSearchQuery] = useState("");

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

            setActivityTypes(mockActivityTypes);
            setIsLoading(false);
        };

        checkAuth();
    }, [router]);

    const filteredTypes = activityTypes.filter(type =>
        type.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        type.description.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const toggleActivityStatus = (id: string) => {
        setActivityTypes(prev =>
            prev.map(type =>
                type.id === id ? { ...type, isActive: !type.isActive } : type
            )
        );
    };

    if (isLoading) {
        return <PageLoader message="Loading activity types..." />;
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
                    <AdminHeader
                        title="Activity Types"
                        onSearch={setSearchQuery}
                    />
                </div>

                <main className="p-4 pt-0 md:p-6 md:pt-0">
                    <div className="mx-auto max-w-7xl">
                        <div className="flex items-center justify-between mb-6">
                            <div>
                                <h2
                                    className="text-xl font-bold"
                                    style={{ color: isDark ? "white" : "#1f2937" }}
                                >
                                    Manage Activity Types
                                </h2>
                                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                    Configure and manage activity types for users
                                </p>
                            </div>
                            <Button variant="primary">
                                + Add New
                            </Button>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                            {filteredTypes.map((type) => (
                                <div
                                    key={type.id}
                                    className="rounded-xl p-5 shadow-lg transition-all duration-300 hover:-translate-y-1"
                                    style={{
                                        backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                                        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                                    }}
                                >
                                    <div className="flex items-start justify-between mb-3">
                                        <div className="flex items-center gap-3">
                                            <span className="text-3xl">{type.icon}</span>
                                            <div>
                                                <h3
                                                    className="font-bold"
                                                    style={{ color: isDark ? "white" : "#1f2937" }}
                                                >
                                                    {type.name}
                                                </h3>
                                                <p
                                                    className="text-sm"
                                                    style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                                                >
                                                    {type.description}
                                                </p>
                                            </div>
                                        </div>
                                    </div>

                                    <div className="flex items-center justify-between pt-3"
                                        style={{ borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}
                                    >
                                        <div className="flex items-center gap-2">
                                            <button
                                                onClick={() => toggleActivityStatus(type.id)}
                                                className="relative inline-flex h-6 w-11 items-center rounded-full transition-colors duration-200"
                                                style={{
                                                    backgroundColor: type.isActive ? appColors.success : (isDark ? "#4b5563" : "#d1d5db"),
                                                }}
                                            >
                                                <span
                                                    className="inline-block h-4 w-4 transform rounded-full bg-white transition-transform duration-200"
                                                    style={{
                                                        transform: type.isActive ? "translateX(1.375rem)" : "translateX(0.25rem)",
                                                    }}
                                                />
                                            </button>
                                            <span
                                                className="text-sm"
                                                style={{ color: type.isActive ? appColors.success : (isDark ? "#9ca3af" : "#6b7280") }}
                                            >
                                                {type.isActive ? "Active" : "Inactive"}
                                            </span>
                                        </div>

                                        <div className="flex gap-2">
                                            <button
                                                className="p-2 rounded-lg transition-colors duration-200"
                                                style={{
                                                    color: isDark ? "#9ca3af" : "#6b7280",
                                                }}
                                                onMouseEnter={(e) => {
                                                    e.currentTarget.style.backgroundColor = isDark ? "rgba(255,255,255,0.1)" : "#f3f4f6";
                                                }}
                                                onMouseLeave={(e) => {
                                                    e.currentTarget.style.backgroundColor = "transparent";
                                                }}
                                            >
                                                ✏️
                                            </button>
                                            <button
                                                className="p-2 rounded-lg transition-colors duration-200"
                                                style={{
                                                    color: appColors.error,
                                                }}
                                                onMouseEnter={(e) => {
                                                    e.currentTarget.style.backgroundColor = isDark ? "rgba(255,255,255,0.1)" : "#f3f4f6";
                                                }}
                                                onMouseLeave={(e) => {
                                                    e.currentTarget.style.backgroundColor = "transparent";
                                                }}
                                            >
                                                🗑️
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>

                        {filteredTypes.length === 0 && (
                            <div
                                className="text-center py-12"
                                style={{ color: isDark ? "#6b7280" : "#9ca3af" }}
                            >
                                <span className="text-4xl block mb-4">🔍</span>
                                <p>No activity types found matching your search.</p>
                            </div>
                        )}
                    </div>
                </main>
            </div>
        </div>
    );
}
