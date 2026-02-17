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
    const [formData, setFormData] = useState({ name: "" });
    const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);

    const [emailChange, setEmailChange] = useState({ newEmail: "", otp: "", step: "idle" as "idle" | "otp" | "verifying" });
    const [passwordChange, setPasswordChange] = useState({ current: "", new: "", confirm: "", changing: false });

    useEffect(() => {
        fetchProfile();
    }, []);

    const fetchProfile = async () => {
        try {
            const response = await apiClient.get<AdminProfile>("/api/admin/profile");
            if (response.success && response.data) {
                setProfile(response.data);
                setFormData({ name: response.data.name });
            } else {
                setProfile({
                    id: currentUser?.id || "",
                    name: currentUser?.name || "Admin",
                    email: currentUser?.email || "",
                    createdAt: new Date().toISOString(),
                });
                setFormData({ name: currentUser?.name || "" });
            }
        } catch (error) {
            setProfile({
                id: currentUser?.id || "",
                name: currentUser?.name || "Admin",
                email: currentUser?.email || "",
                createdAt: new Date().toISOString(),
            });
            setFormData({ name: currentUser?.name || "" });
        } finally {
            setLoading(false);
        }
    };

    const handleSaveName = async () => {
        setSaving(true);
        setMessage(null);
        try {
            const response = await apiClient.put("/api/admin/profile", { name: formData.name });
            if (response.success) {
                setMessage({ type: "success", text: "Name updated successfully!" });
                setEditing(false);
                await fetchProfile();
            } else {
                setMessage({ type: "error", text: "Failed to update name." });
            }
        } catch {
            setMessage({ type: "error", text: "Failed to update name." });
        } finally {
            setSaving(false);
        }
    };

    const handleRequestOtp = async () => {
        if (!emailChange.newEmail) return;
        setEmailChange((prev) => ({ ...prev, step: "otp" }));
        try {
            await apiClient.post("/api/admin/request-otp", {
                email: emailChange.newEmail,
                purpose: "EMAIL_CHANGE",
            });
            setMessage({ type: "success", text: "OTP sent to your new email address." });
        } catch {
            setMessage({ type: "error", text: "Failed to send OTP." });
            setEmailChange((prev) => ({ ...prev, step: "idle" }));
        }
    };

    const handleVerifyAndChangeEmail = async () => {
        if (!emailChange.otp) return;
        setEmailChange((prev) => ({ ...prev, step: "verifying" }));
        try {
            const response = await apiClient.put("/api/admin/change-email", {
                newEmail: emailChange.newEmail,
                otp: emailChange.otp,
            });
            if (response.success) {
                setMessage({ type: "success", text: "Email changed successfully!" });
                setEmailChange({ newEmail: "", otp: "", step: "idle" });
                await fetchProfile();
            } else {
                setMessage({ type: "error", text: response.error || "Invalid or expired OTP." });
                setEmailChange((prev) => ({ ...prev, step: "otp" }));
            }
        } catch {
            setMessage({ type: "error", text: "Failed to change email." });
            setEmailChange((prev) => ({ ...prev, step: "otp" }));
        }
    };

    const handleChangePassword = async () => {
        if (passwordChange.new !== passwordChange.confirm) {
            setMessage({ type: "error", text: "New passwords do not match." });
            return;
        }
        if (passwordChange.new.length < 6) {
            setMessage({ type: "error", text: "Password must be at least 6 characters." });
            return;
        }
        setPasswordChange((prev) => ({ ...prev, changing: true }));
        try {
            const response = await apiClient.put("/api/admin/change-password", {
                currentPassword: passwordChange.current,
                newPassword: passwordChange.new,
            });
            if (response.success) {
                setMessage({ type: "success", text: "Password changed successfully!" });
                setPasswordChange({ current: "", new: "", confirm: "", changing: false });
            } else {
                setMessage({ type: "error", text: response.error || "Current password is incorrect." });
            }
        } catch {
            setMessage({ type: "error", text: "Failed to change password." });
        } finally {
            setPasswordChange((prev) => ({ ...prev, changing: false }));
        }
    };

    const inputStyle = {
        backgroundColor: isDark ? "rgba(255,255,255,0.05)" : "#f3f4f6",
        color: isDark ? "#f3f4f6" : "#1f2937",
        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
    };

    return (
        <div className="space-y-6">
            <div>
                <h2 className="text-xl font-bold" style={{ color: isDark ? "#f3f4f6" : "#1f2937" }}>
                    Admin Settings
                </h2>
                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                    Manage your admin profile and security settings
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
                            Edit Name
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
                                onChange={(e) => setFormData({ name: e.target.value })}
                                className="w-full rounded-lg p-3"
                                style={inputStyle}
                            />
                        </div>
                        <div className="flex gap-3 pt-2">
                            <Button variant="primary" onClick={handleSaveName} disabled={saving}>
                                {saving ? "Saving..." : "Save"}
                            </Button>
                            <Button variant="secondary" onClick={() => { setEditing(false); setFormData({ name: profile?.name || "" }); }}>
                                Cancel
                            </Button>
                        </div>
                    </div>
                ) : (
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
                    Change Email
                </h3>
                <p className="text-sm mb-4" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                    A verification code will be sent to your new email address.
                </p>
                <div className="space-y-3">
                    <input
                        type="email"
                        placeholder="New email address"
                        value={emailChange.newEmail}
                        onChange={(e) => setEmailChange({ ...emailChange, newEmail: e.target.value })}
                        disabled={emailChange.step !== "idle"}
                        className="w-full rounded-lg p-3"
                        style={inputStyle}
                    />
                    {emailChange.step === "otp" && (
                        <input
                            type="text"
                            placeholder="Enter 6-digit OTP"
                            value={emailChange.otp}
                            onChange={(e) => setEmailChange({ ...emailChange, otp: e.target.value })}
                            className="w-full rounded-lg p-3"
                            style={inputStyle}
                            maxLength={6}
                        />
                    )}
                    <div className="flex gap-3">
                        {emailChange.step === "idle" && (
                            <Button variant="primary" onClick={handleRequestOtp} disabled={!emailChange.newEmail}>
                                Send OTP
                            </Button>
                        )}
                        {emailChange.step === "otp" && (
                            <>
                                <Button variant="primary" onClick={handleVerifyAndChangeEmail} disabled={emailChange.otp.length !== 6}>
                                    Verify & Change
                                </Button>
                                <Button variant="secondary" onClick={() => setEmailChange({ newEmail: "", otp: "", step: "idle" })}>
                                    Cancel
                                </Button>
                            </>
                        )}
                        {emailChange.step === "verifying" && (
                            <Button variant="primary" disabled>Verifying...</Button>
                        )}
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
                    Change Password
                </h3>
                <div className="space-y-3">
                    <input
                        type="password"
                        placeholder="Current password"
                        value={passwordChange.current}
                        onChange={(e) => setPasswordChange({ ...passwordChange, current: e.target.value })}
                        className="w-full rounded-lg p-3"
                        style={inputStyle}
                    />
                    <input
                        type="password"
                        placeholder="New password"
                        value={passwordChange.new}
                        onChange={(e) => setPasswordChange({ ...passwordChange, new: e.target.value })}
                        className="w-full rounded-lg p-3"
                        style={inputStyle}
                    />
                    <input
                        type="password"
                        placeholder="Confirm new password"
                        value={passwordChange.confirm}
                        onChange={(e) => setPasswordChange({ ...passwordChange, confirm: e.target.value })}
                        className="w-full rounded-lg p-3"
                        style={inputStyle}
                    />
                    <Button
                        variant="primary"
                        onClick={handleChangePassword}
                        disabled={passwordChange.changing || !passwordChange.current || !passwordChange.new || !passwordChange.confirm}
                    >
                        {passwordChange.changing ? "Changing..." : "Change Password"}
                    </Button>
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
                </div>
            </div>
        </div>
    );
}
