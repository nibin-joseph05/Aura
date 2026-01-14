"use client";

import Link from "next/link";
import { appColors } from "@/app/core/constants/colors";

interface BackButtonProps {
    href: string;
    label?: string;
}

export default function BackButton({ href, label = "Back to Home" }: BackButtonProps) {
    return (
        <Link
            href={href}
            className="group relative flex items-center justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-lg text-white transition-all duration-300 ease-in-out transform hover:-translate-y-1 shadow-md hover:shadow-lg"
            style={{
                background: `linear-gradient(to right, ${appColors.accent}, ${appColors.primary})`,
            }}
        >
            <svg
                className="w-5 h-5 mr-2 transition-transform group-hover:-translate-x-1"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
            >
                <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M15 19l-7-7 7-7"
                />
            </svg>
            {label}
        </Link>
    );
}
