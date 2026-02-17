"use client";

import { useState, useEffect, useCallback } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";
import { apiClient } from "@/app/core/network/api-client";
import { API_ENDPOINTS } from "@/app/core/network/api-endpoints";

interface User {
    uid: string;
    name: string;
    email: string;
    username: string;
    phone: string | null;
    profileImageUrl: string | null;
    profileCompleted: boolean;
    createdAt: string;
    lastLoginAt: string | null;
}

interface PaginatedResponse<T> {
    content: T[];
    totalPages: number;
    totalElements: number;
}

export default function UsersPage() {
    const { isDark } = useTheme();
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");
    const [page, setPage] = useState(0);
    const [totalPages, setTotalPages] = useState(0);
    const [totalElements, setTotalElements] = useState(0);

    const fetchUsers = useCallback(async () => {
        try {
            setLoading(true);
            const response = await apiClient.get<{ success: boolean; data: PaginatedResponse<User> }>(
                `${API_ENDPOINTS.USERS.BASE}?page=${page}&size=20&search=${encodeURIComponent(searchTerm)}`
            );

            if (response.success && response.data) {
                const payload = response.data;
                const pageData = payload.data || payload;
                setUsers(Array.isArray(pageData.content) ? pageData.content : []);
                setTotalPages(pageData.totalPages || 0);
                setTotalElements(pageData.totalElements || 0);
            } else {
                setUsers([]);
            }
        } catch (error) {
            console.error("Failed to fetch users:", error);
            setUsers([]);
        } finally {
            setLoading(false);
        }
    }, [page, searchTerm]);

    useEffect(() => {
        fetchUsers();
    }, [fetchUsers]);

    const formatDate = (dateString: string | null) => {
        if (!dateString) return "-";
        return new Date(dateString).toLocaleDateString("en-US", {
            year: "numeric",
            month: "short",
            day: "numeric",
        });
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h2 className="text-xl font-bold" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                        Manage Users
                    </h2>
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                        {totalElements > 0 ? `${totalElements} registered users` : "View and manage registered users"}
                    </p>
                </div>

                <input
                    type="text"
                    placeholder="Search by name, email, username..."
                    value={searchTerm}
                    onChange={(e) => { setSearchTerm(e.target.value); setPage(0); }}
                    className="px-4 py-2.5 rounded-xl outline-none transition-all w-full sm:w-72"
                    style={{
                        backgroundColor: isDark ? appColors.cardBg : "#f3f4f6",
                        color: isDark ? "#f3f4f6" : "#1f2937",
                        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                    }}
                />
            </div>

            <div
                className="rounded-xl overflow-hidden"
                style={{
                    backgroundColor: isDark ? appColors.cardBg : "white",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                }}
            >
                {loading ? (
                    <div className="p-12 text-center">
                        <div className="animate-spin text-4xl mb-3">⏳</div>
                        <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Loading users...</p>
                    </div>
                ) : users.length === 0 ? (
                    <div className="p-12 text-center">
                        <span className="text-5xl mb-4 block">👥</span>
                        <p className="text-lg font-medium mb-1" style={{ color: isDark ? "#d1d5db" : "#374151" }}>
                            {searchTerm ? `No users matching "${searchTerm}"` : "No users registered yet"}
                        </p>
                        <p className="text-sm" style={{ color: isDark ? "#6b7280" : "#9ca3af" }}>
                            Users will appear here once they sign up.
                        </p>
                    </div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr style={{ backgroundColor: isDark ? "rgba(255,255,255,0.04)" : "#f9fafb" }}>
                                    <th className="text-left px-5 py-3.5 font-medium text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                        User
                                    </th>
                                    <th className="text-left px-5 py-3.5 font-medium text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                        Username
                                    </th>
                                    <th className="text-left px-5 py-3.5 font-medium text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                        Phone
                                    </th>
                                    <th className="text-left px-5 py-3.5 font-medium text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                        Status
                                    </th>
                                    <th className="text-left px-5 py-3.5 font-medium text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                        Joined
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                {users.map((user, index) => (
                                    <tr
                                        key={user.uid}
                                        className="transition-colors"
                                        style={{
                                            borderTop: index > 0 ? `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` : undefined,
                                        }}
                                        onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = isDark ? appColors.cardBgHover : "#f9fafb")}
                                        onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = "transparent")}
                                    >
                                        <td className="px-5 py-4">
                                            <div className="flex items-center gap-3">
                                                <div
                                                    className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold text-sm"
                                                    style={{ backgroundColor: appColors.accent }}
                                                >
                                                    {(user.name || user.email || "?").charAt(0).toUpperCase()}
                                                </div>
                                                <div>
                                                    <p className="font-medium" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                                                        {user.name || "Unnamed User"}
                                                    </p>
                                                    <p className="text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                                        {user.email || "-"}
                                                    </p>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-5 py-4">
                                            <span className="font-medium" style={{ color: appColors.accent }}>
                                                {user.username ? `@${user.username}` : "-"}
                                            </span>
                                        </td>
                                        <td className="px-5 py-4">
                                            <span style={{ color: isDark ? "#e5e7eb" : "#1f2937" }}>
                                                {user.phone || "-"}
                                            </span>
                                        </td>
                                        <td className="px-5 py-4">
                                            <span
                                                className="px-2.5 py-1 rounded-full text-xs font-semibold"
                                                style={{
                                                    backgroundColor: user.profileCompleted
                                                        ? "rgba(34,197,94,0.15)"
                                                        : "rgba(234,179,8,0.15)",
                                                    color: user.profileCompleted ? "#22c55e" : "#eab308",
                                                }}
                                            >
                                                {user.profileCompleted ? "Complete" : "Incomplete"}
                                            </span>
                                        </td>
                                        <td className="px-5 py-4">
                                            <span className="text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                                {formatDate(user.createdAt)}
                                            </span>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}

                {totalPages > 1 && (
                    <div className="p-4 flex justify-center items-center gap-3" style={{ borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}>
                        <button
                            onClick={() => setPage((p) => Math.max(0, p - 1))}
                            disabled={page === 0}
                            className="px-4 py-2 rounded-lg text-sm font-medium disabled:opacity-40 transition-all"
                            style={{ backgroundColor: isDark ? appColors.cardBgHover : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937" }}
                        >
                            ← Previous
                        </button>
                        <span className="px-4 py-2 text-sm font-medium" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                            Page {page + 1} of {totalPages}
                        </span>
                        <button
                            onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                            disabled={page >= totalPages - 1}
                            className="px-4 py-2 rounded-lg text-sm font-medium disabled:opacity-40 transition-all"
                            style={{ backgroundColor: isDark ? appColors.cardBgHover : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937" }}
                        >
                            Next →
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
}
