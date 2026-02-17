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

    const sectionBg = isDark ? appColors.cardBgHover : "#f9fafb";
    const labelColor = isDark ? "#9ca3af" : "#6b7280";
    const textColor = isDark ? "#f3f4f6" : "#1f2937";
    const subTextColor = isDark ? "#6b7280" : "#9ca3af";

    return (
        <div
            className="fixed inset-0 z-50 flex items-center justify-center p-4"
            style={{ backgroundColor: "rgba(0, 0, 0, 0.6)", backdropFilter: "blur(4px)" }}
            onClick={onClose}
        >
            <div
                className="w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl"
                style={{
                    backgroundColor: isDark ? appColors.modalBg : "white",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                }}
                onClick={(e) => e.stopPropagation()}
            >
                <div
                    className="p-6"
                    style={{
                        borderBottom: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                        backgroundColor: event.status === "TRIGGERED"
                            ? (isDark ? "rgba(239, 68, 68, 0.15)" : "rgba(254, 226, 226, 0.5)")
                            : "transparent",
                    }}
                >
                    <div className="flex items-start justify-between">
                        <div>
                            <div className="flex items-center gap-2 mb-2">
                                <span className="text-2xl">🚨</span>
                                <h2 className="text-xl font-bold" style={{ color: textColor }}>
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
                            style={{ color: labelColor }}
                        >
                            ✕
                        </button>
                    </div>
                </div>

                <div className="p-6 space-y-5">
                    <div>
                        <h3 className="text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                            User Information
                        </h3>
                        <div className="p-4 rounded-xl" style={{ backgroundColor: sectionBg }}>
                            <p className="font-medium" style={{ color: textColor }}>
                                {event.userName || "Unknown User"}
                            </p>
                            {event.userPhone && (
                                <p className="text-sm mt-1" style={{ color: labelColor }}>📱 {event.userPhone}</p>
                            )}
                            <p className="text-xs mt-1 font-mono" style={{ color: subTextColor }}>
                                ID: {event.userId}
                            </p>
                        </div>
                    </div>

                    <div>
                        <h3 className="text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                            Emergency Message
                        </h3>
                        <p
                            className="p-4 rounded-xl"
                            style={{ backgroundColor: sectionBg, color: textColor }}
                        >
                            {event.message}
                        </p>
                    </div>

                    <div>
                        <h3 className="text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                            Location
                        </h3>
                        <div className="p-4 rounded-xl space-y-3" style={{ backgroundColor: sectionBg }}>
                            <p style={{ color: textColor }}>
                                📍 {event.address || "Address not available"}
                            </p>
                            <p className="text-sm" style={{ color: labelColor }}>
                                Coordinates: {event.latitude.toFixed(6)}, {event.longitude.toFixed(6)}
                            </p>
                            <div className="rounded-xl overflow-hidden border" style={{ borderColor: isDark ? appColors.cardBorder : "#e5e7eb" }}>
                                <iframe
                                    title="SOS Location"
                                    width="100%"
                                    height="250"
                                    style={{ border: 0 }}
                                    loading="lazy"
                                    src={`https://www.google.com/maps?q=${event.latitude},${event.longitude}&z=15&output=embed`}
                                />
                            </div>
                        </div>
                    </div>

                    <div>
                        <h3 className="text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                            Timeline
                        </h3>
                        <div className="p-4 rounded-xl space-y-3" style={{ backgroundColor: sectionBg }}>
                            <TimelineItem label="Triggered" time={event.triggeredAt} isDark={isDark} />
                            {event.acknowledgedAt && (
                                <TimelineItem label="Acknowledged" time={event.acknowledgedAt} isDark={isDark} />
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

                    {event.resolutionNotes && (
                        <div>
                            <h3 className="text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                                Resolution Notes
                            </h3>
                            <p
                                className="p-4 rounded-xl"
                                style={{ backgroundColor: sectionBg, color: textColor }}
                            >
                                {event.resolutionNotes}
                            </p>
                        </div>
                    )}

                    {showResolveForm && !event.resolvedAt && (
                        <div>
                            <h3 className="text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                                Resolution Notes (Optional)
                            </h3>
                            <textarea
                                value={resolutionNotes}
                                onChange={(e) => setResolutionNotes(e.target.value)}
                                placeholder="Enter any notes about how this was resolved..."
                                className="w-full p-4 rounded-xl resize-none outline-none"
                                rows={3}
                                style={{
                                    backgroundColor: sectionBg,
                                    color: textColor,
                                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                                }}
                            />
                        </div>
                    )}

                    <div className="flex gap-4 text-sm" style={{ color: labelColor }}>
                        <span>📱 {event.contactsNotified} contacts notified</span>
                        {event.syncedFromOffline && (
                            <span
                                className="px-2 py-0.5 rounded text-xs font-medium"
                                style={{
                                    backgroundColor: isDark ? "rgba(234,179,8,0.15)" : "#fef3c7",
                                    color: isDark ? "#fbbf24" : "#b45309",
                                }}
                            >
                                Synced from offline
                            </span>
                        )}
                    </div>
                </div>

                {(event.status === "TRIGGERED" || event.status === "ACKNOWLEDGED") && (
                    <div
                        className="p-6 flex justify-end gap-3"
                        style={{ borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}
                    >
                        {event.status === "TRIGGERED" && (
                            <button
                                onClick={() => onAcknowledge(event.id)}
                                className="px-5 py-2.5 rounded-lg font-medium bg-yellow-500 text-white hover:bg-yellow-600 transition-colors"
                            >
                                Acknowledge
                            </button>
                        )}
                        {!showResolveForm ? (
                            <button
                                onClick={() => setShowResolveForm(true)}
                                className="px-5 py-2.5 rounded-lg font-medium bg-green-500 text-white hover:bg-green-600 transition-colors"
                            >
                                Resolve
                            </button>
                        ) : (
                            <button
                                onClick={handleResolve}
                                className="px-5 py-2.5 rounded-lg font-medium bg-green-500 text-white hover:bg-green-600 transition-colors"
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
            <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: appColors.accent }} />
            <span className="font-medium" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>{label}:</span>
            <span style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                {sosService.formatDateTime(time)}
            </span>
            {extra && (
                <span style={{ color: isDark ? "#6b7280" : "#9ca3af" }}>({extra})</span>
            )}
        </div>
    );
}
