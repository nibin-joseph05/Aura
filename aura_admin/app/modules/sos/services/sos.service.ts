import { apiClient } from "@/app/core/network/api-client";
import { API_ENDPOINTS } from "@/app/core/network/api-endpoints";
import { SOSEvent, SOSEventsResponse, SOSStats, ResolveSOSRequest, SOSEventStatus, LiveLocationSession } from "../models/sos.model";

interface BackendResponse<T> {
    success: boolean;
    data: T;
    error?: string;
}

class SOSService {
    async getEvents(page: number = 0, size: number = 20, status?: SOSEventStatus): Promise<SOSEventsResponse> {
        const params = new URLSearchParams();
        params.append('page', page.toString());
        params.append('size', size.toString());
        if (status) {
            params.append('status', status);
        }

        const response = await apiClient.get<BackendResponse<SOSEventsResponse>>(`${API_ENDPOINTS.SOS.EVENTS}?${params.toString()}`);
        if (response.data?.success) {
            return response.data.data;
        }
        throw new Error(response.data?.error || 'Failed to fetch SOS events');
    }

    async getEventById(eventId: string): Promise<SOSEvent> {
        const response = await apiClient.get<BackendResponse<SOSEvent>>(API_ENDPOINTS.SOS.EVENT_BY_ID(eventId));
        if (response.data?.success) {
            return response.data.data;
        }
        throw new Error(response.data?.error || 'Failed to fetch SOS event');
    }

    async acknowledgeEvent(eventId: string): Promise<SOSEvent> {
        const response = await apiClient.put<BackendResponse<SOSEvent>>(API_ENDPOINTS.SOS.ACKNOWLEDGE(eventId), {});
        if (response.data?.success) {
            return response.data.data;
        }
        throw new Error(response.data?.error || 'Failed to acknowledge event');
    }

    async resolveEvent(eventId: string, request?: ResolveSOSRequest): Promise<SOSEvent> {
        const response = await apiClient.put<BackendResponse<SOSEvent>>(API_ENDPOINTS.SOS.RESOLVE(eventId), request || {});
        if (response.data?.success) {
            return response.data.data;
        }
        throw new Error(response.data?.error || 'Failed to resolve event');
    }

    async getStats(): Promise<SOSStats> {
        const response = await apiClient.get<BackendResponse<SOSStats>>(API_ENDPOINTS.SOS.STATS);
        if (response.data?.success) {
            return response.data.data;
        }
        throw new Error(response.data?.error || 'Failed to fetch SOS stats');
    }

    getStatusColor(status: SOSEventStatus): string {
        switch (status) {
            case 'TRIGGERED':
                return 'bg-red-500';
            case 'DELIVERED':
                return 'bg-orange-500';
            case 'ACKNOWLEDGED':
                return 'bg-yellow-500';
            case 'RESOLVED':
                return 'bg-green-500';
            case 'CANCELLED':
                return 'bg-gray-500';
            default:
                return 'bg-gray-500';
        }
    }

    getStatusBadgeColor(status: SOSEventStatus): string {
        switch (status) {
            case 'TRIGGERED':
                return 'text-red-700 bg-red-100 dark:text-red-400 dark:bg-red-900/30';
            case 'DELIVERED':
                return 'text-orange-700 bg-orange-100 dark:text-orange-400 dark:bg-orange-900/30';
            case 'ACKNOWLEDGED':
                return 'text-yellow-700 bg-yellow-100 dark:text-yellow-400 dark:bg-yellow-900/30';
            case 'RESOLVED':
                return 'text-green-700 bg-green-100 dark:text-green-400 dark:bg-green-900/30';
            case 'CANCELLED':
                return 'text-gray-700 bg-gray-100 dark:text-gray-400 dark:bg-gray-900/30';
            default:
                return 'text-gray-700 bg-gray-100';
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

    async getLiveSessions(): Promise<LiveLocationSession[]> {
        try {
            const response = await apiClient.get<BackendResponse<LiveLocationSession[]>>(API_ENDPOINTS.SOS.LIVE_SESSIONS);
            const data = response.data as BackendResponse<LiveLocationSession[]> | null;
            if (!data) return [];
            if (Array.isArray(data)) {
                return data;
            }
            if (data?.data) {
                return Array.isArray(data.data) ? data.data : [data.data as unknown as LiveLocationSession];
            }
            return [];
        } catch {
            return [];
        }
    }

    async getLiveSessionById(sessionId: string): Promise<LiveLocationSession> {
        const response = await apiClient.get<BackendResponse<LiveLocationSession>>(API_ENDPOINTS.SOS.LIVE_SESSION_BY_ID(sessionId));
        if (response.data?.success) {
            return response.data.data;
        }
        throw new Error('Failed to fetch live session');
    }
}

export const sosService = new SOSService();
