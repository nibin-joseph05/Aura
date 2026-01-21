"use client";

import { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";
import { adminAuthService } from "@/app/modules/auth/services/admin-auth.service";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import PageLoader from "@/app/components/loaders/PageLoader";
import Sidebar from "@/app/components/layout/Sidebar";
import AdminHeader from "@/app/components/layout/AdminHeader";
import { appColors } from "@/app/core/constants/colors";

const pageTitles: Record<string, string> = {
    "/admin/dashboard": "Dashboard",
    "/admin/sos-events": "SOS Alerts",
    "/admin/wellness": "Wellness Feed",
    "/admin/categories": "Activity Categories",
    "/admin/activities": "Activity Types",
    "/admin/gym-exercises": "Gym Exercises",
    "/admin/users": "Users",
    "/admin/settings": "Settings",
};

export default function AdminLayout({ children }: { children: React.ReactNode }) {
    const router = useRouter();
    const pathname = usePathname();
    const { isDark } = useTheme();
    const [isLoading, setIsLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");

    useEffect(() => {
        const checkAuth = async () => {
            if (pathname === "/admin/login") {
                setIsLoading(false);
                return;
            }

            if (!adminAuthService.isAuthenticated()) {
                router.push("/admin/login");
                return;
            }

            const currentUser = await adminAuthService.getCurrentUser();
            if (!currentUser) {
                router.push("/admin/login");
                return;
            }

            setIsLoading(false);
        };

        checkAuth();
    }, [router, pathname]);

    if (pathname === "/admin/login") {
        return <>{children}</>;
    }

    if (isLoading) {
        return <PageLoader message="Loading..." />;
    }

    const title = pageTitles[pathname] || "Admin Panel";

    return (
        <div
            className="min-h-screen transition-colors duration-500"
            style={{ backgroundColor: isDark ? appColors.splashDark : "#f0f4f8" }}
        >
            <Sidebar />

            <div className="ml-0 transition-all duration-300 md:ml-[80px] lg:ml-[260px]">
                <div
                    className="sticky top-0 z-30 p-4 md:p-6"
                    style={{ backgroundColor: isDark ? appColors.splashDark : "#f0f4f8" }}
                >
                    <AdminHeader title={title} onSearch={setSearchQuery} />
                </div>

                <main className="p-4 pt-0 md:p-6 md:pt-0">
                    <div className="mx-auto max-w-7xl">
                        {children}
                    </div>
                </main>
            </div>
        </div>
    );
}
