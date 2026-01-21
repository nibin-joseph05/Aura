export const API_ENDPOINTS = {
    AUTH: {
        LOGIN: "/api/admin/login",
        CURRENT: "/api/admin/current",
        REGISTER: "/api/admin/register",
    },
    ACTIVITY_CATEGORIES: {
        BASE: "/api/admin/activity-categories",
        ACTIVE: "/api/admin/activity-categories/active",
        BY_ID: (id: string) => `/api/admin/activity-categories/${id}`,
        TOGGLE: (id: string) => `/api/admin/activity-categories/${id}/toggle-status`,
    },
    ACTIVITY_TYPES: {
        BASE: "/api/admin/activity-types",
        ACTIVE: "/api/admin/activity-types/active",
        BY_ID: (id: string) => `/api/admin/activity-types/${id}`,
        BY_CATEGORY: (categoryId: string) => `/api/admin/activity-types/category/${categoryId}`,
        GYM: "/api/admin/activity-types/gym",
        TOGGLE: (id: string) => `/api/admin/activity-types/${id}/toggle-status`,
    },
    GYM_EXERCISES: {
        BASE: "/api/admin/gym-exercises",
        ACTIVE: "/api/admin/gym-exercises/active",
        BY_ID: (id: string) => `/api/admin/gym-exercises/${id}`,
        BY_MUSCLE: (muscle: string) => `/api/admin/gym-exercises/muscle/${muscle}`,
        TOGGLE: (id: string) => `/api/admin/gym-exercises/${id}/toggle-status`,
    },
    SOS: {
        EVENTS: "/api/admin/sos/events",
        EVENT_BY_ID: (id: string) => `/api/admin/sos/events/${id}`,
        ACKNOWLEDGE: (id: string) => `/api/admin/sos/events/${id}/acknowledge`,
        RESOLVE: (id: string) => `/api/admin/sos/events/${id}/resolve`,
        STATS: "/api/admin/sos/stats",
    },
    WELLNESS: {
        PENDING: "/api/admin/wellness/pending",
        ALL: "/api/admin/wellness/all",
        STATS: "/api/admin/wellness/stats",
        APPROVE: (id: string) => `/api/admin/wellness/${id}/approve`,
        REJECT: (id: string) => `/api/admin/wellness/${id}/reject`,
        DELETE: (id: string) => `/api/admin/wellness/${id}`,
    },
    USERS: {
        BASE: "/api/users",
        BY_ID: (id: string) => `/api/users/${id}`,
    },
};
