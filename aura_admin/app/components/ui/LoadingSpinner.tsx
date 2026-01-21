"use client";

import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";

interface LoadingSpinnerProps {
    size?: "sm" | "md" | "lg";
    message?: string;
}

export default function LoadingSpinner({
    size = "md",
    message,
}: LoadingSpinnerProps) {
    const { isDark } = useTheme();

    const sizeClasses = {
        sm: "w-6 h-6",
        md: "w-10 h-10",
        lg: "w-16 h-16",
    };

    return (
        <div className="flex flex-col items-center justify-center p-8">
            <div
                className={`${sizeClasses[size]} rounded-full border-4 animate-spin`}
                style={{
                    borderColor: isDark ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.1)",
                    borderTopColor: appColors.accent,
                }}
            />
            {message && (
                <p
                    className="mt-4 text-sm"
                    style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                >
                    {message}
                </p>
            )}
        </div>
    );
}
