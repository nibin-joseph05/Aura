"use client";

import Image from "next/image";
import { appColors } from "@/app/core/constants/colors";

interface PageLoaderProps {
    message?: string;
    fullScreen?: boolean;
}

export default function PageLoader({ message = "Loading...", fullScreen = true }: PageLoaderProps) {
    const content = (
        <div className="flex flex-col items-center justify-center gap-4">
            <div className="relative" style={{ width: 100, height: 100 }}>
                <div
                    className="absolute inset-0 rounded-full animate-spin-slow"
                    style={{
                        border: `3px solid transparent`,
                        borderTopColor: appColors.accent,
                        borderRightColor: appColors.primary,
                    }}
                />
                <div
                    className="absolute inset-1 rounded-full animate-spin-reverse"
                    style={{
                        border: `2px solid transparent`,
                        borderBottomColor: appColors.accent,
                        borderLeftColor: appColors.primaryLight,
                        opacity: 0.5,
                    }}
                />
                <div
                    className="absolute inset-2 overflow-hidden rounded-full"
                >
                    <Image
                        src="/loading/ghost-running.gif"
                        alt="Loading"
                        fill
                        className="object-cover scale-125"
                        unoptimized
                    />
                </div>
            </div>
            <p
                className="text-lg font-semibold animate-pulse"
                style={{
                    background: `linear-gradient(to right, ${appColors.accent}, ${appColors.primary})`,
                    WebkitBackgroundClip: "text",
                    WebkitTextFillColor: "transparent",
                }}
            >
                {message}
            </p>

            <style jsx>{`
        @keyframes spinSlow {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
        .animate-spin-slow {
          animation: spinSlow 2s linear infinite;
        }

        @keyframes spinReverse {
          from { transform: rotate(360deg); }
          to { transform: rotate(0deg); }
        }
        .animate-spin-reverse {
          animation: spinReverse 3s linear infinite;
        }
      `}</style>
        </div>
    );

    if (fullScreen) {
        return (
            <div
                className="fixed inset-0 z-50 flex items-center justify-center"
                style={{
                    backgroundColor: "rgba(10, 26, 47, 0.7)",
                    backdropFilter: "blur(4px)",
                }}
            >
                {content}
            </div>
        );
    }

    return (
        <div className="flex items-center justify-center py-12">
            {content}
        </div>
    );
}
