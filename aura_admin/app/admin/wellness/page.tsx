"use client";

import { useState, useEffect, useCallback } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";
import { wellnessService } from "@/app/modules/wellness/services/wellness.service";
import { WellnessUpdate, WellnessCategory, WellnessStats } from "@/app/modules/wellness/models/wellness.model";

export default function WellnessPage() {
    const { isDark } = useTheme();
    const [updates, setUpdates] = useState<WellnessUpdate[]>([]);
    const [stats, setStats] = useState<WellnessStats | null>(null);
    const [loading, setLoading] = useState(true);
    const [view, setView] = useState<"pending" | "all">("pending");
    const [categoryFilter, setCategoryFilter] = useState<WellnessCategory | "ALL">("ALL");
    const [page, setPage] = useState(0);
    const [totalPages, setTotalPages] = useState(0);

    const fetchUpdates = useCallback(async () => {
        try {
            setLoading(true);
            const response = view === "pending"
                ? await wellnessService.getPendingUpdates(page, 20)
                : await wellnessService.getAllUpdates(page, 20, categoryFilter === "ALL" ? undefined : categoryFilter);
            setUpdates(response.content);
            setTotalPages(response.totalPages);
        } catch (error) {
            console.error("Failed to fetch updates:", error);
        } finally {
            setLoading(false);
        }
    }, [page, view, categoryFilter]);

    const fetchStats = useCallback(async () => {
        try {
            const data = await wellnessService.getStats();
            setStats(data);
        } catch (error) {
            console.error("Failed to fetch stats:", error);
        }
    }, []);

    useEffect(() => {
        fetchUpdates();
        fetchStats();
    }, [fetchUpdates, fetchStats]);

    const handleApprove = async (id: string) => {
        try {
            await wellnessService.approveUpdate(id);
            fetchUpdates();
            fetchStats();
        } catch (error) {
            console.error("Failed to approve:", error);
        }
    };

    const handleReject = async (id: string) => {
        try {
            await wellnessService.rejectUpdate(id);
            fetchUpdates();
            fetchStats();
        } catch (error) {
            console.error("Failed to reject:", error);
        }
    };

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this update?")) return;
        try {
            await wellnessService.deleteUpdate(id);
            fetchUpdates();
            fetchStats();
        } catch (error) {
            console.error("Failed to delete:", error);
        }
    };

    const categories: (WellnessCategory | "ALL")[] = ["ALL", "PROGRESS", "MOTIVATION", "TIP", "ACHIEVEMENT", "GENERAL"];

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 className="text-2xl font-bold" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                        ✨ Wellness Feed
                    </h1>
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                        Moderate and manage wellness updates
                    </p>
                </div>
            </div>

            {stats && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <StatCard title="Pending" value={stats.pendingUpdates} icon="⏳" color="yellow" isDark={isDark} />
                    <StatCard title="Approved" value={stats.approvedUpdates} icon="✅" color="green" isDark={isDark} />
                    <StatCard title="Today" value={stats.todayUpdates} icon="📅" color="blue" isDark={isDark} />
                    <StatCard title="Total" value={stats.totalUpdates} icon="📊" color="purple" isDark={isDark} />
                </div>
            )}

            <div className="flex flex-wrap gap-4" style={{ borderBottom: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`, paddingBottom: 16 }}>
                <div className="flex gap-2">
                    <button
                        onClick={() => { setView("pending"); setPage(0); }}
                        className="px-4 py-2 rounded-lg text-sm font-medium transition-all"
                        style={{
                            backgroundColor: view === "pending" ? appColors.accent : isDark ? "#374151" : "#f3f4f6",
                            color: view === "pending" ? "white" : isDark ? "#f3f4f6" : "#1f2937",
                        }}
                    >
                        Pending Review
                    </button>
                    <button
                        onClick={() => { setView("all"); setPage(0); }}
                        className="px-4 py-2 rounded-lg text-sm font-medium transition-all"
                        style={{
                            backgroundColor: view === "all" ? appColors.accent : isDark ? "#374151" : "#f3f4f6",
                            color: view === "all" ? "white" : isDark ? "#f3f4f6" : "#1f2937",
                        }}
                    >
                        All Updates
                    </button>
                </div>
                {view === "all" && (
                    <div className="flex gap-2 flex-wrap">
                        {categories.map((cat) => (
                            <button
                                key={cat}
                                onClick={() => { setCategoryFilter(cat); setPage(0); }}
                                className="px-3 py-1.5 rounded-lg text-xs font-medium transition-all"
                                style={{
                                    backgroundColor: categoryFilter === cat ? appColors.accent : isDark ? "#374151" : "#f3f4f6",
                                    color: categoryFilter === cat ? "white" : isDark ? "#f3f4f6" : "#1f2937",
                                }}
                            >
                                {cat === "ALL" ? "All" : `${wellnessService.getCategoryEmoji(cat)} ${cat}`}
                            </button>
                        ))}
                    </div>
                )}
            </div>

            <div className="rounded-xl overflow-hidden" style={{ backgroundColor: isDark ? appColors.cardBg : "white", border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}>
                {loading ? (
                    <div className="p-8 text-center">
                        <div className="animate-spin text-4xl mb-2">⏳</div>
                        <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Loading...</p>
                    </div>
                ) : updates.length === 0 ? (
                    <div className="p-8 text-center">
                        <div className="text-4xl mb-2">📭</div>
                        <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>No updates found</p>
                    </div>
                ) : (
                    <div className="divide-y" style={{ borderColor: isDark ? appColors.cardBorder : "#e5e7eb" }}>
                        {updates.map((update) => (
                            <div key={update.id} className="p-4">
                                <div className="flex items-start gap-4">
                                    <div className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold" style={{ backgroundColor: appColors.accent }}>
                                        {update.userName?.charAt(0).toUpperCase() || "?"}
                                    </div>
                                    <div className="flex-1">
                                        <div className="flex items-center gap-2 mb-1">
                                            <span className="font-medium" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                                                {update.userName || `User ${update.userId.slice(0, 8)}`}
                                            </span>
                                            <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${wellnessService.getCategoryColor(update.category)}`}>
                                                {wellnessService.getCategoryEmoji(update.category)} {update.category}
                                            </span>
                                            <span className="text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                                {wellnessService.getTimeAgo(update.createdAt)}
                                            </span>
                                        </div>
                                        <p className="mb-2" style={{ color: isDark ? "#e5e7eb" : "#374151" }}>{update.content}</p>
                                        <div className="flex items-center gap-2 text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                            <span>❤️ {update.likesCount}</span>
                                            {update.isApproved && <span className="text-green-500">✓ Approved</span>}
                                        </div>
                                    </div>
                                    <div className="flex gap-2">
                                        {!update.isApproved && (
                                            <>
                                                <button onClick={() => handleApprove(update.id)} className="px-3 py-1.5 rounded-lg text-sm font-medium bg-green-500 text-white hover:bg-green-600">
                                                    Approve
                                                </button>
                                                <button onClick={() => handleReject(update.id)} className="px-3 py-1.5 rounded-lg text-sm font-medium bg-yellow-500 text-white hover:bg-yellow-600">
                                                    Reject
                                                </button>
                                            </>
                                        )}
                                        <button onClick={() => handleDelete(update.id)} className="px-3 py-1.5 rounded-lg text-sm font-medium bg-red-500 text-white hover:bg-red-600">
                                            Delete
                                        </button>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}

                {totalPages > 1 && (
                    <div className="p-4 flex justify-center gap-2" style={{ borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}>
                        <button
                            onClick={() => setPage((p) => Math.max(0, p - 1))}
                            disabled={page === 0}
                            className="px-4 py-2 rounded-lg disabled:opacity-50"
                            style={{ backgroundColor: isDark ? "#374151" : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937" }}
                        >
                            Previous
                        </button>
                        <span className="px-4 py-2" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                            Page {page + 1} of {totalPages}
                        </span>
                        <button
                            onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                            disabled={page >= totalPages - 1}
                            className="px-4 py-2 rounded-lg disabled:opacity-50"
                            style={{ backgroundColor: isDark ? "#374151" : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937" }}
                        >
                            Next
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
}

function StatCard({ title, value, icon, color, isDark }: { title: string; value: number; icon: string; color: string; isDark: boolean }) {
    const colorMap: Record<string, string> = {
        yellow: isDark ? "rgba(234, 179, 8, 0.2)" : "rgba(254, 249, 195, 1)",
        green: isDark ? "rgba(34, 197, 94, 0.2)" : "rgba(220, 252, 231, 1)",
        blue: isDark ? "rgba(59, 130, 246, 0.2)" : "rgba(219, 234, 254, 1)",
        purple: isDark ? "rgba(139, 92, 246, 0.2)" : "rgba(237, 233, 254, 1)",
    };
    return (
        <div className="p-4 rounded-xl" style={{ backgroundColor: colorMap[color] || (isDark ? appColors.cardBg : "white"), border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}>
            <div className="flex items-center gap-3">
                <span className="text-2xl">{icon}</span>
                <div>
                    <p className="text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>{title}</p>
                    <p className="text-2xl font-bold" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>{value}</p>
                </div>
            </div>
        </div>
    );
}
