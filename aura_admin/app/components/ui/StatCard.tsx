"use client";

import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";

interface StatCardProps {
    title: string;
    value: string | number;
    icon?: string;
    color?: string;
    description?: string;
    trend?: {
        value: number;
        isPositive: boolean;
    };
}

export default function StatCard({
    title,
    value,
    icon,
    color = appColors.accent,
    description,
    trend,
}: StatCardProps) {
    const { isDark } = useTheme();

    return (
        <div
            className="rounded-xl p-5 transition-all hover:scale-[1.02]"
            style={{
                backgroundColor: isDark ? appColors.cardBg : "white",
                border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                boxShadow: isDark ? "none" : "0 1px 3px rgba(0,0,0,0.1)",
            }}
        >
            <div className="flex items-start justify-between mb-3">
                <div
                    className="w-10 h-10 rounded-lg flex items-center justify-center text-xl"
                    style={{ backgroundColor: `${color}20` }}
                >
                    {icon || "📊"}
                </div>
                {trend && (
                    <span
                        className="text-xs font-medium px-2 py-1 rounded-full"
                        style={{
                            backgroundColor: trend.isPositive ? "rgba(34, 197, 94, 0.1)" : "rgba(239, 68, 68, 0.1)",
                            color: trend.isPositive ? "#22c55e" : "#ef4444",
                        }}
                    >
                        {trend.isPositive ? "↑" : "↓"} {Math.abs(trend.value)}%
                    </span>
                )}
            </div>
            <p
                className="text-2xl font-bold mb-1"
                style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
            >
                {value}
            </p>
            <p
                className="text-sm"
                style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
            >
                {title}
            </p>
            {description && (
                <p
                    className="text-xs mt-2"
                    style={{ color: isDark ? "#6b7280" : "#9ca3af" }}
                >
                    {description}
                </p>
            )}
        </div>
    );
}
