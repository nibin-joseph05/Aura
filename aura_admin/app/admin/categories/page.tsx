"use client";

import { useEffect, useState, useCallback } from "react";
import { useTheme } from "@/app/core/providers/ThemeProvider";
import Button from "@/app/components/ui/Button";
import { appColors } from "@/app/core/constants/colors";
import { apiClient } from "@/app/core/network/api-client";
import { API_ENDPOINTS } from "@/app/core/network/api-endpoints";

interface ActivityCategory {
    id: string;
    name: string;
    description: string;
    isActive: boolean;
    createdAt: string;
    updatedAt: string;
}

export default function CategoriesPage() {
    const { isDark } = useTheme();
    const [categories, setCategories] = useState<ActivityCategory[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");
    const [showAddModal, setShowAddModal] = useState(false);
    const [editingCategory, setEditingCategory] = useState<ActivityCategory | null>(null);
    const [formData, setFormData] = useState({ name: "", description: "" });
    const [saving, setSaving] = useState(false);

    const fetchCategories = useCallback(async () => {
        try {
            setLoading(true);
            const response = await apiClient.get<ActivityCategory[]>(API_ENDPOINTS.ACTIVITY_CATEGORIES.BASE);
            if (response.success && response.data) {
                setCategories(response.data);
            }
        } catch (error) {
            console.error("Failed to fetch categories:", error);
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchCategories();
    }, [fetchCategories]);

    const filteredCategories = categories.filter(cat =>
        cat.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        cat.description?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const handleSave = async () => {
        if (!formData.name.trim()) return;
        setSaving(true);

        try {
            if (editingCategory) {
                const response = await apiClient.put(
                    API_ENDPOINTS.ACTIVITY_CATEGORIES.BY_ID(editingCategory.id),
                    formData
                );
                if (response.success) {
                    await fetchCategories();
                    closeModal();
                }
            } else {
                const response = await apiClient.post(API_ENDPOINTS.ACTIVITY_CATEGORIES.BASE, formData);
                if (response.success) {
                    await fetchCategories();
                    closeModal();
                }
            }
        } catch (error) {
            console.error("Failed to save category:", error);
        } finally {
            setSaving(false);
        }
    };

    const handleToggle = async (id: string) => {
        await apiClient.patch(API_ENDPOINTS.ACTIVITY_CATEGORIES.TOGGLE(id), {});
        await fetchCategories();
    };

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this category?")) return;
        await apiClient.delete(API_ENDPOINTS.ACTIVITY_CATEGORIES.BY_ID(id));
        await fetchCategories();
    };

    const openEdit = (category: ActivityCategory) => {
        setEditingCategory(category);
        setFormData({ name: category.name, description: category.description || "" });
        setShowAddModal(true);
    };

    const closeModal = () => {
        setShowAddModal(false);
        setEditingCategory(null);
        setFormData({ name: "", description: "" });
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 style={{ color: isDark ? "#f3f4f6" : "#1f2937" }} className="text-xl font-bold">
                        Manage Categories
                    </h2>
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                        Group activity types into categories
                    </p>
                </div>
                <div className="flex gap-3">
                    <input
                        type="text"
                        placeholder="Search categories..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="px-4 py-2 rounded-lg text-sm"
                        style={{
                            backgroundColor: isDark ? appColors.cardBg : "#f3f4f6",
                            color: isDark ? "#f3f4f6" : "#1f2937",
                            border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                        }}
                    />
                    <Button variant="primary" onClick={() => setShowAddModal(true)}>
                        + Add Category
                    </Button>
                </div>
            </div>

            {loading ? (
                <div className="p-8 text-center">
                    <div className="animate-spin text-4xl mb-2">⏳</div>
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Loading categories...</p>
                </div>
            ) : filteredCategories.length === 0 ? (
                <div
                    className="text-center py-12 rounded-xl"
                    style={{
                        backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                    }}
                >
                    <span className="text-4xl block mb-4">📂</span>
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                        No categories found. Create your first category!
                    </p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {filteredCategories.map((category) => (
                        <div
                            key={category.id}
                            className="rounded-xl p-5 shadow-lg transition-all duration-300 hover:-translate-y-1"
                            style={{
                                backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                                border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                            }}
                        >
                            <div className="flex items-start justify-between mb-3">
                                <div>
                                    <h3 style={{ color: isDark ? "#f3f4f6" : "#1f2937" }} className="font-bold text-lg">
                                        {category.name}
                                    </h3>
                                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="text-sm mt-1">
                                        {category.description || "No description"}
                                    </p>
                                </div>
                            </div>

                            <div
                                className="flex items-center justify-between pt-3"
                                style={{ borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}
                            >
                                <div className="flex items-center gap-2">
                                    <button
                                        onClick={() => handleToggle(category.id)}
                                        className="relative inline-flex h-6 w-11 items-center rounded-full transition-colors duration-200"
                                        style={{
                                            backgroundColor: category.isActive ? appColors.success : (isDark ? "#4b5563" : "#d1d5db"),
                                        }}
                                    >
                                        <span
                                            className="inline-block h-4 w-4 transform rounded-full bg-white transition-transform duration-200"
                                            style={{
                                                transform: category.isActive ? "translateX(1.375rem)" : "translateX(0.25rem)",
                                            }}
                                        />
                                    </button>
                                    <span
                                        className="text-sm"
                                        style={{ color: category.isActive ? appColors.success : (isDark ? "#9ca3af" : "#6b7280") }}
                                    >
                                        {category.isActive ? "Active" : "Inactive"}
                                    </span>
                                </div>

                                <div className="flex gap-2">
                                    <button onClick={() => openEdit(category)} className="p-2 rounded-lg hover:bg-white/10">
                                        ✏️
                                    </button>
                                    <button
                                        onClick={() => handleDelete(category.id)}
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
            )}

            {showAddModal && (
                <div
                    className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
                    onClick={closeModal}
                >
                    <div
                        className="rounded-xl p-6 shadow-2xl w-full max-w-md"
                        style={{
                            backgroundColor: isDark ? appColors.splashDark : "white",
                            border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                        }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        <h3 style={{ color: isDark ? "#f3f4f6" : "#1f2937" }} className="text-xl font-bold mb-4">
                            {editingCategory ? "Edit Category" : "Add Category"}
                        </h3>

                        <div className="space-y-4">
                            <div>
                                <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">
                                    Name
                                </label>
                                <input
                                    type="text"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    className="w-full rounded-lg p-3"
                                    style={{
                                        backgroundColor: isDark ? appColors.cardBg : "#f3f4f6",
                                        color: isDark ? "#f3f4f6" : "#1f2937",
                                        border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}`,
                                    }}
                                    placeholder="e.g., Physical Activities"
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
                                        color: isDark ? "#f3f4f6" : "#1f2937",
                                        border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}`,
                                    }}
                                    placeholder="Brief description..."
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
