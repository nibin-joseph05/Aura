"use client";

import { useState } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";

interface SearchBarProps {
    placeholder?: string;
    value?: string;
    onChange?: (value: string) => void;
    className?: string;
}

export default function SearchBar({
    placeholder = "Search...",
    value,
    onChange,
    className = "",
}: SearchBarProps) {
    const { isDark } = useTheme();
    const [internalValue, setInternalValue] = useState("");

    const searchValue = value !== undefined ? value : internalValue;
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const newValue = e.target.value;
        if (onChange) {
            onChange(newValue);
        } else {
            setInternalValue(newValue);
        }
    };

    return (
        <div className={`relative ${className}`}>
            <input
                type="text"
                placeholder={placeholder}
                value={searchValue}
                onChange={handleChange}
                className="w-full rounded-full py-2 pl-10 pr-4 focus:outline-none focus:ring-2 transition-all duration-200"
                style={{
                    backgroundColor: isDark ? "rgba(17,24,39,0.7)" : "#f3f4f6",
                    color: isDark ? "white" : "#1f2937",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}`,
                }}
            />
            <span className="absolute left-3 top-2.5 text-gray-400">🔍</span>
        </div>
    );
}
