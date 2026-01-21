"use client";

import { ReactNode } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";

interface ErrorMessageProps {
    title?: string;
    message: string;
    onRetry?: () => void;
    icon?: ReactNode;
}

export default function ErrorMessage({
    title = "Something went wrong",
    message,
    onRetry,
    icon,
}: ErrorMessageProps) {
    const { isDark } = useTheme();

    return (
        <div
            className="flex flex-col items-center justify-center p-8 rounded-xl text-center"
            style={{
                backgroundColor: isDark ? "rgba(239, 68, 68, 0.1)" : "rgba(239, 68, 68, 0.05)",
                border: `1px solid ${isDark ? "rgba(239, 68, 68, 0.3)" : "rgba(239, 68, 68, 0.2)"}`,
            }}
        >
            <div className="text-4xl mb-4">
                {icon || "❌"}
            </div>
            <h3
                className="text-lg font-semibold mb-2"
                style={{ color: isDark ? "#FCA5A5" : "#DC2626" }}
            >
                {title}
            </h3>
            <p
                className="text-sm mb-4"
                style={{ color: isDark ? "#F87171" : "#EF4444" }}
            >
                {message}
            </p>
            {onRetry && (
                <button
                    onClick={onRetry}
                    className="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                    style={{
                        backgroundColor: isDark ? "rgba(239, 68, 68, 0.2)" : "rgba(239, 68, 68, 0.1)",
                        color: isDark ? "#FCA5A5" : "#DC2626",
                        border: `1px solid ${isDark ? "rgba(239, 68, 68, 0.4)" : "rgba(239, 68, 68, 0.3)"}`,
                    }}
                >
                    Try Again
                </button>
            )}
        </div>
    );
}
