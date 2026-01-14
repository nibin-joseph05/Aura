"use client";

import { createContext, useContext, useState, ReactNode, useCallback } from "react";
import { appColors } from "@/app/core/constants/colors";

type ToastType = "success" | "error" | "warning" | "info";

interface Toast {
    id: number;
    message: string;
    type: ToastType;
}

interface ToastContextType {
    showToast: (message: string, type?: ToastType) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export function useToast() {
    const context = useContext(ToastContext);
    if (!context) {
        throw new Error("useToast must be used within a ToastProvider");
    }
    return context;
}

const typeStyles: Record<ToastType, { bg: string; icon: string }> = {
    success: { bg: appColors.success, icon: "✓" },
    error: { bg: appColors.error, icon: "✕" },
    warning: { bg: appColors.warning, icon: "⚠" },
    info: { bg: appColors.info, icon: "ℹ" },
};

export function ToastProvider({ children }: { children: ReactNode }) {
    const [toasts, setToasts] = useState<Toast[]>([]);

    const showToast = useCallback((message: string, type: ToastType = "info") => {
        const id = Date.now();
        setToasts((prev) => [...prev, { id, message, type }]);

        setTimeout(() => {
            setToasts((prev) => prev.filter((t) => t.id !== id));
        }, 4000);
    }, []);

    const removeToast = (id: number) => {
        setToasts((prev) => prev.filter((t) => t.id !== id));
    };

    return (
        <ToastContext.Provider value={{ showToast }}>
            {children}
            <div className="fixed bottom-6 right-6 z-50 flex flex-col gap-3">
                {toasts.map((toast) => {
                    const style = typeStyles[toast.type];
                    return (
                        <div
                            key={toast.id}
                            className="flex items-center gap-3 px-4 py-3 rounded-lg shadow-lg animate-slide-in-right min-w-[300px] max-w-[400px]"
                            style={{ backgroundColor: style.bg }}
                        >
                            <span className="flex items-center justify-center w-6 h-6 rounded-full bg-white/20 text-white text-sm font-bold">
                                {style.icon}
                            </span>
                            <p className="flex-1 text-white text-sm">{toast.message}</p>
                            <button
                                onClick={() => removeToast(toast.id)}
                                className="text-white/70 hover:text-white transition-colors"
                            >
                                ✕
                            </button>
                        </div>
                    );
                })}
            </div>
            <style jsx>{`
        @keyframes slideInRight {
          from {
            transform: translateX(100%);
            opacity: 0;
          }
          to {
            transform: translateX(0);
            opacity: 1;
          }
        }
        .animate-slide-in-right {
          animation: slideInRight 0.3s ease-out forwards;
        }
      `}</style>
        </ToastContext.Provider>
    );
}
