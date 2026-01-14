"use client";

import { useRouter } from "next/navigation";
import { adminAuthService } from "@/app/modules/auth/services/admin-auth.service";
import { authStorage } from "@/app/modules/auth/services/auth-storage";
import { useToast } from "@/app/components/ui/Toast";
import Button from "@/app/components/ui/Button";
import { appColors } from "@/app/core/constants/colors";

interface DashboardHeaderProps {
    title?: string;
}

export default function DashboardHeader({ title = "Dashboard" }: DashboardHeaderProps) {
    const router = useRouter();
    const { showToast } = useToast();
    const user = authStorage.getUser();

    const handleLogout = () => {
        adminAuthService.logout();
        showToast("Logged out successfully", "success");
        router.push("/admin/login");
    };

    return (
        <header
            className="flex items-center justify-between px-6 py-4 shadow-lg"
            style={{
                backgroundColor: appColors.cardBg,
                borderBottom: `1px solid ${appColors.cardBorder}`,
            }}
        >
            <div className="flex items-center gap-4">
                <h1
                    className="text-2xl font-bold"
                    style={{
                        background: `linear-gradient(to right, ${appColors.accent}, ${appColors.primary})`,
                        WebkitBackgroundClip: "text",
                        WebkitTextFillColor: "transparent",
                    }}
                >
                    {title}
                </h1>
            </div>

            <div className="flex items-center gap-4">
                {user && (
                    <div className="flex items-center gap-3">
                        <div className="text-right hidden sm:block">
                            <p className="text-sm font-medium text-white">{user.name}</p>
                            <p className="text-xs text-gray-400">{user.role}</p>
                        </div>
                        <div
                            className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold"
                            style={{ backgroundColor: appColors.accent }}
                        >
                            {user.name?.charAt(0).toUpperCase() || "A"}
                        </div>
                    </div>
                )}
                <Button variant="outline" onClick={handleLogout}>
                    Logout
                </Button>
            </div>
        </header>
    );
}
