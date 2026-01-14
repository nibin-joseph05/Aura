"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { adminAuthService } from "@/app/modules/auth/services/admin-auth.service";
import { authStorage } from "@/app/modules/auth/services/auth-storage";
import PageLoader from "@/app/components/loaders/PageLoader";
import DashboardHeader from "@/app/components/layout/DashboardHeader";
import { gradients, appColors } from "@/app/core/constants/colors";
import { AdminResponse } from "@/app/modules/auth/models/admin.model";

export default function AdminDashboardPage() {
    const router = useRouter();
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
            className="min-h-screen"
            style={{ background: gradients.primaryDiagonal }}
        >
            <DashboardHeader title="Admin Dashboard" />

            <main className="p-6">
                <div className="max-w-7xl mx-auto">
                    <div className="mb-8">
                        <h2 className="text-3xl font-bold text-white mb-2">
                            Welcome back, {user?.name || "Admin"}!
                        </h2>
                        <p className="text-gray-400">
                            Here&apos;s an overview of your platform.
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                        {[
                            { label: "Total Users", value: "0", icon: "👥", color: appColors.accent },
                            { label: "Active Today", value: "0", icon: "📊", color: appColors.success },
                            { label: "Activities Logged", value: "0", icon: "📝", color: appColors.warning },
                            { label: "SOS Alerts", value: "0", icon: "🚨", color: appColors.error },
                        ].map((stat, index) => (
                            <div
                                key={index}
                                className="p-6 rounded-xl transition-all duration-300 hover:-translate-y-1"
                                style={{
                                    backgroundColor: appColors.cardBg,
                                    border: `1px solid ${appColors.cardBorder}`,
                                }}
                            >
                                <div className="flex items-center justify-between mb-4">
                                    <span className="text-3xl">{stat.icon}</span>
                                    <span
                                        className="text-xs font-medium px-2 py-1 rounded-full"
                                        style={{ backgroundColor: `${stat.color}20`, color: stat.color }}
                                    >
                                        Live
                                    </span>
                                </div>
                                <p className="text-3xl font-bold text-white mb-1">{stat.value}</p>
                                <p className="text-sm text-gray-400">{stat.label}</p>
                            </div>
                        ))}
                    </div>

                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <div
                            className="p-6 rounded-xl"
                            style={{
                                backgroundColor: appColors.cardBg,
                                border: `1px solid ${appColors.cardBorder}`,
                            }}
                        >
                            <h3 className="text-xl font-bold text-white mb-4">Quick Actions</h3>
                            <div className="space-y-3">
                                {[
                                    { label: "Manage Activity Types", icon: "📋" },
                                    { label: "View User Reports", icon: "📈" },
                                    { label: "Emergency Settings", icon: "⚙️" },
                                    { label: "Send Notification", icon: "🔔" },
                                ].map((action, index) => (
                                    <button
                                        key={index}
                                        className="w-full flex items-center gap-3 p-3 rounded-lg text-left text-white transition-all duration-200 hover:bg-white/10"
                                    >
                                        <span className="text-xl">{action.icon}</span>
                                        <span>{action.label}</span>
                                    </button>
                                ))}
                            </div>
                        </div>

                        <div
                            className="p-6 rounded-xl"
                            style={{
                                backgroundColor: appColors.cardBg,
                                border: `1px solid ${appColors.cardBorder}`,
                            }}
                        >
                            <h3 className="text-xl font-bold text-white mb-4">Recent Activity</h3>
                            <div className="space-y-4">
                                <div className="flex items-center justify-center h-32 text-gray-500">
                                    <p>No recent activity to display</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
