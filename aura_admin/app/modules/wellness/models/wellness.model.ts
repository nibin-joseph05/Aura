export type WellnessCategory = 'PROGRESS' | 'MOTIVATION' | 'TIP' | 'ACHIEVEMENT' | 'GENERAL';

export interface WellnessUpdate {
    id: string;
    userId: string;
    userName: string | null;
    userProfileImage: string | null;
    content: string;
    imageUrl: string | null;
    category: WellnessCategory;
    likesCount: number;
    likedByCurrentUser: boolean;
    isApproved: boolean;
    createdAt: string;
}

export interface WellnessStats {
    totalUpdates: number;
    approvedUpdates: number;
    pendingUpdates: number;
    todayUpdates: number;
}

export interface WellnessUpdatesResponse {
    content: WellnessUpdate[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number;
}

export interface ModerateWellnessRequest {
    rejectionReason?: string;
}
