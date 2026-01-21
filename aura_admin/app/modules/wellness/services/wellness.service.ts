import { apiClient } from "@/app/core/network/api-client";
import { API_ENDPOINTS } from "@/app/core/network/api-endpoints";
import { WellnessUpdate, WellnessUpdatesResponse, WellnessStats, WellnessCategory, ModerateWellnessRequest } from "../models/wellness.model";

interface ApiResponse<T> {
    success: boolean;
    data: T;
    error?: string;
}

class WellnessService {
    async getPendingUpdates(page: number = 0, size: number = 20): Promise<WellnessUpdatesResponse> {
        const response = await apiClient.get<ApiResponse<WellnessUpdatesResponse>>(`${API_ENDPOINTS.WELLNESS.PENDING}?page=${page}&size=${size}`);
        if (response.data.success) {
            return response.data.data;
        }
        throw new Error(response.data.error || 'Failed to fetch pending updates');
    }

    async getAllUpdates(page: number = 0, size: number = 20, category?: WellnessCategory): Promise<WellnessUpdatesResponse> {
        let url = `${API_ENDPOINTS.WELLNESS.ALL}?page=${page}&size=${size}`;
        if (category) {
            url += `&category=${category}`;
        }
        const response = await apiClient.get<ApiResponse<WellnessUpdatesResponse>>(url);
        if (response.data.success) {
            return response.data.data;
        }
        throw new Error(response.data.error || 'Failed to fetch updates');
    }

    async getStats(): Promise<WellnessStats> {
        const response = await apiClient.get<ApiResponse<WellnessStats>>(API_ENDPOINTS.WELLNESS.STATS);
        if (response.data.success) {
            return response.data.data;
        }
        throw new Error(response.data.error || 'Failed to fetch stats');
    }

    async approveUpdate(id: string): Promise<WellnessUpdate> {
        const response = await apiClient.put<ApiResponse<WellnessUpdate>>(API_ENDPOINTS.WELLNESS.APPROVE(id), {});
        if (response.data.success) {
            return response.data.data;
        }
        throw new Error(response.data.error || 'Failed to approve update');
    }

    async rejectUpdate(id: string, request?: ModerateWellnessRequest): Promise<WellnessUpdate> {
        const response = await apiClient.put<ApiResponse<WellnessUpdate>>(API_ENDPOINTS.WELLNESS.REJECT(id), request || {});
        if (response.data.success) {
            return response.data.data;
        }
        throw new Error(response.data.error || 'Failed to reject update');
    }

    async deleteUpdate(id: string): Promise<void> {
        const response = await apiClient.delete<ApiResponse<void>>(API_ENDPOINTS.WELLNESS.DELETE(id));
        if (!response.data.success) {
            throw new Error(response.data.error || 'Failed to delete update');
        }
    }

    getCategoryColor(category: WellnessCategory): string {
        switch (category) {
            case 'PROGRESS':
                return 'text-blue-700 bg-blue-100 dark:text-blue-400 dark:bg-blue-900/30';
            case 'MOTIVATION':
                return 'text-purple-700 bg-purple-100 dark:text-purple-400 dark:bg-purple-900/30';
            case 'TIP':
                return 'text-yellow-700 bg-yellow-100 dark:text-yellow-400 dark:bg-yellow-900/30';
            case 'ACHIEVEMENT':
                return 'text-green-700 bg-green-100 dark:text-green-400 dark:bg-green-900/30';
            case 'GENERAL':
                return 'text-gray-700 bg-gray-100 dark:text-gray-400 dark:bg-gray-900/30';
            default:
                return 'text-gray-700 bg-gray-100';
        }
    }

    getCategoryEmoji(category: WellnessCategory): string {
        switch (category) {
            case 'PROGRESS': return '📈';
            case 'MOTIVATION': return '💪';
            case 'TIP': return '💡';
            case 'ACHIEVEMENT': return '🏆';
            case 'GENERAL': return '✨';
            default: return '✨';
        }
    }

    formatDateTime(dateString: string): string {
        const date = new Date(dateString);
        return date.toLocaleString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
        });
    }

    getTimeAgo(dateString: string): string {
        const date = new Date(dateString);
        const now = new Date();
        const diffMs = now.getTime() - date.getTime();
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMins / 60);
        const diffDays = Math.floor(diffHours / 24);

        if (diffMins < 1) return 'Just now';
        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffHours < 24) return `${diffHours}h ago`;
        if (diffDays < 7) return `${diffDays}d ago`;
        return this.formatDateTime(dateString);
    }
}

export const wellnessService = new WellnessService();
