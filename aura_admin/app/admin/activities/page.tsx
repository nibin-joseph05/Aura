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
}

export enum MetricType {
    INTEGER = "INTEGER",
    DECIMAL = "DECIMAL",
    BOOLEAN = "BOOLEAN",
    TIME_MINUTES = "TIME_MINUTES",
    TEXT = "TEXT"
}

export interface ActivityMetric {
    id?: string;
    name: string;
    unit: string;
    metricType: MetricType;
    isRequired: boolean;
}

interface ActivityType {
    id: string;
    categoryId: string;
    categoryName: string;
    name: string;
    description: string;
    allowAlarm: boolean;
    allowNotes: boolean;
    metrics: ActivityMetric[];
    isGymActivity: boolean;
    icon: string;
    color: string;
    defaultIntervalMinutes: number | null;
    defaultTargetCompletions: number;
    isActive: boolean;
}

export default function ActivityTypesPage() {
    const { isDark } = useTheme();
    const [activityTypes, setActivityTypes] = useState<ActivityType[]>([]);
    const [categories, setCategories] = useState<ActivityCategory[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");
    const [showAddModal, setShowAddModal] = useState(false);
    const [editingType, setEditingType] = useState<ActivityType | null>(null);
    const [formData, setFormData] = useState({
        categoryId: "",
        name: "",
        description: "",
        icon: "",
        allowAlarm: false,
        allowNotes: true,
        metrics: [] as ActivityMetric[],
        isGymActivity: false,
        color: "#3b82f6",
        defaultIntervalMinutes: null as number | null,
        defaultTargetCompletions: 1,
    });
    const [saving, setSaving] = useState(false);

    const fetchData = useCallback(async () => {
        try {
            setLoading(true);
            const [typesRes, catsRes] = await Promise.all([
                apiClient.get<ActivityType[]>(API_ENDPOINTS.ACTIVITY_TYPES.BASE),
                apiClient.get<ActivityCategory[]>(API_ENDPOINTS.ACTIVITY_CATEGORIES.ACTIVE)
            ]);
            if (typesRes.success && typesRes.data) setActivityTypes(typesRes.data);
            if (catsRes.success && catsRes.data) setCategories(catsRes.data);
        } catch (error) {
            console.error("Failed to fetch data:", error);
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    const filteredTypes = activityTypes.filter(type =>
        type.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        type.categoryName?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const handleSave = async () => {
        if (!formData.name.trim() || !formData.categoryId) return;
        setSaving(true);
        try {
            if (editingType) {
                await apiClient.put(API_ENDPOINTS.ACTIVITY_TYPES.BY_ID(editingType.id), formData);
            } else {
                await apiClient.post(API_ENDPOINTS.ACTIVITY_TYPES.BASE, formData);
            }
            await fetchData();
            closeModal();
        } catch (error) {
            console.error("Failed to save:", error);
        } finally {
            setSaving(false);
        }
    };

    const handleToggle = async (id: string) => {
        await apiClient.patch(API_ENDPOINTS.ACTIVITY_TYPES.TOGGLE(id), {});
        await fetchData();
    };

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this activity type?")) return;
        await apiClient.delete(API_ENDPOINTS.ACTIVITY_TYPES.BY_ID(id));
        await fetchData();
    };

    const openEdit = (type: ActivityType) => {
        setEditingType(type);
        setFormData({
            categoryId: type.categoryId,
            name: type.name,
            description: type.description || "",
            icon: type.icon || "",
            allowAlarm: type.allowAlarm,
            allowNotes: type.allowNotes,
            metrics: type.metrics || [],
            isGymActivity: type.isGymActivity,
            color: type.color || "#3b82f6",
            defaultIntervalMinutes: type.defaultIntervalMinutes,
            defaultTargetCompletions: type.defaultTargetCompletions || 1,
        });
        setShowAddModal(true);
    };

    const closeModal = () => {
        setShowAddModal(false);
        setEditingType(null);
        setFormData({
            categoryId: "", name: "", description: "", icon: "", color: "#3b82f6", defaultIntervalMinutes: null, defaultTargetCompletions: 1,
            allowAlarm: false, allowNotes: true, metrics: [], isGymActivity: false,
        });
    };

    const addMetric = () => {
        setFormData({
            ...formData,
            metrics: [...formData.metrics, { name: "", unit: "", metricType: MetricType.INTEGER, isRequired: false }]
        });
    };

    const updateMetric = (index: number, field: keyof ActivityMetric, value: any) => {
        const newMetrics = [...formData.metrics];
        newMetrics[index] = { ...newMetrics[index], [field]: value };
        setFormData({ ...formData, metrics: newMetrics });
    };

    const removeMetric = (index: number) => {
        const newMetrics = [...formData.metrics];
        newMetrics.splice(index, 1);
        setFormData({ ...formData, metrics: newMetrics });
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 style={{ color: isDark ? "#f3f4f6" : "#1f2937" }} className="text-xl font-bold">
                        Manage Activity Types
                    </h2>
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                        Define activities users can add to their daily plans
                    </p>
                </div>
                <div className="flex gap-3">
                    <input
                        type="text"
                        placeholder="Search activities..."
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
                        + Add Type
                    </Button>
                </div>
            </div>

            {loading ? (
                <div className="p-8 text-center">
                    <div className="animate-spin text-4xl mb-2">⏳</div>
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Loading activity types...</p>
                </div>
            ) : filteredTypes.length === 0 ? (
                <div
                    className="text-center py-12 rounded-xl"
                    style={{
                        backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                        border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                    }}
                >
                    <span className="text-4xl block mb-4">📋</span>
                    <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>
                        {searchQuery ? `No results for "${searchQuery}"` : "No activity types yet. Create your first one!"}
                    </p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {filteredTypes.map((type) => (
                        <div
                            key={type.id}
                            className="rounded-xl p-5 shadow-lg transition-all duration-300 hover:-translate-y-1"
                            style={{
                                backgroundColor: isDark ? appColors.cardBg : "rgba(255,255,255,0.95)",
                                border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                            }}
                        >
                            <div className="flex items-start gap-3 mb-3">
                                <div className="flex items-center justify-center w-12 h-12 rounded-xl text-2xl" style={{ backgroundColor: `${type.color}20` || `${appColors.primary}20` }}>
                                    {type.icon || "📋"}
                                </div>
                                <div className="flex-1">
                                    <h3 style={{ color: isDark ? "#f3f4f6" : "#1f2937" }} className="font-bold">
                                        {type.name}
                                    </h3>
                                    <span
                                        className="inline-block text-xs px-2 py-0.5 rounded-full"
                                        style={{ backgroundColor: `${appColors.primary}20`, color: appColors.primary }}
                                    >
                                        {type.categoryName}
                                    </span>
                                </div>
                            </div>

                            {type.description && (
                                <p style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="text-sm mb-3 line-clamp-2">
                                    {type.description}
                                </p>
                            )}

                            <div className="flex flex-wrap gap-1 mb-3">
                                {type.allowAlarm && <span className="text-xs px-2 py-0.5 rounded-full bg-blue-500/20 text-blue-400">⏰ Alarm</span>}
                                {type.isGymActivity && <span className="text-xs px-2 py-0.5 rounded-full bg-purple-500/20 text-purple-400">🏋️ Gym</span>}
                                {type.defaultIntervalMinutes && <span className="text-xs px-2 py-0.5 rounded-full bg-orange-500/20 text-orange-400">⏳ Every {type.defaultIntervalMinutes}m</span>}
                                {type.defaultTargetCompletions > 1 && <span className="text-xs px-2 py-0.5 rounded-full bg-indigo-500/20 text-indigo-400">🎯 {type.defaultTargetCompletions}x / day</span>}

                                {type.metrics && type.metrics.map((metric, idx) => (
                                    <span key={metric.id || idx} className="text-xs px-2 py-0.5 rounded-full bg-green-500/20 text-green-400 border border-green-500/30">
                                        📊 {metric.name} {metric.isRequired ? '*' : ''}
                                    </span>
                                ))}
                            </div>

                            <div
                                className="flex items-center justify-between pt-3"
                                style={{ borderTop: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}
                            >
                                <div className="flex items-center gap-2">
                                    <button
                                        onClick={() => handleToggle(type.id)}
                                        className="relative inline-flex h-6 w-11 items-center rounded-full transition-colors duration-200"
                                        style={{ backgroundColor: type.isActive ? appColors.success : (isDark ? "#4b5563" : "#d1d5db") }}
                                    >
                                        <span
                                            className="inline-block h-4 w-4 transform rounded-full bg-white transition-transform duration-200"
                                            style={{ transform: type.isActive ? "translateX(1.375rem)" : "translateX(0.25rem)" }}
                                        />
                                    </button>
                                    <span className="text-sm" style={{ color: type.isActive ? appColors.success : (isDark ? "#9ca3af" : "#6b7280") }}>
                                        {type.isActive ? "Active" : "Inactive"}
                                    </span>
                                </div>
                                <div className="flex gap-2">
                                    <button onClick={() => openEdit(type)} className="p-2 rounded-lg hover:bg-white/10">✏️</button>
                                    <button onClick={() => handleDelete(type.id)} className="p-2 rounded-lg hover:bg-white/10" style={{ color: appColors.error }}>🗑️</button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {showAddModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={closeModal}>
                    <div
                        className="rounded-xl p-6 shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto"
                        style={{
                            backgroundColor: isDark ? appColors.splashDark : "white",
                            border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}`,
                        }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        <h3 style={{ color: isDark ? "#f3f4f6" : "#1f2937" }} className="text-xl font-bold mb-4">
                            {editingType ? "Edit Activity Type" : "Add Activity Type"}
                        </h3>

                        <div className="space-y-4">
                            <div>
                                <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">Category *</label>
                                <select
                                    value={formData.categoryId}
                                    onChange={(e) => setFormData({ ...formData, categoryId: e.target.value })}
                                    className="w-full rounded-lg p-3"
                                    style={{ backgroundColor: isDark ? appColors.cardBg : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }}
                                >
                                    <option value="">Select category</option>
                                    {categories.map(cat => (<option key={cat.id} value={cat.id}>{cat.name}</option>))}
                                </select>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">Name *</label>
                                    <input type="text" value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })} className="w-full rounded-lg p-3" style={{ backgroundColor: isDark ? appColors.cardBg : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }} placeholder="e.g., Walking" />
                                </div>
                                <div>
                                    <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">Icon</label>
                                    <input type="text" value={formData.icon} onChange={(e) => setFormData({ ...formData, icon: e.target.value })} className="w-full rounded-lg p-3" style={{ backgroundColor: isDark ? appColors.cardBg : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }} placeholder="🚶" />
                                </div>
                                <div>
                                    <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">Color HEX</label>
                                    <div className="flex gap-2">
                                        <input type="color" value={formData.color} onChange={(e) => setFormData({ ...formData, color: e.target.value })} className="h-[46px] w-[46px] rounded cursor-pointer" />
                                        <input type="text" value={formData.color} onChange={(e) => setFormData({ ...formData, color: e.target.value })} className="w-full rounded-lg px-3" style={{ backgroundColor: isDark ? appColors.cardBg : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }} placeholder="#3b82f6" />
                                    </div>
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">Default Interval (mins)</label>
                                    <input type="number" min="0" value={formData.defaultIntervalMinutes || ""} onChange={(e) => setFormData({ ...formData, defaultIntervalMinutes: e.target.value ? parseInt(e.target.value) : null })} className="w-full rounded-lg p-3" style={{ backgroundColor: isDark ? appColors.cardBg : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }} placeholder="e.g., 60" />
                                </div>
                                <div>
                                    <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">Default Target Completions</label>
                                    <input type="number" min="1" value={formData.defaultTargetCompletions} onChange={(e) => setFormData({ ...formData, defaultTargetCompletions: parseInt(e.target.value) || 1 })} className="w-full rounded-lg p-3" style={{ backgroundColor: isDark ? appColors.cardBg : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }} />
                                </div>
                            </div>

                            <div>
                                <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-1">Description</label>
                                <textarea value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} className="w-full rounded-lg p-3 resize-none" rows={2} style={{ backgroundColor: isDark ? appColors.cardBg : "#f3f4f6", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }} />
                            </div>

                            <div>
                                <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm mb-2">Options</label>
                                <div className="grid grid-cols-2 gap-2">
                                    {[
                                        { key: "allowAlarm", label: "⏰ Allow Alarm" },
                                        { key: "allowNotes", label: "📝 Allow Notes" },
                                        { key: "isGymActivity", label: "🏋️ Gym Activity" },
                                    ].map((option) => (
                                        <label key={option.key} className="flex items-center gap-2 p-2 rounded-lg cursor-pointer" style={{ backgroundColor: formData[option.key as keyof typeof formData] ? `${appColors.accent}20` : "transparent", border: `1px solid ${isDark ? appColors.cardBorder : "#e5e7eb"}` }}>
                                            <input type="checkbox" checked={formData[option.key as keyof typeof formData] as boolean} onChange={(e) => setFormData({ ...formData, [option.key]: e.target.checked })} className="rounded" />
                                            <span className="text-sm" style={{ color: isDark ? "#f3f4f6" : "#374151" }}>{option.label}</span>
                                        </label>
                                    ))}
                                </div>
                            </div>

                            <div>
                                <div className="flex justify-between items-center mb-2">
                                    <label style={{ color: isDark ? "#9ca3af" : "#6b7280" }} className="block text-sm">Dynamic Metrics</label>
                                    <button onClick={addMetric} className="text-xs px-2 py-1 rounded bg-blue-500/20 text-blue-500 hover:bg-blue-500/30">
                                        + Add Metric
                                    </button>
                                </div>

                                {formData.metrics.length === 0 ? (
                                    <p className="text-xs italic" style={{ color: isDark ? "#6b7280" : "#9ca3af" }}>No custom metrics defined yet.</p>
                                ) : (
                                    <div className="space-y-3">
                                        {formData.metrics.map((metric, index) => (
                                            <div key={index} className="flex flex-col gap-2 p-3 rounded-lg relative" style={{ border: `1px dashed ${isDark ? appColors.cardBorder : "#d1d5db"}`, backgroundColor: isDark ? 'rgba(0,0,0,0.1)' : '#f9fafb' }}>
                                                <button onClick={() => removeMetric(index)} className="absolute top-2 right-2 text-red-500 hover:text-red-700">🗑️</button>

                                                <div className="grid grid-cols-2 gap-2 mt-2">
                                                    <div>
                                                        <label className="text-xs mb-1 block" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Name</label>
                                                        <input type="text" value={metric.name} onChange={(e) => updateMetric(index, 'name', e.target.value)} className="w-full rounded p-2 text-sm" style={{ backgroundColor: isDark ? appColors.cardBg : "white", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }} placeholder="e.g. Pages Read" />
                                                    </div>
                                                    <div>
                                                        <label className="text-xs mb-1 block" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Unit Symbol</label>
                                                        <input type="text" value={metric.unit} onChange={(e) => updateMetric(index, 'unit', e.target.value)} className="w-full rounded p-2 text-sm" style={{ backgroundColor: isDark ? appColors.cardBg : "white", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }} placeholder="e.g. pages, L, mins" />
                                                    </div>
                                                    <div>
                                                        <label className="text-xs mb-1 block" style={{ color: isDark ? "#9ca3af" : "#6b7280" }}>Data Type</label>
                                                        <select value={metric.metricType} onChange={(e) => updateMetric(index, 'metricType', e.target.value)} className="w-full rounded p-2 text-sm" style={{ backgroundColor: isDark ? appColors.cardBg : "white", color: isDark ? "#f3f4f6" : "#1f2937", border: `1px solid ${isDark ? appColors.cardBorder : "#d1d5db"}` }}>
                                                            {Object.values(MetricType).map(t => <option key={t} value={t}>{t}</option>)}
                                                        </select>
                                                    </div>
                                                    <div className="flex items-center justify-center mt-5">
                                                        <label className="flex items-center gap-2 cursor-pointer">
                                                            <input type="checkbox" checked={metric.isRequired} onChange={(e) => updateMetric(index, 'isRequired', e.target.checked)} className="rounded" />
                                                            <span className="text-xs font-bold" style={{ color: isDark ? "#f3f4f6" : "#374151" }}>Required Field</span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </div>
                        </div>

                        <div className="flex justify-end gap-3 mt-6">
                            <Button variant="secondary" onClick={closeModal}>Cancel</Button>
                            <Button variant="primary" onClick={handleSave} disabled={saving || !formData.name.trim() || !formData.categoryId}>{saving ? "Saving..." : "Save"}</Button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
