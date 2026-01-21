"use client";

import { useState } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";
import { SOSEvent } from "@/app/modules/sos/models/sos.model";
import { sosService } from "@/app/modules/sos/services/sos.service";

interface SOSEventDetailsModalProps {
    event: SOSEvent;
    onClose: () => void;
    onAcknowledge: (eventId: string) => void;
    onResolve: (eventId: string, notes?: string) => void;
}

export default function SOSEventDetailsModal({
    event,
    onClose,
    onAcknowledge,
    onResolve,
}: SOSEventDetailsModalProps) {
    const { isDark } = useTheme();
    const [resolutionNotes, setResolutionNotes] = useState("");
    const [showResolveForm, setShowResolveForm] = useState(false);

    const handleResolve = () => {
        onResolve(event.id, resolutionNotes || undefined);
    };

    return (
        <div
            className="fixed inset-0 z-50 flex items-center justify-center p-4"
            style={{ backgroundColor: "rgba(0, 0, 0, 0.5)" }}
            onClick={onClose}
        >
            <div
                className="w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl"
                style={{
                    backgroundColor: isDark ? appColors.cardBg : "white",
                }}
                onClick={(e) => e.stopPropagation()}
            >
                {/* Header */}
                <div
                    className="p-6"
                    style={{
                        borderBottom: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                        backgroundColor: event.status === "TRIGGERED"
                            ? (isDark ? "rgba(239, 68, 68, 0.2)" : "rgba(254, 226, 226, 0.5)")
                            : "transparent",
                    }}
                >
                    <div className="flex items-start justify-between">
                        <div>
                            <div className="flex items-center gap-2 mb-2">
                                <span className="text-2xl">🚨</span>
                                <h2
                                    className="text-xl font-bold"
                                    style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                                >
                                    SOS Alert Details
                                </h2>
                            </div>
                            <span
                                className={`px-3 py-1 rounded-full text-sm font-medium ${sosService.getStatusBadgeColor(event.status)}`}
                            >
                                {event.status}
                            </span>
                        </div>
                        <button
                            onClick={onClose}
                            className="text-2xl hover:opacity-70 transition-opacity"
                            style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                        >
                            ✕
                        </button>
                    </div>
                </div>

                {/* Content */}
                <div className="p-6 space-y-6">
                    {/* User Info */}
                    <div>
                        <h3
                            className="text-sm font-medium mb-2"
                            style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                        >
                            User Information
                        </h3>
                        <div
                            className="p-4 rounded-xl"
                            style={{
                                backgroundColor: isDark ? "#1f2937" : "#f9fafb",
                            }}
                        >
                            <p
                                className="font-medium"
                                style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}
                            >
                                {event.userName || "Unknown User"}
                            </p>
                            {event.userPhone && (
                                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                    📱 {event.userPhone}
                                </p>
                            )}
                            <p
                                className="text-sm mt-1"
                                style={{ color: isDark ? "#6b7280" : "#9ca3af" }}
                            >
                                ID: {event.userId}
                            </p>
                        </div>
                    </div>

                    {/* Message */}
                    <div>
                        <h3
                            className="text-sm font-medium mb-2"
                            style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                        >
                            Emergency Message
                        </h3>
                        <p
                            className="p-4 rounded-xl"
                            style={{
                                backgroundColor: isDark ? "#1f2937" : "#f9fafb",
                                color: isDark ? "#f3f4f6" : "#1f2937",
                            }}
                        >
                            {event.message}
                        </p>
                    </div>

                    {/* Location */}
                    <div>
                        <h3
                            className="text-sm font-medium mb-2"
                            style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                        >
                            Location
                        </h3>
                        <div
                            className="p-4 rounded-xl"
                            style={{
                                backgroundColor: isDark ? "#1f2937" : "#f9fafb",
                            }}
                        >
                            <p style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                                📍 {event.address || "Address not available"}
                            </p>
                            <p
                                className="text-sm mt-1"
                                style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                            >
                                Coordinates: {event.latitude.toFixed(6)}, {event.longitude.toFixed(6)}
                            </p>
                            <a
                                href={event.mapsUrl}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="inline-block mt-3 px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                                style={{
                                    backgroundColor: appColors.accent,
                                    color: "white",
                                }}
                            >
                                🗺️ View on Google Maps
                            </a>
                        </div>
                    </div>

                    {/* Timeline */}
                    <div>
                        <h3
                            className="text-sm font-medium mb-2"
                            style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                        >
                            Timeline
                        </h3>
                        <div
                            className="p-4 rounded-xl space-y-2"
                            style={{
                                backgroundColor: isDark ? "#1f2937" : "#f9fafb",
                            }}
                        >
                            <TimelineItem
                                label="Triggered"
                                time={event.triggeredAt}
                                isDark={isDark}
                            />
                            {event.acknowledgedAt && (
                                <TimelineItem
                                    label="Acknowledged"
                                    time={event.acknowledgedAt}
                                    isDark={isDark}
                                />
                            )}
                            {event.resolvedAt && (
                                <TimelineItem
                                    label="Resolved"
                                    time={event.resolvedAt}
                                    extra={event.resolvedBy ? `by ${event.resolvedBy}` : undefined}
                                    isDark={isDark}
                                />
                            )}
                        </div>
                    </div>

                    {/* Resolution Notes */}
                    {event.resolutionNotes && (
                        <div>
                            <h3
                                className="text-sm font-medium mb-2"
                                style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                            >
                                Resolution Notes
                            </h3>
                            <p
                                className="p-4 rounded-xl"
                                style={{
                                    backgroundColor: isDark ? "#1f2937" : "#f9fafb",
                                    color: isDark ? "#f3f4f6" : "#1f2937",
                                }}
                            >
                                {event.resolutionNotes}
                            </p>
                        </div>
                    )}

                    {/* Resolve Form */}
                    {showResolveForm && !event.resolvedAt && (
                        <div>
                            <h3
                                className="text-sm font-medium mb-2"
                                style={{ color: isDark ? "#9ca3af" : "#6b7280" }}
                            >
                                Resolution Notes (Optional)
                            </h3>
                            <textarea
                                value={resolutionNotes}
                                onChange={(e) => setResolutionNotes(e.target.value)}
                                placeholder="Enter any notes about how this was resolved..."
                                className="w-full p-4 rounded-xl border-none resize-none"
                                rows={3}
                                style={{
                                    backgroundColor: isDark ? "#1f2937" : "#f9fafb",
                                    color: isDark ? "#f3f4f6" : "#1f2937",
                                }}
                            />
                        </div>
                    )}

                    {/* Stats */}
                    <div className="flex gap-4 text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                        <span>📱 {event.contactsNotified} contacts notified</span>
                        {event.syncedFromOffline && (
                            <span className="px-2 py-0.5 rounded bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400">
                                Synced from offline
                            </span>
                        )}
                    </div>
                </div>

                {/* Footer Actions */}
                {(event.status === "TRIGGERED" || event.status === "ACKNOWLEDGED") && (
                    <div
                        className="p-6 flex justify-end gap-3"
                        style={{
                            borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                        }}
                    >
                        {event.status === "TRIGGERED" && (
                            <button
                                onClick={() => onAcknowledge(event.id)}
                                className="px-4 py-2 rounded-lg font-medium bg-yellow-500 text-white hover:bg-yellow-600 transition-colors"
                            >
                                Acknowledge
                            </button>
                        )}
                        {!showResolveForm ? (
                            <button
                                onClick={() => setShowResolveForm(true)}
                                className="px-4 py-2 rounded-lg font-medium bg-green-500 text-white hover:bg-green-600 transition-colors"
                            >
                                Resolve
                            </button>
                        ) : (
                            <button
                                onClick={handleResolve}
                                className="px-4 py-2 rounded-lg font-medium bg-green-500 text-white hover:bg-green-600 transition-colors"
                            >
                                Confirm Resolution
                            </button>
                        )}
                    </div>
                )}
            </div>
        </div>
    );
}

function TimelineItem({
    label,
    time,
    extra,
    isDark,
}: {
    label: string;
    time: string;
    extra?: string;
    isDark: boolean;
}) {
    return (
        <div className="flex items-center gap-3">
            <span className="w-2 h-2 rounded-full" style={{ backgroundColor: appColors.accent }} />
            <span style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>{label}:</span>
            <span style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                {sosService.formatDateTime(time)}
            </span>
            {extra && (
                <span style={{ color: isDark ? "#6b7280" : "#9ca3af" }}>({extra})</span>
            )}
        </div>
    );
}
