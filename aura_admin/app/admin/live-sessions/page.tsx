"use client";

import { useState, useEffect, useCallback } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";
import { sosService } from "@/app/modules/sos/services/sos.service";
import { LiveLocationSession } from "@/app/modules/sos/models/sos.model";

export default function LiveSessionsPage() {
    const { isDark } = useTheme();
    const [sessions, setSessions] = useState<LiveLocationSession[]>([]);
    const [loading, setLoading] = useState(true);
    const [expandedSession, setExpandedSession] = useState<string | null>(null);

    const fetchSessions = useCallback(async () => {
        try {
            setLoading(true);
            const data = await sosService.getLiveSessions();
            setSessions(data);
        } catch (error) {
            console.error("Failed to fetch live sessions:", error);
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchSessions();
        const interval = setInterval(fetchSessions, 15000);
        return () => clearInterval(interval);
    }, [fetchSessions]);

    const cardBg = isDark ? appColors.surfaceDark : "#ffffff";
    const borderColor = isDark ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.08)";
    const textPrimary = isDark ? "#f3f4f6" : "#1f2937";
    const textSecondary = isDark ? "#9ca3af" : "#6b7280";

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h2 className="text-xl font-bold" style={{ color: textPrimary }}>
                        Live Location Tracking
                    </h2>
                    <p style={{ color: textSecondary }}>
                        Monitor active live location sharing sessions
                    </p>
                </div>

                <button
                    onClick={fetchSessions}
                    className="px-4 py-2 rounded-xl font-medium text-sm transition-all"
                    style={{
                        backgroundColor: isDark ? "rgba(139,92,246,0.2)" : "rgba(139,92,246,0.1)",
                        color: "#8b5cf6",
                        border: `1px solid ${isDark ? "rgba(139,92,246,0.3)" : "rgba(139,92,246,0.2)"}`,
                    }}
                >
                    🔄 Refresh
                </button>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div
                    className="p-5 rounded-2xl"
                    style={{ backgroundColor: cardBg, border: `1px solid ${borderColor}` }}
                >
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl flex items-center justify-center text-lg"
                            style={{ backgroundColor: "rgba(239,68,68,0.15)" }}>
                            📡
                        </div>
                        <div>
                            <p className="text-2xl font-bold" style={{ color: textPrimary }}>
                                {sessions.length}
                            </p>
                            <p className="text-xs" style={{ color: textSecondary }}>
                                Active Sessions
                            </p>
                        </div>
                    </div>
                </div>

                <div
                    className="p-5 rounded-2xl"
                    style={{ backgroundColor: cardBg, border: `1px solid ${borderColor}` }}
                >
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl flex items-center justify-center text-lg"
                            style={{ backgroundColor: "rgba(34,197,94,0.15)" }}>
                            📍
                        </div>
                        <div>
                            <p className="text-2xl font-bold" style={{ color: textPrimary }}>
                                {sessions.reduce((sum, s) => sum + (s.points?.length || 0), 0)}
                            </p>
                            <p className="text-xs" style={{ color: textSecondary }}>
                                Total Points Tracked
                            </p>
                        </div>
                    </div>
                </div>

                <div
                    className="p-5 rounded-2xl"
                    style={{ backgroundColor: cardBg, border: `1px solid ${borderColor}` }}
                >
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl flex items-center justify-center text-lg"
                            style={{ backgroundColor: "rgba(59,130,246,0.15)" }}>
                            👥
                        </div>
                        <div>
                            <p className="text-2xl font-bold" style={{ color: textPrimary }}>
                                {new Set(sessions.map(s => s.userId)).size}
                            </p>
                            <p className="text-xs" style={{ color: textSecondary }}>
                                Users Sharing
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            {/* Sessions list */}
            {loading ? (
                <div className="flex justify-center py-16">
                    <div className="w-8 h-8 border-3 border-purple-500 border-t-transparent rounded-full animate-spin" />
                </div>
            ) : sessions.length === 0 ? (
                <div
                    className="text-center py-16 rounded-2xl"
                    style={{ backgroundColor: cardBg, border: `1px solid ${borderColor}` }}
                >
                    <p className="text-4xl mb-3">📍</p>
                    <p className="text-lg font-semibold" style={{ color: textPrimary }}>
                        No Active Sessions
                    </p>
                    <p className="text-sm mt-1" style={{ color: textSecondary }}>
                        No users are currently sharing their live location
                    </p>
                </div>
            ) : (
                <div className="space-y-3">
                    {sessions.map((session) => (
                        <div
                            key={session.id}
                            className="rounded-2xl overflow-hidden transition-all"
                            style={{ backgroundColor: cardBg, border: `1px solid ${borderColor}` }}
                        >
                            {/* Session header */}
                            <div
                                className="p-5 cursor-pointer hover:opacity-80 transition-opacity"
                                onClick={() => setExpandedSession(
                                    expandedSession === session.id ? null : session.id
                                )}
                            >
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-4">
                                        <div
                                            className="w-3 h-3 rounded-full animate-pulse"
                                            style={{ backgroundColor: session.active ? "#ef4444" : "#6b7280" }}
                                        />
                                        <div>
                                            <p className="font-semibold" style={{ color: textPrimary }}>
                                                User: {session.userId.substring(0, 12)}...
                                            </p>
                                            <p className="text-xs" style={{ color: textSecondary }}>
                                                Started {sosService.getTimeAgo(session.startedAt)}
                                                {session.durationMinutes && ` · ${session.durationMinutes}min duration`}
                                            </p>
                                        </div>
                                    </div>

                                    <div className="flex items-center gap-3">
                                        <span
                                            className="px-3 py-1 rounded-full text-xs font-medium"
                                            style={{
                                                backgroundColor: session.active
                                                    ? "rgba(239,68,68,0.15)"
                                                    : "rgba(107,114,128,0.15)",
                                                color: session.active ? "#ef4444" : "#6b7280",
                                            }}
                                        >
                                            {session.active ? "🔴 LIVE" : "Ended"}
                                        </span>
                                        <span className="text-xs" style={{ color: textSecondary }}>
                                            {session.points?.length || 0} points
                                        </span>
                                        <span style={{ color: textSecondary }}>
                                            {expandedSession === session.id ? "▲" : "▼"}
                                        </span>
                                    </div>
                                </div>
                            </div>

                            {/* Expanded details */}
                            {expandedSession === session.id && (
                                <div
                                    className="px-5 pb-5 space-y-4"
                                    style={{ borderTop: `1px solid ${borderColor}` }}
                                >
                                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-4">
                                        <div>
                                            <p className="text-xs" style={{ color: textSecondary }}>Session ID</p>
                                            <p className="text-sm font-mono" style={{ color: textPrimary }}>
                                                {session.id.substring(0, 8)}
                                            </p>
                                        </div>
                                        <div>
                                            <p className="text-xs" style={{ color: textSecondary }}>Contacts Allowed</p>
                                            <p className="text-sm font-semibold" style={{ color: textPrimary }}>
                                                {session.allowedContactIds?.length || 0}
                                            </p>
                                        </div>
                                        <div>
                                            <p className="text-xs" style={{ color: textSecondary }}>Blockchain</p>
                                            <p className="text-sm" style={{ color: textPrimary }}>
                                                {session.blockHash ? `#${session.blockIndex}` : "Pending"}
                                            </p>
                                        </div>
                                        <div>
                                            <p className="text-xs" style={{ color: textSecondary }}>Ended At</p>
                                            <p className="text-sm" style={{ color: textPrimary }}>
                                                {session.endedAt ? sosService.formatDateTime(session.endedAt) : "Still active"}
                                            </p>
                                        </div>
                                    </div>

                                    {session.points && session.points.length > 0 && (
                                        <div>
                                            <p className="text-xs font-medium mb-2" style={{ color: textSecondary }}>
                                                Recent Points (last 5)
                                            </p>
                                            <div className="space-y-1">
                                                {session.points.slice(-5).map((point, index) => (
                                                    <div
                                                        key={point.id || index}
                                                        className="flex items-center justify-between text-xs p-2 rounded-lg"
                                                        style={{
                                                            backgroundColor: isDark
                                                                ? "rgba(255,255,255,0.05)"
                                                                : "rgba(0,0,0,0.03)",
                                                        }}
                                                    >
                                                        <span style={{ color: textPrimary }}>
                                                            📍 {point.latitude.toFixed(6)}, {point.longitude.toFixed(6)}
                                                        </span>
                                                        <span style={{ color: textSecondary }}>
                                                            {sosService.getTimeAgo(point.timestamp)}
                                                            {point.speed != null && ` · ${point.speed.toFixed(1)} m/s`}
                                                        </span>
                                                    </div>
                                                ))}
                                            </div>
                                        </div>
                                    )}
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
