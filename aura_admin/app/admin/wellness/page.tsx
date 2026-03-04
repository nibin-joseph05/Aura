"use client";

import { useState, useEffect, useCallback } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { wellnessService } from "@/app/modules/wellness/services/wellness.service";
import { WellnessUpdate, WellnessCategory, WellnessStats } from "@/app/modules/wellness/models/wellness.model";

const CATEGORIES: { label: string; value: WellnessCategory | "ALL" }[] = [
    { label: "All", value: "ALL" },
    { label: "📈 Progress", value: "PROGRESS" },
    { label: "💪 Motivation", value: "MOTIVATION" },
    { label: "💡 Tip", value: "TIP" },
    { label: "🏆 Achievement", value: "ACHIEVEMENT" },
    { label: "✨ General", value: "GENERAL" },
];

export default function WellnessPage() {
    const { isDark } = useTheme();
    const [updates, setUpdates] = useState<WellnessUpdate[]>([]);
    const [stats, setStats] = useState<WellnessStats | null>(null);
    const [loading, setLoading] = useState(true);
    const [categoryFilter, setCategoryFilter] = useState<WellnessCategory | "ALL">("ALL");
    const [userFilter, setUserFilter] = useState("");
    const [userFilterInput, setUserFilterInput] = useState("");
    const [page, setPage] = useState(0);
    const [totalPages, setTotalPages] = useState(0);
    const [warnMessage, setWarnMessage] = useState<Record<string, string>>({});
    const [warningPostId, setWarningPostId] = useState<string | null>(null);
    const [actionLoading, setActionLoading] = useState<string | null>(null);

    const fetchUpdates = useCallback(async () => {
        try {
            setLoading(true);
            const response = await wellnessService.getAllUpdates(
                page,
                20,
                categoryFilter === "ALL" ? undefined : categoryFilter,
                userFilter || undefined
            );
            setUpdates(response.content);
            setTotalPages(response.totalPages);
        } catch (error) {
            console.error("Failed to fetch updates:", error);
        } finally {
            setLoading(false);
        }
    }, [page, categoryFilter, userFilter]);

    const fetchStats = useCallback(async () => {
        try {
            const data = await wellnessService.getStats();
            setStats(data);
        } catch {

        }
    }, []);

    useEffect(() => {
        fetchUpdates();
        fetchStats();
    }, [fetchUpdates, fetchStats]);

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this post?")) return;
        try {
            setActionLoading(id);
            await wellnessService.deleteUpdate(id);
            fetchUpdates();
            fetchStats();
        } catch (error) {
            console.error("Failed to delete:", error);
        } finally {
            setActionLoading(null);
        }
    };

    const handleHide = async (id: string) => {
        try {
            setActionLoading(id);
            await wellnessService.hideUpdate(id);
            fetchUpdates();
        } catch (error) {
            console.error("Failed to hide:", error);
        } finally {
            setActionLoading(null);
        }
    };

    const handleWarn = async (id: string) => {
        try {
            setActionLoading(id);
            await wellnessService.warnUser(id, warnMessage[id] || undefined);
            setWarningPostId(null);
            alert("Warning sent to user.");
        } catch (error) {
            console.error("Failed to warn user:", error);
        } finally {
            setActionLoading(null);
        }
    };

    const bg = isDark ? "#0A1A2F" : "#F0F4F8";
    const card = isDark ? "rgba(255,255,255,0.06)" : "rgba(255,255,255,0.9)";
    const border = isDark ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.08)";
    const text = isDark ? "#FFFFFF" : "#1A2744";
    const muted = isDark ? "rgba(255,255,255,0.55)" : "rgba(26,39,68,0.55)";

    return (
        <div style={{ minHeight: "100vh", background: bg, padding: "24px" }}>
            {/* Header */}
            <div style={{ marginBottom: "24px" }}>
                <h1 style={{ color: text, fontSize: "24px", fontWeight: 700, margin: 0 }}>Wellness Posts</h1>
                <p style={{ color: muted, marginTop: "4px", fontSize: "14px" }}>Manage all community wellness posts</p>
            </div>

            {/* Stats */}
            {stats && (
                <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))", gap: "16px", marginBottom: "24px" }}>
                    {[
                        { label: "Total Posts", value: stats.totalUpdates ?? 0 },
                        { label: "Total Likes", value: stats.totalLikes ?? 0 },
                        { label: "Total Comments", value: stats.totalComments ?? 0 },
                        { label: "Total Users", value: stats.totalUsers ?? 0 },
                    ].map((s) => (
                        <div key={s.label} style={{ background: card, border: `1px solid ${border}`, borderRadius: "16px", padding: "16px 20px" }}>
                            <div style={{ color: muted, fontSize: "12px", fontWeight: 600, letterSpacing: 1, marginBottom: "4px" }}>{s.label.toUpperCase()}</div>
                            <div style={{ color: text, fontSize: "28px", fontWeight: 700 }}>{s.value}</div>
                        </div>
                    ))}
                </div>
            )}

            {/* Filters */}
            <div style={{ display: "flex", flexWrap: "wrap", gap: "12px", marginBottom: "20px", alignItems: "center" }}>
                {/* User ID filter */}
                <div style={{ display: "flex", gap: "8px", flex: "1 1 280px" }}>
                    <input
                        type="text"
                        placeholder="Filter by User ID…"
                        value={userFilterInput}
                        onChange={(e) => setUserFilterInput(e.target.value)}
                        onKeyDown={(e) => { if (e.key === "Enter") { setUserFilter(userFilterInput); setPage(0); } }}
                        style={{ flex: 1, background: card, border: `1px solid ${border}`, borderRadius: "10px", padding: "8px 14px", color: text, fontSize: "14px", outline: "none" }}
                    />
                    <button
                        onClick={() => { setUserFilter(userFilterInput); setPage(0); }}
                        style={{ padding: "8px 16px", borderRadius: "10px", background: "#00BCD4", color: "#fff", border: "none", fontWeight: 600, cursor: "pointer" }}
                    >
                        Search
                    </button>
                    {userFilter && (
                        <button
                            onClick={() => { setUserFilter(""); setUserFilterInput(""); setPage(0); }}
                            style={{ padding: "8px 14px", borderRadius: "10px", background: "rgba(255,0,0,0.15)", color: "#f44336", border: "none", fontWeight: 600, cursor: "pointer" }}
                        >
                            Clear
                        </button>
                    )}
                </div>

                {/* Category filter */}
                <div style={{ display: "flex", gap: "6px", flexWrap: "wrap" }}>
                    {CATEGORIES.map((cat) => (
                        <button
                            key={cat.value}
                            onClick={() => { setCategoryFilter(cat.value); setPage(0); }}
                            style={{
                                padding: "6px 14px",
                                borderRadius: "20px",
                                background: categoryFilter === cat.value ? "#00BCD4" : card,
                                color: categoryFilter === cat.value ? "#fff" : muted,
                                border: `1px solid ${categoryFilter === cat.value ? "#00BCD4" : border}`,
                                fontWeight: categoryFilter === cat.value ? 600 : 400,
                                cursor: "pointer",
                                fontSize: "13px",
                            }}
                        >
                            {cat.label}
                        </button>
                    ))}
                </div>
            </div>

            {/* Post list */}
            {loading ? (
                <div style={{ textAlign: "center", padding: "40px", color: muted }}>Loading…</div>
            ) : updates.length === 0 ? (
                <div style={{ textAlign: "center", padding: "60px", color: muted, fontSize: "16px" }}>No posts found</div>
            ) : (
                <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                    {updates.map((update) => (
                        <div key={update.id} style={{ background: card, border: `1px solid ${border}`, borderRadius: "16px", padding: "20px", position: "relative" }}>
                            {/* User info */}
                            <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "12px" }}>
                                {update.userProfileImage ? (
                                    <img src={update.userProfileImage} alt="" style={{ width: 40, height: 40, borderRadius: "50%", objectFit: "cover" }} />
                                ) : (
                                    <div style={{ width: 40, height: 40, borderRadius: "50%", background: "#00BCD4", display: "flex", alignItems: "center", justifyContent: "center", color: "#fff", fontWeight: 700, fontSize: "16px" }}>
                                        {(update.userName || "U")[0].toUpperCase()}
                                    </div>
                                )}
                                <div>
                                    <div style={{ color: text, fontWeight: 600, fontSize: "14px" }}>{update.userName || "Unknown User"}</div>
                                    <div style={{ color: muted, fontSize: "11px" }}>
                                        {update.userId} &bull; {update.category} &bull; {update.createdAt ? new Date(update.createdAt).toLocaleString() : ""}
                                    </div>
                                </div>
                            </div>

                            {/* Content */}
                            <p style={{ color: text, lineHeight: 1.6, marginBottom: "12px", whiteSpace: "pre-wrap" }}>{update.content}</p>

                            {/* Image */}
                            {update.imageUrl && (
                                <img src={update.imageUrl} alt="post" style={{ maxWidth: "100%", maxHeight: "300px", borderRadius: "12px", marginBottom: "12px", objectFit: "cover" }} />
                            )}

                            {/* Stats */}
                            <div style={{ display: "flex", gap: "16px", color: muted, fontSize: "13px", marginBottom: "16px" }}>
                                <span>❤️ {update.likesCount ?? 0} likes</span>
                                <span>💬 {update.commentsCount ?? 0} comments</span>
                            </div>

                            {/* Actions */}
                            <div style={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
                                <button
                                    onClick={() => handleHide(update.id)}
                                    disabled={actionLoading === update.id}
                                    style={{ padding: "7px 16px", borderRadius: "10px", background: "rgba(255,152,0,0.15)", color: "#FF9800", border: "1px solid rgba(255,152,0,0.3)", fontWeight: 600, cursor: "pointer", fontSize: "13px" }}
                                >
                                    🙈 Hide
                                </button>
                                <button
                                    onClick={() => handleDelete(update.id)}
                                    disabled={actionLoading === update.id}
                                    style={{ padding: "7px 16px", borderRadius: "10px", background: "rgba(244,67,54,0.15)", color: "#F44336", border: "1px solid rgba(244,67,54,0.3)", fontWeight: 600, cursor: "pointer", fontSize: "13px" }}
                                >
                                    🗑️ Delete Post
                                </button>
                                <button
                                    onClick={() => setWarningPostId(warningPostId === update.id ? null : update.id)}
                                    style={{ padding: "7px 16px", borderRadius: "10px", background: "rgba(156,39,176,0.15)", color: "#9C27B0", border: "1px solid rgba(156,39,176,0.3)", fontWeight: 600, cursor: "pointer", fontSize: "13px" }}
                                >
                                    ⚠️ Warn User
                                </button>
                            </div>

                            {/* Warn user panel */}
                            {warningPostId === update.id && (
                                <div style={{ marginTop: "12px", background: isDark ? "rgba(156,39,176,0.1)" : "rgba(156,39,176,0.05)", border: "1px solid rgba(156,39,176,0.3)", borderRadius: "12px", padding: "14px" }}>
                                    <p style={{ color: muted, fontSize: "13px", margin: "0 0 8px" }}>Custom warning message (optional):</p>
                                    <textarea
                                        placeholder="Your post violates our community guidelines…"
                                        value={warnMessage[update.id] || ""}
                                        onChange={(e) => setWarnMessage((prev) => ({ ...prev, [update.id]: e.target.value }))}
                                        rows={3}
                                        style={{ width: "100%", background: card, border: `1px solid ${border}`, borderRadius: "8px", padding: "10px", color: text, fontSize: "13px", resize: "vertical", outline: "none", boxSizing: "border-box" }}
                                    />
                                    <div style={{ display: "flex", gap: "8px", marginTop: "10px" }}>
                                        <button
                                            onClick={() => handleWarn(update.id)}
                                            disabled={actionLoading === update.id}
                                            style={{ padding: "8px 18px", borderRadius: "10px", background: "#9C27B0", color: "#fff", border: "none", fontWeight: 600, cursor: "pointer" }}
                                        >
                                            {actionLoading === update.id ? "Sending…" : "Send Warning"}
                                        </button>
                                        <button
                                            onClick={() => setWarningPostId(null)}
                                            style={{ padding: "8px 14px", borderRadius: "10px", background: card, color: muted, border: `1px solid ${border}`, cursor: "pointer" }}
                                        >
                                            Cancel
                                        </button>
                                    </div>
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            )}

            {/* Pagination */}
            {totalPages > 1 && (
                <div style={{ display: "flex", justifyContent: "center", gap: "12px", marginTop: "32px", alignItems: "center" }}>
                    <button onClick={() => setPage((p) => Math.max(0, p - 1))} disabled={page === 0} style={{ padding: "8px 18px", borderRadius: "10px", background: card, color: page === 0 ? muted : text, border: `1px solid ${border}`, cursor: page === 0 ? "not-allowed" : "pointer", fontWeight: 600 }}>
                        ← Prev
                    </button>
                    <span style={{ color: muted, fontSize: "14px" }}>Page {page + 1} of {totalPages}</span>
                    <button onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))} disabled={page >= totalPages - 1} style={{ padding: "8px 18px", borderRadius: "10px", background: card, color: page >= totalPages - 1 ? muted : text, border: `1px solid ${border}`, cursor: page >= totalPages - 1 ? "not-allowed" : "pointer", fontWeight: 600 }}>
                        Next →
                    </button>
                </div>
            )}
        </div>
    );
}
