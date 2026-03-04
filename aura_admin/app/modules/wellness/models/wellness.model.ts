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
    commentsCount: number;
    likedByCurrentUser: boolean;
    isApproved: boolean;
    isVisible: boolean;
    createdAt: string;
    updatedAt?: string;
}

export interface WellnessStats {
    totalUpdates: number;
    totalLikes: number;
    totalComments: number;
    totalUsers: number;
    todayUpdates: number;
}

export interface WellnessUpdatesResponse {
    content: WellnessUpdate[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number;
}
