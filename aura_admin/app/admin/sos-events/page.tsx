"use client";

import { useState, useEffect, useCallback } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";
import { sosService } from "@/app/modules/sos/services/sos.service";
import { SOSEvent, SOSEventStatus, SOSStats } from "@/app/modules/sos/models/sos.model";
import SOSEventDetailsModal from "@/app/components/sos/SOSEventDetailsModal";

export default function SOSEventsPage() {
    const { isDark } = useTheme();
    const [events, setEvents] = useState<SOSEvent[]>([]);
    const [stats, setStats] = useState<SOSStats | null>(null);
    const [loading, setLoading] = useState(true);
    const [selectedEvent, setSelectedEvent] = useState<SOSEvent | null>(null);
    const [statusFilter, setStatusFilter] = useState<SOSEventStatus | "ALL">("ALL");
    const [page, setPage] = useState(0);
    const [totalPages, setTotalPages] = useState(0);

    const fetchEvents = useCallback(async () => {
        try {
            setLoading(true);
            const status = statusFilter === "ALL" ? undefined : statusFilter;
            const response = await sosService.getEvents(page, 20, status);
            setEvents(response.content);
            setTotalPages(response.totalPages);
        } catch (error) {
            console.error("Failed to fetch SOS events:", error);
        } finally {
            setLoading(false);
        }
    }, [page, statusFilter]);

    const fetchStats = useCallback(async () => {
        try {
            const data = await sosService.getStats();
            setStats(data);
        } catch (error) {
            console.error("Failed to fetch SOS stats:", error);
        }
    }, []);

    useEffect(() => {
        fetchEvents();
        fetchStats();
    }, [fetchEvents, fetchStats]);

    const handleAcknowledge = async (eventId: string) => {
        try {
            await sosService.acknowledgeEvent(eventId);
            fetchEvents();
            fetchStats();
        } catch (error) {
            console.error("Failed to acknowledge event:", error);
        }
    };

    const handleResolve = async (eventId: string, notes?: string) => {
        try {
            await sosService.resolveEvent(eventId, { resolutionNotes: notes });
            fetchEvents();
            fetchStats();
            setSelectedEvent(null);
        } catch (error) {
            console.error("Failed to resolve event:", error);
        }
    };

    const statusOptions: (SOSEventStatus | "ALL")[] = ["ALL", "TRIGGERED", "DELIVERED", "ACKNOWLEDGED", "RESOLVED", "CANCELLED"];

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1
                        className="text-2xl font-bold"
                        style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                    >
                        🚨 SOS Alerts
                    </h1>
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                        Monitor and respond to emergency alerts
                    </p>
                </div>
            </div>

            {/* Stats Cards */}
            {stats && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <StatCard
                        title="Active Alerts"
                        value={stats.activeEvents}
                        icon="🔴"
                        color="red"
                        isDark={isDark}
                    />
                    <StatCard
                        title="Today"
                        value={stats.eventsToday}
                        icon="📅"
                        color="blue"
                        isDark={isDark}
                    />
                    <StatCard
                        title="This Week"
                        value={stats.eventsThisWeek}
                        icon="📊"
                        color="purple"
                        isDark={isDark}
                    />
                    <StatCard
                        title="Total Resolved"
                        value={stats.resolvedEvents}
                        icon="✅"
                        color="green"
                        isDark={isDark}
                    />
                </div>
            )}

            {/* Filter */}
            <div
                className="p-4 rounded-xl"
                style={{
                    backgroundColor: isDark ? appColors.cardBg : "white",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                }}
            >
                <div className="flex flex-wrap gap-2">
                    {statusOptions.map((status) => (
                        <button
                            key={status}
                            onClick={() => {
                                setStatusFilter(status);
                                setPage(0);
                            }}
                            className="px-4 py-2 rounded-lg text-sm font-medium transition-all"
                            style={{
                                backgroundColor:
                                    statusFilter === status
                                        ? appColors.accent
                                        : isDark
                                            ? "#374151"
                                            : "#f3f4f6",
                                color:
                                    statusFilter === status
                                        ? "white"
                                        : isDark
                                            ? "#f3f4f6"
                                            : "#1f2937",
                            }}
                        >
                            {status}
                        </button>
                    ))}
                </div>
            </div>

            {/* Events List */}
            <div
                className="rounded-xl overflow-hidden"
                style={{
                    backgroundColor: isDark ? appColors.cardBg : "white",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                }}
            >
                {loading ? (
                    <div className="p-8 text-center">
                        <div className="animate-spin text-4xl mb-2">⏳</div>
                        <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                            Loading events...
                        </p>
                    </div>
                ) : events.length === 0 ? (
                    <div className="p-8 text-center">
                        <div className="text-4xl mb-2">📭</div>
                        <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                            No SOS events found
                        </p>
                    </div>
                ) : (
                    <div className="divide-y" style={{ borderColor: isDark ? appColors.cardBorder : "#e5e7eb" }}>
                        {events.map((event) => (
                            <div
                                key={event.id}
                                className="p-4 hover:bg-opacity-50 transition-colors cursor-pointer"
                                style={{ backgroundColor: event.status === "TRIGGERED" ? (isDark ? "rgba(239, 68, 68, 0.1)" : "rgba(254, 226, 226, 0.5)") : "transparent" }}
                                onClick={() => setSelectedEvent(event)}
                            >
                                <div className="flex items-start justify-between gap-4">
                                    <div className="flex-1">
                                        <div className="flex items-center gap-2 mb-1">
                                            <span
                                                className={`px-2 py-0.5 rounded-full text-xs font-medium ${sosService.getStatusBadgeColor(event.status)}`}
                                            >
                                                {event.status}
                                            </span>
                                            <span style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="text-sm">
                                                {sosService.getTimeAgo(event.triggeredAt)}
                                            </span>
                                            {event.syncedFromOffline && (
                                                <span className="text-xs px-2 py-0.5 rounded bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400">
                                                    Synced Offline
                                                </span>
                                            )}
                                        </div>
                                        <p
                                            className="font-medium"
                                            style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                                        >
                                            {event.userName || `User ${event.userId.slice(0, 8)}...`}
                                        </p>
                                        <p
                                            className="text-sm truncate max-w-md"
                                            style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                                        >
                                            {event.message}
                                        </p>
                                        <div className="flex items-center gap-4 mt-2 text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                            <span>📍 {event.address || `${event.latitude.toFixed(4)}, ${event.longitude.toFixed(4)}`}</span>
                                            <span>📱 {event.contactsNotified} notified</span>
                                        </div>
                                    </div>
                                    <div className="flex gap-2">
                                        {event.status === "TRIGGERED" && (
                                            <button
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    handleAcknowledge(event.id);
                                                }}
                                                className="px-3 py-1.5 rounded-lg text-sm font-medium bg-yellow-500 text-white hover:bg-yellow-600 transition-colors"
                                            >
                                                Acknowledge
                                            </button>
                                        )}
                                        {(event.status === "TRIGGERED" || event.status === "ACKNOWLEDGED") && (
                                            <button
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    setSelectedEvent(event);
                                                }}
                                                className="px-3 py-1.5 rounded-lg text-sm font-medium bg-green-500 text-white hover:bg-green-600 transition-colors"
                                            >
                                                Resolve
                                            </button>
                                        )}
                                        <a
                                            href={event.mapsUrl}
                                            target="_blank"
                                            rel="noopener noreferrer"
                                            onClick={(e) => e.stopPropagation()}
                                            className="px-3 py-1.5 rounded-lg text-sm font-medium transition-colors"
                                            style={{
                                                backgroundColor: isDark ? "#374151" : "#f3f4f6",
                                                color: isDark ? "#f3f4f6" : "#1f2937",
                                            }}
                                        >
                                            📍 Map
                                        </a>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}

                {/* Pagination */}
                {totalPages > 1 && (
                    <div
                        className="p-4 flex justify-center gap-2"
                        style={{ borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}
                    >
                        <button
                            onClick={() => setPage((p) => Math.max(0, p - 1))}
                            disabled={page === 0}
                            className="px-4 py-2 rounded-lg disabled:opacity-50"
                            style={{
                                backgroundColor: isDark ? "#374151" : "#f3f4f6",
                                color: isDark ? "#f3f4f6" : "#1f2937",
                            }}
                        >
                            Previous
                        </button>
                        <span
                            className="px-4 py-2"
                            style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                        >
                            Page {page + 1} of {totalPages}
                        </span>
                        <button
                            onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                            disabled={page >= totalPages - 1}
                            className="px-4 py-2 rounded-lg disabled:opacity-50"
                            style={{
                                backgroundColor: isDark ? "#374151" : "#f3f4f6",
                                color: isDark ? "#f3f4f6" : "#1f2937",
                            }}
                        >
                            Next
                        </button>
                    </div>
                )}
            </div>

            {/* Event Details Modal */}
            {selectedEvent && (
                <SOSEventDetailsModal
                    event={selectedEvent}
                    onClose={() => setSelectedEvent(null)}
                    onAcknowledge={handleAcknowledge}
                    onResolve={handleResolve}
                />
            )}
        </div>
    );
}

function StatCard({
    title,
    value,
    icon,
    color,
    isDark,
}: {
    title: string;
    value: number;
    icon: string;
    color: string;
    isDark: boolean;
}) {
    const colorMap: Record<string, string> = {
        red: isDark ? "rgba(239, 68, 68, 0.2)" : "rgba(254, 226, 226, 1)",
        blue: isDark ? "rgba(59, 130, 246, 0.2)" : "rgba(219, 234, 254, 1)",
        purple: isDark ? "rgba(139, 92, 246, 0.2)" : "rgba(237, 233, 254, 1)",
        green: isDark ? "rgba(34, 197, 94, 0.2)" : "rgba(220, 252, 231, 1)",
    };

    return (
        <div
            className="p-4 rounded-xl"
            style={{
                backgroundColor: colorMap[color] || (isDark ? appColors.cardBg : "white"),
                border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
            }}
        >
            <div className="flex items-center gap-3">
                <span className="text-2xl">{icon}</span>
                <div>
                    <p className="text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                        {title}
                    </p>
                    <p
                        className="text-2xl font-bold"
                        style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                    >
                        {value}
                    </p>
                </div>
            </div>
        </div>
    );
}
