"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { adminAuthService } from "@/app/modules/auth/services/admin-auth.service";
import { useToast } from "@/app/components/ui/Toast";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import Button from "@/app/components/ui/Button";
import SearchBar from "@/app/components/ui/SearchBar";
import { appColors } from "@/app/core/constants/colors";

interface AdminHeaderProps {
    title?: string;
    showSearch?: boolean;
    onSearch?: (query: string) => void;
}

export default function AdminHeader({
    title = "Dashboard",
    showSearch = true,
    onSearch
}: AdminHeaderProps) {
    const router = useRouter();
    const { showToast } = useToast();
    const { theme, toggleTheme, isDark } = useTheme();
    const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);
    const [searchQuery, setSearchQuery] = useState("");

    const handleSearch = (value: string) => {
        setSearchQuery(value);
        if (onSearch) {
            onSearch(value);
        }
    };

    const handleLogout = () => {
        adminAuthService.logout();
        showToast("Logged out successfully", "success");
        router.push("/admin/login");
        setShowLogoutConfirm(false);
    };

    return (
        <>
            <div
                className="flex items-center justify-between rounded-xl p-4 shadow-xl backdrop-blur-md transition-colors duration-300"
                style={{
                    backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                }}
            >
                <h1
                    className="text-2xl md:text-3xl font-bold"
                    style={{
                        background: `linear-gradient(to right, ${appColors.accent}, ${appColors.primary})`,
                        WebkitBackgroundClip: "text",
                        WebkitTextFillColor: "transparent",
                    }}
                >
                    {title}
                </h1>

                {showSearch && (
                    <div className="ml-4 flex-1 max-w-sm hidden md:block">
                        <SearchBar
                            value={searchQuery}
                            onChange={handleSearch}
                            placeholder="Search..."
                        />
                    </div>
                )}

                <div className="flex items-center space-x-3 ml-4">
                    <button
                        onClick={toggleTheme}
                        className="rounded-full px-4 py-2 text-sm font-medium shadow-md transition-all duration-300 hover:scale-105"
                        style={{
                            backgroundColor: isDark ? appColors.primary : appColors.splashDark,
                            color: "white",
                        }}
                    >
                        {isDark ? "☀️ Light" : "🌙 Dark"}
                    </button>
                    <Button
                        variant="danger"
                        onClick={() => setShowLogoutConfirm(true)}
                    >
                        Logout
                    </Button>
                </div>
            </div>

            {showLogoutConfirm && (
                <div
                    className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
                    onClick={() => setShowLogoutConfirm(false)}
                >
                    <div
                        className="rounded-xl p-8 shadow-2xl text-center max-w-sm mx-auto animate-fade-in"
                        style={{
                            backgroundColor: isDark ? appColors.splashDark : "white",
                            border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                        }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        <span className="text-4xl block mb-4">👋</span>
                        <h3
                            className="text-xl font-bold mb-2"
                            style={{ color: isDark ? "white" : "#1f2937" }}
                        >
                            Confirm Logout
                        </h3>
                        <p
                            className="mb-6"
                            style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                        >
                            Are you sure you want to end your session?
                        </p>
                        <div className="flex justify-center space-x-4">
                            <Button variant="danger" onClick={handleLogout}>
                                Yes, Logout
                            </Button>
                            <Button
                                variant="secondary"
                                onClick={() => setShowLogoutConfirm(false)}
                            >
                                Cancel
                            </Button>
                        </div>
                    </div>
                </div>
            )}
        </>
    );
}
