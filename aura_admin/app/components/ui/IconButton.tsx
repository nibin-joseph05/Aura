"use client";

import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";

interface IconButtonProps {
    icon: string;
    label?: string;
    onClick?: () => void;
    variant?: "default" | "danger" | "success" | "warning";
    className?: string;
}

export default function IconButton({
    icon,
    label,
    onClick,
    variant = "default",
    className = "",
}: IconButtonProps) {
    const { isDark } = useTheme();

    const getVariantStyles = () => {
        switch (variant) {
            case "danger":
                return { backgroundColor: appColors.error, color: "white" };
            case "success":
                return { backgroundColor: appColors.success, color: "white" };
            case "warning":
                return { backgroundColor: appColors.warning, color: "white" };
            default:
                return {
                    backgroundColor: isDark ? appColors.cardBg : "#e5e7eb",
                    color: isDark ? "white" : "#374151",
                };
        }
    };

    return (
        <button
            onClick={onClick}
            className={`rounded-full px-3 py-2 text-sm font-medium shadow-md transition-all duration-300 hover:opacity-80 flex items-center gap-2 ${className}`}
            style={getVariantStyles()}
        >
            <span>{icon}</span>
            {label && <span>{label}</span>}
        </button>
    );
}
