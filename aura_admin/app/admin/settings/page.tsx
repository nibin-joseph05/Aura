"use client";

import { useState, useEffect } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import { appColors } from "@/app/core/constants/colors";
import { authStorage } from "@/app/modules/auth/services/auth-storage";
import { apiClient } from "@/app/core/network/api-client";
import Button from "@/app/components/ui/Button";

interface AdminProfile {
    id: string;
    name: string;
    email: string;
    createdAt: string;
}

export default function SettingsPage() {
    const { isDark } = useTheme();
    const currentUser = authStorage.getUser();
    const [profile, setProfile] = useState<AdminProfile | null>(null);
    const [loading, setLoading] = useState(true);
    const [editing, setEditing] = useState(false);
    const [saving, setSaving] = useState(false);
    const [formData, setFormData] = useState({ name: "", email: "" });
    const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);

    useEffect(() => {
        fetchProfile();
    }, []);

    const fetchProfile = async () => {
        try {
            const response = await apiClient.get<AdminProfile>("/api/admin/profile");
            if (response.success && response.data) {
                setProfile(response.data);
                setFormData({ name: response.data.name, email: response.data.email });
            } else {
                setProfile({
                    id: currentUser?.adminId || "",
                    name: currentUser?.name || "Admin",
                    email: currentUser?.email || "",
                    createdAt: new Date().toISOString(),
                });
                setFormData({ name: currentUser?.name || "", email: currentUser?.email || "" });
            }
        } catch (error) {
            console.error("Failed to fetch profile:", error);
            setProfile({
                id: currentUser?.adminId || "",
                name: currentUser?.name || "Admin",
                email: currentUser?.email || "",
                createdAt: new Date().toISOString(),
            });
            setFormData({ name: currentUser?.name || "", email: currentUser?.email || "" });
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        setSaving(true);
        setMessage(null);
        try {
            const response = await apiClient.put("/api/admin/profile", formData);
            if (response.success) {
                setMessage({ type: "success", text: "Profile updated successfully!" });
                setEditing(false);
                await fetchProfile();
            } else {
                setMessage({ type: "error", text: "Failed to update profile. Please try again." });
            }
        } catch (error) {
            setMessage({ type: "error", text: "Failed to update profile. Please try again." });
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="space-y-6">
            <div>
                <h2 className="text-xl font-bold" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                    Admin Settings
                </h2>
                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                    Manage your admin profile and preferences
                </p>
            </div>

            {message && (
                <div
                    className="p-4 rounded-xl"
                    style={{
                        backgroundColor: message.type === "success" ? "rgba(34,197,94,0.1)" : "rgba(239,68,68,0.1)",
                        border: `1px solid ${message.type === "success" ? "#22c55e" : "#ef4444"}`,
                        color: message.type === "success" ? "#22c55e" : "#ef4444",
                    }}
                >
                    {message.text}
                </div>
            )}

            <div
                className="rounded-xl p-6"
                style={{
                    backgroundColor: isDark ? appColors.cardBg : "white",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                }}
            >
                <div className="flex items-center justify-between mb-6">
                    <h3 className="text-lg font-semibold" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                        Profile Information
                    </h3>
                    {!editing && (
                        <Button variant="secondary" onClick={() => setEditing(true)}>
                            Edit Profile
                        </Button>
                    )}
                </div>

                {loading ? (
                    <div className="p-8 text-center">
                        <div className="animate-spin text-4xl mb-2">⏳</div>
                        <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Loading profile...</p>
                    </div>
                ) : editing ? (
                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm mb-2" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                Name
                            </label>
                            <input
                                type="text"
                                value={formData.name}
                                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                className="w-full rounded-lg p-3"
                                style={{
                                    backgroundColor: isDark ? "rgba(255,255,255,0.05)" : "#f3f4f6",
                                    color: isDark ? "#f3f4f6" : "#1f2937",
                                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                                }}
                            />
                        </div>
                        <div>
                            <label className="block text-sm mb-2" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                Email
                            </label>
                            <input
                                type="email"
                                value={formData.email}
                                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                className="w-full rounded-lg p-3"
                                style={{
                                    backgroundColor: isDark ? "rgba(255,255,255,0.05)" : "#f3f4f6",
                                    color: isDark ? "#f3f4f6" : "#1f2937",
                                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                                }}
                            />
                            <p className="text-xs mt-1" style={{ color: isDark ? "#6b7280" : "#9ca3af" }}>
                                Email changes require verification
                            </p>
                        </div>
                        <div className="flex gap-3 pt-4">
                            <Button variant="primary" onClick={handleSave} disabled={saving}>
                                {saving ? "Saving..." : "Save Changes"}
                            </Button>
                            <Button variant="secondary" onClick={() => { setEditing(false); setFormData({ name: profile?.name || "", email: profile?.email || "" }); }}>
                                Cancel
                            </Button>
                        </div>
                    </div>
                ) : (
                    <div className="space-y-4">
                        <div className="flex items-center gap-4">
                            <div
                                className="w-16 h-16 rounded-full flex items-center justify-center text-2xl font-bold text-white"
                                style={{ backgroundColor: appColors.accent }}
                            >
                                {(profile?.name || "A").charAt(0).toUpperCase()}
                            </div>
                            <div>
                                <p className="text-lg font-semibold" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                                    {profile?.name || "Admin"}
                                </p>
                                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                    {profile?.email || "-"}
                                </p>
                            </div>
                        </div>
                    </div>
                )}
            </div>

            <div
                className="rounded-xl p-6"
                style={{
                    backgroundColor: isDark ? appColors.cardBg : "white",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                }}
            >
                <h3 className="text-lg font-semibold mb-4" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                    System Information
                </h3>
                <div className="space-y-4">
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="font-medium" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>Version</p>
                            <p className="text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Current admin panel version</p>
                        </div>
                        <span
                            className="px-3 py-1 rounded-lg text-sm"
                            style={{ backgroundColor: `${appColors.accent}20`, color: appColors.accent }}
                        >
                            v1.0.0
                        </span>
                    </div>
                    <div className="h-px" style={{ backgroundColor: isDark ? appColors.cardBorder : "#e5e7eb" }} />
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="font-medium" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>API Status</p>
                            <p className="text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Backend connection</p>
                        </div>
                        <span
                            className="px-3 py-1 rounded-lg text-sm"
                            style={{ backgroundColor: "rgba(34,197,94,0.1)", color: "#22c55e" }}
                        >
                            Connected
                        </span>
                    </div>
                    <div className="h-px" style={{ backgroundColor: isDark ? appColors.cardBorder : "#e5e7eb" }} />
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="font-medium" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>Environment</p>
                            <p className="text-sm" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Current deployment</p>
                        </div>
                        <span
                            className="px-3 py-1 rounded-lg text-sm"
                            style={{ backgroundColor: "rgba(234,179,8,0.1)", color: "#eab308" }}
                        >
                            Development
                        </span>
                    </div>
                </div>
            </div>

            <div
                className="rounded-xl p-6"
                style={{
                    backgroundColor: isDark ? appColors.cardBg : "white",
                    border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                }}
            >
                <h3 className="text-lg font-semibold mb-4" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                    About Aura Admin
                </h3>
                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                    Aura Admin Panel is the management dashboard for the Aura wellness & safety application.
                    Monitor SOS alerts, moderate wellness content, manage categories, and oversee user activity.
                </p>
            </div>
        </div>
    );
}
