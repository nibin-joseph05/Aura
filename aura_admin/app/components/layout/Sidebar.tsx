"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import Image from "next/image";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";
import { authStorage } from "@/app/modules/auth/services/auth-storage";

const menuItems = [
    { name: "Dashboard", icon: "📊", path: "/admin/dashboard" },
    { name: "Activity Types", icon: "📋", path: "/admin/activities" },
    { name: "Users", icon: "👥", path: "/admin/users" },
    { name: "Reports", icon: "📈", path: "/admin/reports" },
    { name: "Settings", icon: "⚙️", path: "/admin/settings" },
];

export default function Sidebar() {
    const pathname = usePathname();
    const { isDark } = useTheme();
    const [isOpen, setIsOpen] = useState(true);
    const [isMobile, setIsMobile] = useState(false);
    const user = authStorage.getUser();

    useEffect(() => {
        const checkIfMobile = () => {
            setIsMobile(window.innerWidth < 768);
            setIsOpen(window.innerWidth >= 768);
        };

        checkIfMobile();
        window.addEventListener("resize", checkIfMobile);

        return () => window.removeEventListener("resize", checkIfMobile);
    }, []);

    const toggleSidebar = () => setIsOpen(!isOpen);

    return (
        <>
            {isMobile && (
                <button
                    onClick={toggleSidebar}
                    className="fixed left-4 top-4 z-50 rounded-lg p-2 shadow-lg transition-all duration-300 hover:opacity-80"
                    style={{
                        backgroundColor: isDark ? appColors.cardBg : "white",
                        color: isDark ? "white" : "#1f2937",
                    }}
                >
                    <span className="text-xl">{isOpen ? "✕" : "☰"}</span>
                </button>
            )}

            <div
                className="fixed inset-y-0 z-40 transition-all duration-300"
                style={{
                    width: isOpen ? (isMobile ? "80%" : "260px") : "80px",
                    transform: isMobile && !isOpen ? "translateX(-100%)" : "translateX(0)",
                    backgroundColor: isDark ? appColors.splashDark : "white",
                    borderRight: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                    boxShadow: isOpen ? "4px 0 20px rgba(0,0,0,0.1)" : "none",
                }}
            >
                <div className="flex h-full flex-col">
                    <div
                        className="flex flex-col items-center justify-center space-y-3 p-5"
                        style={{ borderBottom: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}
                    >
                        <div className="relative h-16 w-16">
                            <Image
                                src="/logo/Aura-app-icon.png"
                                alt="Aura Logo"
                                width={64}
                                height={64}
                                className="rounded-full shadow-lg"
                                style={{ border: `2px solid ${appColors.accent}` }}
                            />
                        </div>

                        {isOpen && (
                            <div
                                className="text-lg font-bold"
                                style={{
                                    background: `linear-gradient(to right, ${appColors.accent}, ${appColors.primary})`,
                                    WebkitBackgroundClip: "text",
                                    WebkitTextFillColor: "transparent",
                                }}
                            >
                                Aura Admin
                            </div>
                        )}
                    </div>

                    <div className="flex-1 overflow-y-auto py-4">
                        <nav className="space-y-1 px-3">
                            {menuItems.map((item) => {
                                const isActive = pathname === item.path;
                                return (
                                    <Link key={item.path} href={item.path}>
                                        <div
                                            className="flex items-center space-x-3 rounded-xl p-3 transition-all duration-300"
                                            style={{
                                                backgroundColor: isActive
                                                    ? `${appColors.accent}20`
                                                    : "transparent",
                                                border: isActive
                                                    ? `1px solid ${appColors.accent}`
                                                    : "1px solid transparent",
                                            }}
                                        >
                                            <span className="text-xl">{item.icon}</span>
                                            {isOpen && (
                                                <span
                                                    className="font-medium"
                                                    style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                                                >
                                                    {item.name}
                                                </span>
                                            )}
                                        </div>
                                    </Link>
                                );
                            })}
                        </nav>
                    </div>

                    <div
                        className="p-4"
                        style={{ borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}
                    >
                        <div
                            className="flex items-center space-x-3 rounded-xl p-3"
                            style={{ backgroundColor: isDark ? appColors.cardBg : "#f3f4f6" }}
                        >
                            <div
                                className="rounded-full flex items-center justify-center text-white font-bold"
                                style={{
                                    backgroundColor: appColors.accent,
                                    width: 36,
                                    height: 36,
                                    fontSize: "0.875rem",
                                }}
                            >
                                {user?.name?.charAt(0).toUpperCase() || "A"}
                            </div>
                            {isOpen && (
                                <div className="overflow-hidden flex-1">
                                    <div
                                        className="font-medium truncate text-sm"
                                        style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                                    >
                                        {user?.name || "Admin"}
                                    </div>
                                    <div
                                        className="text-xs truncate"
                                        style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                                    >
                                        {user?.role || "ADMIN"}
                                    </div>
                                </div>
                            )}
                        </div>
                    </div>

                    {!isMobile && (
                        <button
                            onClick={toggleSidebar}
                            className="absolute -right-3 top-20 rounded-full p-1.5 shadow-lg transition-all duration-300 hover:scale-110"
                            style={{ backgroundColor: appColors.accent }}
                        >
                            <span className="text-white text-xs">
                                {isOpen ? "◀" : "▶"}
                            </span>
                        </button>
                    )}
                </div>
            </div>
        </>
    );
}
