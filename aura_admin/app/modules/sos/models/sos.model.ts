export type SOSEventStatus = 'TRIGGERED' | 'DELIVERED' | 'ACKNOWLEDGED' | 'RESOLVED' | 'CANCELLED';

export interface SOSEvent {
    id: string;
    userId: string;
    userName: string | null;
    userPhone: string | null;
    latitude: number;
    longitude: number;
    address: string | null;
    message: string;
    contactsNotified: number;
    status: SOSEventStatus;
    triggeredAt: string;
    acknowledgedAt: string | null;
    resolvedAt: string | null;
    resolvedBy: string | null;
    resolutionNotes: string | null;
    syncedFromOffline: boolean;
    mapsUrl: string;
}

export interface SOSStats {
    totalEvents: number;
    activeEvents: number;
    resolvedEvents: number;
    eventsToday: number;
    eventsThisWeek: number;
    eventsThisMonth: number;
}

export interface SOSEventsResponse {
    content: SOSEvent[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number;
}

export interface ResolveSOSRequest {
    resolutionNotes?: string;
}

export interface LiveLocationPoint {
    id: string;
    latitude: number;
    longitude: number;
    timestamp: string;
    altitude: number | null;
    speed: number | null;
}

export interface LiveLocationSession {
    id: string;
    userId: string;
    active: boolean;
    startedAt: string;
    endedAt: string | null;
    durationMinutes: number | null;
    allowedContactIds: string[];
    blockHash: string | null;
    blockIndex: number | null;
    points: LiveLocationPoint[];
}
