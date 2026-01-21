"use client";

import { ReactNode } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";

interface EmptyStateProps {
    title: string;
    description?: string;
    icon?: ReactNode;
    action?: {
        label: string;
        onClick: () => void;
    };
}

export default function EmptyState({
    title,
    description,
    icon,
    action,
}: EmptyStateProps) {
    const { isDark } = useTheme();

    return (
        <div className="flex flex-col items-center justify-center p-12 text-center">
            <div className="text-5xl mb-4 opacity-50">
                {icon || "📭"}
            </div>
            <h3
                className="text-lg font-semibold mb-2"
                style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
            >
                {title}
            </h3>
            {description && (
                <p
                    className="text-sm mb-6 max-w-sm"
                    style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                >
                    {description}
                </p>
            )}
            {action && (
                <button
                    onClick={action.onClick}
                    className="px-6 py-2 rounded-lg text-sm font-medium text-white transition-all hover:opacity-90"
                    style={{
                        background: "linear-gradient(to right, #2196F3, #00BCD4)",
                    }}
                >
                    {action.label}
                </button>
            )}
        </div>
    );
}
