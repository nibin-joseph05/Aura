"use client";

import { useState } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";
import { apiClient } from "@/app/core/network/api-client";

export default function NotificationsPage() {
    const { isDark } = useTheme();
    const [title, setTitle] = useState("");
    const [body, setBody] = useState("");
    const [deepLink, setDeepLink] = useState("");
    const [sending, setSending] = useState(false);
    const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);
    const [history, setHistory] = useState<{ title: string; body: string; sentAt: string }[]>([]);

    const handleSend = async () => {
        if (!title.trim() || !body.trim()) {
            setMessage({ type: "error", text: "Title and body are required." });
            return;
        }

        setSending(true);
        setMessage(null);

        try {
            const payload: Record<string, string> = { title: title.trim(), body: body.trim() };
            if (deepLink.trim()) payload.deepLink = deepLink.trim();

            const response = await apiClient.post("/api/admin/notifications/broadcast", payload);

            if (response.success) {
                setMessage({ type: "success", text: "Notification sent to all users!" });
                setHistory((prev) => [{ title: title.trim(), body: body.trim(), sentAt: new Date().toISOString() }, ...prev]);
                setTitle("");
                setBody("");
                setDeepLink("");
            } else {
                setMessage({ type: "error", text: response.error || "Failed to send notification." });
            }
        } catch {
            setMessage({ type: "error", text: "Failed to send notification. Check backend connection." });
        } finally {
            setSending(false);
        }
    };

    const inputStyle = {
        backgroundColor: isDark ? appColors.cardBgHover : "#f9fafb",
        color: isDark ? "#f3f4f6" : "#1f2937",
        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
    };

    const labelColor = isDark ? "#9ca3af" : "#6b7280";
    const textColor = isDark ? "#f3f4f6" : "#1f2937";

    return (
        <div className="space-y-6">
            <div>
                <h2 className="text-xl font-bold" style={{ color: textColor }}>
                    Send Notifications
                </h2>
                <p style={{ color: labelColor }}>
                    Broadcast push notifications to all app users
                </p>
            </div>

            {message && (
                <div
                    className="p-4 rounded-xl font-medium text-sm"
                    style={{
                        backgroundColor: message.type === "success" ? "rgba(34,197,94,0.12)" : "rgba(239,68,68,0.12)",
                        border: `1px solid ${message.type === "success" ? "#22c55e" : "#ef4444"}`,
                        color: message.type === "success" ? "#22c55e" : "#ef4444",
                    }}
                >
                    {message.type === "success" ? "✅" : "❌"} {message.text}
                </div>
            )}

            <div
                className="rounded-xl p-6"
                style={{
                    backgroundColor: isDark ? appColors.cardBg : "white",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                }}
            >
                <h3 className="text-lg font-semibold mb-5 flex items-center gap-2" style={{ color: textColor }}>
                    📢 Compose Notification
                </h3>

                <div className="space-y-4">
                    <div>
                        <label className="block text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                            Title *
                        </label>
                        <input
                            type="text"
                            value={title}
                            onChange={(e) => setTitle(e.target.value)}
                            placeholder="e.g. New Feature Available!"
                            className="w-full rounded-xl p-3.5 outline-none transition-all"
                            style={inputStyle}
                            maxLength={100}
                        />
                        <p className="text-xs mt-1 text-right" style={{ color: labelColor }}>
                            {title.length}/100
                        </p>
                    </div>

                    <div>
                        <label className="block text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                            Body *
                        </label>
                        <textarea
                            value={body}
                            onChange={(e) => setBody(e.target.value)}
                            placeholder="e.g. Check out our latest wellness features and daily activities..."
                            className="w-full rounded-xl p-3.5 resize-none outline-none transition-all"
                            rows={4}
                            style={inputStyle}
                            maxLength={500}
                        />
                        <p className="text-xs mt-1 text-right" style={{ color: labelColor }}>
                            {body.length}/500
                        </p>
                    </div>

                    <div>
                        <label className="block text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                            Deep Link (Optional)
                        </label>
                        <input
                            type="text"
                            value={deepLink}
                            onChange={(e) => setDeepLink(e.target.value)}
                            placeholder="e.g. /wellness or /activities"
                            className="w-full rounded-xl p-3.5 outline-none transition-all"
                            style={inputStyle}
                        />
                        <p className="text-xs mt-1" style={{ color: labelColor }}>
                            Opens a specific screen in the app when tapped
                        </p>
                    </div>

                    <div
                        className="p-4 rounded-xl"
                        style={{ backgroundColor: isDark ? appColors.cardBgHover : "#f0f9ff" }}
                    >
                        <p className="text-xs font-semibold uppercase tracking-wider mb-2" style={{ color: labelColor }}>
                            Preview
                        </p>
                        <div
                            className="p-3 rounded-lg"
                            style={{
                                backgroundColor: isDark ? appColors.cardBg : "white",
                                border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                            }}
                        >
                            <p className="font-semibold text-sm" style={{ color: textColor }}>
                                {title || "Notification Title"}
                            </p>
                            <p className="text-sm mt-0.5" style={{ color: labelColor }}>
                                {body || "Notification body text will appear here..."}
                            </p>
                        </div>
                    </div>

                    <button
                        onClick={handleSend}
                        disabled={sending || !title.trim() || !body.trim()}
                        className="w-full py-3.5 rounded-xl text-white font-semibold transition-all disabled:opacity-40"
                        style={{
                            background: `linear-gradient(135deg, ${appColors.accent}, ${appColors.primary})`,
                        }}
                    >
                        {sending ? "Sending..." : "📤 Send to All Users"}
                    </button>
                </div>
            </div>

            {history.length > 0 && (
                <div
                    className="rounded-xl p-6"
                    style={{
                        backgroundColor: isDark ? appColors.cardBg : "white",
                        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                    }}
                >
                    <h3 className="text-lg font-semibold mb-4 flex items-center gap-2" style={{ color: textColor }}>
                        📋 Sent This Session
                    </h3>
                    <div className="space-y-3">
                        {history.map((item, i) => (
                            <div
                                key={i}
                                className="p-3 rounded-lg"
                                style={{
                                    backgroundColor: isDark ? appColors.cardBgHover : "#f9fafb",
                                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                                }}
                            >
                                <div className="flex justify-between items-start">
                                    <div>
                                        <p className="font-medium text-sm" style={{ color: textColor }}>{item.title}</p>
                                        <p className="text-xs mt-0.5" style={{ color: labelColor }}>{item.body}</p>
                                    </div>
                                    <span className="text-xs whitespace-nowrap ml-3" style={{ color: labelColor }}>
                                        {new Date(item.sentAt).toLocaleTimeString()}
                                    </span>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
}
