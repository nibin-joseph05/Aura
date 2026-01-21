"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { adminAuthService } from "@/app/modules/auth/services/admin-auth.service";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import PageLoader from "@/app/components/loaders/PageLoader";
import Sidebar from "@/app/components/layout/Sidebar";
import AdminHeader from "@/app/components/layout/AdminHeader";
import Button from "@/app/components/ui/Button";
import { appColors } from "@/app/core/constants/colors";
import { apiClient } from "@/app/core/network/api-client";
import { API_ENDPOINTS } from "@/app/core/network/api-endpoints";

interface GymExercise {
    id: string;
    name: string;
    targetMuscle: string;
    machineName: string;
    imageUrl: string;
    description: string;
    isActive: boolean;
}

const MUSCLE_GROUPS = ["Chest", "Back", "Shoulders", "Arms", "Legs", "Core", "Full Body"];

export default function GymExercisesPage() {
    const router = useRouter();
    const { isDark } = useTheme();
    const [isLoading, setIsLoading] = useState(true);
    const [exercises, setExercises] = useState<GymExercise[]>([]);
    const [searchQuery, setSearchQuery] = useState("");
    const [showAddModal, setShowAddModal] = useState(false);
    const [editingExercise, setEditingExercise] = useState<GymExercise | null>(null);
    const [formData, setFormData] = useState({
        name: "",
        targetMuscle: "",
        machineName: "",
        imageUrl: "",
        description: "",
    });
    const [saving, setSaving] = useState(false);

    useEffect(() => {
        const init = async () => {
            if (!adminAuthService.isAuthenticated()) {
                router.push("/admin/login");
                return;
            }
            await fetchExercises();
            setIsLoading(false);
        };
        init();
    }, [router]);

    const fetchExercises = async () => {
        const response = await apiClient.get<GymExercise[]>(API_ENDPOINTS.GYM_EXERCISES.BASE);
        if (response.success && response.data) {
            setExercises(response.data);
        }
    };

    const filteredExercises = exercises.filter(ex =>
        ex.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        ex.targetMuscle?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        ex.machineName?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const handleSave = async () => {
        if (!formData.name.trim()) return;
        setSaving(true);

        if (editingExercise) {
            const response = await apiClient.put(
                API_ENDPOINTS.GYM_EXERCISES.BY_ID(editingExercise.id),
                formData
            );
            if (response.success) {
                await fetchExercises();
                closeModal();
            }
        } else {
            const response = await apiClient.post(API_ENDPOINTS.GYM_EXERCISES.BASE, formData);
            if (response.success) {
                await fetchExercises();
                closeModal();
            }
        }
        setSaving(false);
    };

    const handleToggle = async (id: string) => {
        await apiClient.patch(API_ENDPOINTS.GYM_EXERCISES.TOGGLE(id), {});
        await fetchExercises();
    };

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this exercise?")) return;
        await apiClient.delete(API_ENDPOINTS.GYM_EXERCISES.BY_ID(id));
        await fetchExercises();
    };

    const openEdit = (exercise: GymExercise) => {
        setEditingExercise(exercise);
        setFormData({
            name: exercise.name,
            targetMuscle: exercise.targetMuscle || "",
            machineName: exercise.machineName || "",
            imageUrl: exercise.imageUrl || "",
            description: exercise.description || "",
        });
        setShowAddModal(true);
    };

    const closeModal = () => {
        setShowAddModal(false);
        setEditingExercise(null);
        setFormData({ name: "", targetMuscle: "", machineName: "", imageUrl: "", description: "" });
    };

    if (isLoading) {
        return <PageLoader message="Loading exercises..." />;
    }

    return (
        <div
            className="min-h-screen transition-colors duration-500"
            style={{ backgroundColor: isDark ? appColors.splashDark : "#f0f4f8" }}
        >
            <Sidebar />

            <div className="ml-0 transition-all duration-300 md:ml-[80px] lg:ml-[260px]">
                <div
                    className="sticky top-0 z-30 p-4 md:p-6"
                    style={{ backgroundColor: isDark ? appColors.splashDark : "#f0f4f8" }}
                >
                    <AdminHeader title="Gym Exercises" onSearch={setSearchQuery} />
                </div>

                <main className="p-4 pt-0 md:p-6 md:pt-0">
                    <div className="mx-auto max-w-7xl">
                        <div className="flex items-center justify-between mb-6">
                            <div>
                                <h2 style={{ color: isDark ? "white" : "#1f2937" }} className="text-xl font-bold">
                                    Manage Exercises
                                </h2>
                                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                                    Define gym exercises with muscle groups and machines
                                </p>
                            </div>
                            <Button variant="primary" onClick={() => setShowAddModal(true)}>
                                + Add Exercise
                            </Button>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                            {filteredExercises.map((exercise) => (
                                <div
                                    key={exercise.id}
                                    className="rounded-xl p-5 shadow-lg transition-all duration-300 hover:-translate-y-1"
                                    style={{
                                        backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                                        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                                    }}
                                >
                                    <div className="flex items-start gap-3 mb-3">
                                        <span className="text-3xl">🏋️</span>
                                        <div className="flex-1">
                                            <h3 style={{ color: isDark ? "white" : "#1f2937" }} className="font-bold">
                                                {exercise.name}
                                            </h3>
                                            {exercise.targetMuscle && (
                                                <span
                                                    className="inline-block text-xs px-2 py-0.5 rounded-full mt-1"
                                                    style={{ backgroundColor: `${appColors.accent}20`, color: appColors.accent }}
                                                >
                                                    {exercise.targetMuscle}
                                                </span>
                                            )}
                                            {exercise.machineName && (
                                                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="text-sm mt-1">
                                                    Machine: {exercise.machineName}
                                                </p>
                                            )}
                                        </div>
                                    </div>

                                    {exercise.description && (
                                        <p
                                            style={{ color: isDark ? "#6b7280" : "#9ca3af" }}
                                            className="text-sm mb-3 line-clamp-2"
                                        >
                                            {exercise.description}
                                        </p>
                                    )}

                                    <div
                                        className="flex items-center justify-between pt-3"
                                        style={{ borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}
                                    >
                                        <div className="flex items-center gap-2">
                                            <button
                                                onClick={() => handleToggle(exercise.id)}
                                                className="relative inline-flex h-6 w-11 items-center rounded-full transition-colors duration-200"
                                                style={{
                                                    backgroundColor: exercise.isActive ? appColors.success : (isDark ? "#4b5563" : "#d1d5db"),
                                                }}
                                            >
                                                <span
                                                    className="inline-block h-4 w-4 transform rounded-full bg-white transition-transform duration-200"
                                                    style={{
                                                        transform: exercise.isActive ? "translateX(1.375rem)" : "translateX(0.25rem)",
                                                    }}
                                                />
                                            </button>
                                            <span
                                                className="text-sm"
                                                style={{ color: exercise.isActive ? appColors.success : (isDark ? "#9ca3af" : "#6b7280") }}
                                            >
                                                {exercise.isActive ? "Active" : "Inactive"}
                                            </span>
                                        </div>

                                        <div className="flex gap-2">
                                            <button onClick={() => openEdit(exercise)} className="p-2 rounded-lg hover:bg-white/10">
                                                ✏️
                                            </button>
                                            <button
                                                onClick={() => handleDelete(exercise.id)}
                                                className="p-2 rounded-lg hover:bg-white/10"
                                                style={{ color: appColors.error }}
                                            >
                                                🗑️
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>

                        {filteredExercises.length === 0 && (
                            <div className="text-center py-12" style={{ color: isDark ? "#6b7280" : "#9ca3af" }}>
                                <span className="text-4xl block mb-4">🏋️</span>
                                <p>No exercises found. Add your first gym exercise!</p>
                            </div>
                        )}
                    </div>
                </main>
            </div>

            {showAddModal && (
                <div
                    className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
                    onClick={closeModal}
                >
                    <div
                        className="rounded-xl p-6 shadow-2xl w-full max-w-md max-h-[90vh] overflow-y-auto"
                        style={{
                            backgroundColor: isDark ? appColors.splashDark : "white",
                            border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                        }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        <h3 style={{ color: isDark ? "white" : "#1f2937" }} className="text-xl font-bold mb-4">
                            {editingExercise ? "Edit Exercise" : "Add Exercise"}
                        </h3>

                        <div className="space-y-4">
                            <div>
                                <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">
                                    Name *
                                </label>
                                <input
                                    type="text"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    className="w-full rounded-lg p-3"
                                    style={{
                                        backgroundColor: isDark ? appColors.cardBg : "#f3f4f6",
                                        color: isDark ? "white" : "#1f2937",
                                        border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}`,
                                    }}
                                    placeholder="e.g., Bench Press"
                                />
                            </div>

                            <div>
                                <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">
                                    Target Muscle
                                </label>
                                <select
                                    value={formData.targetMuscle}
                                    onChange={(e) => setFormData({ ...formData, targetMuscle: e.target.value })}
                                    className="w-full rounded-lg p-3"
                                    style={{
                                        backgroundColor: isDark ? appColors.cardBg : "#f3f4f6",
                                        color: isDark ? "white" : "#1f2937",
                                        border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}`,
                                    }}
                                >
                                    <option value="">Select muscle group</option>
                                    {MUSCLE_GROUPS.map(muscle => (
                                        <option key={muscle} value={muscle}>{muscle}</option>
                                    ))}
                                </select>
                            </div>

                            <div>
                                <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">
                                    Machine Name
                                </label>
                                <input
                                    type="text"
                                    value={formData.machineName}
                                    onChange={(e) => setFormData({ ...formData, machineName: e.target.value })}
                                    className="w-full rounded-lg p-3"
                                    style={{
                                        backgroundColor: isDark ? appColors.cardBg : "#f3f4f6",
                                        color: isDark ? "white" : "#1f2937",
                                        border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}`,
                                    }}
                                    placeholder="e.g., Smith Machine"
                                />
                            </div>

                            <div>
                                <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">
                                    Description
                                </label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    className="w-full rounded-lg p-3 resize-none"
                                    rows={3}
                                    style={{
                                        backgroundColor: isDark ? appColors.cardBg : "#f3f4f6",
                                        color: isDark ? "white" : "#1f2937",
                                        border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}`,
                                    }}
                                    placeholder="How to perform this exercise..."
                                />
                            </div>
                        </div>

                        <div className="flex justify-end gap-3 mt-6">
                            <Button variant="secondary" onClick={closeModal}>
                                Cancel
                            </Button>
                            <Button variant="primary" onClick={handleSave} disabled={saving || !formData.name.trim()}>
                                {saving ? "Saving..." : "Save"}
                            </Button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
