"use client";

import { ButtonHTMLAttributes, ReactNode } from "react";
import { appColors } from "@/app/core/constants/colors";
import { useTheme } from "@/app/core/providers/ThemeProvider";

type ButtonVariant = "primary" | "secondary" | "outline" | "danger";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: ButtonVariant;
    isLoading?: boolean;
    fullWidth?: boolean;
    children: ReactNode;
}

export default function Button({
    variant = "primary",
    isLoading = false,
    fullWidth = false,
    children,
    className = "",
    disabled,
    ...props
}: ButtonProps) {
    const { isDark } = useTheme();

    const getStyles = () => {
        switch (variant) {
            case "primary":
                return {
                    background: `linear-gradient(to right, ${appColors.accent}, ${appColors.primary})`,
                    color: "white",
                    border: "none",
                };
            case "secondary":
                return {
                    background: isDark ? appColors.cardBg : "#f3f4f6",
                    color: isDark ? "#f3f4f6" : "#374151",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}`,
                };
            case "outline":
                return {
                    background: "transparent",
                    color: appColors.accent,
                    border: `1px solid ${appColors.accent}`,
                };
            case "danger":
                return {
                    background: appColors.error,
                    color: "white",
                    border: "none",
                };
            default:
                return {
                    background: appColors.primary,
                    color: "white",
                    border: "none",
                };
        }
    };

    const styles = getStyles();

    return (
        <button
            {...props}
            disabled={disabled || isLoading}
            className={`relative flex items-center justify-center py-3 px-6 text-sm font-medium rounded-lg transition-all duration-300 ease-in-out transform hover:-translate-y-1 focus:outline-none focus:ring-2 focus:ring-offset-2 ${fullWidth ? "w-full" : ""
                } ${disabled || isLoading ? "opacity-75 cursor-not-allowed" : "shadow-lg hover:shadow-xl"} ${className}`}
            style={{
                background: styles.background,
                color: styles.color,
                border: styles.border,
            }}
        >
            {isLoading ? (
                <>
                    <svg
                        className="animate-spin -ml-1 mr-3 h-5 w-5"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                    >
                        <circle
                            className="opacity-25"
                            cx="12"
                            cy="12"
                            r="10"
                            stroke="currentColor"
                            strokeWidth="4"
                        ></circle>
                        <path
                            className="opacity-75"
                            fill="currentColor"
                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                        ></path>
                    </svg>
                    Loading...
                </>
            ) : (
                children
            )}
        </button>
    );
}
