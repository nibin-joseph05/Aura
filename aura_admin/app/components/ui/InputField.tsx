"use client";

import { InputHTMLAttributes, useState } from "react";
import { appColors } from "@/app/core/constants/colors";

interface InputFieldProps extends InputHTMLAttributes<HTMLInputElement> {
    label?: string;
    error?: string;
}

export default function InputField({
    label,
    error,
    className = "",
    ...props
}: InputFieldProps) {
    const [isFocused, setIsFocused] = useState(false);

    return (
        <div className="w-full">
            {label && (
                <label
                    htmlFor={props.id}
                    className="block text-sm font-medium text-gray-300 mb-1"
                >
                    {label}
                </label>
            )}
            <input
                {...props}
                className={`appearance-none rounded-lg relative block w-full px-4 py-3 placeholder-gray-500 text-white focus:outline-none focus:z-10 sm:text-sm transition-all duration-200 ${className}`}
                style={{
                    backgroundColor: appColors.cardBg,
                    border: `1px solid ${error ? appColors.error : isFocused ? appColors.accent : appColors.cardBorder
                        }`,
                }}
                onFocus={(e) => {
                    setIsFocused(true);
                    props.onFocus?.(e);
                }}
                onBlur={(e) => {
                    setIsFocused(false);
                    props.onBlur?.(e);
                }}
            />
            {error && (
                <p className="mt-1 text-xs" style={{ color: appColors.error }}>
                    {error}
                </p>
            )}
        </div>
    );
}
