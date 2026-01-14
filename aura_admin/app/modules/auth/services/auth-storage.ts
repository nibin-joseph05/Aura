import { AdminResponse } from "@/app/modules/auth/models/admin.model";

const AUTH_TOKEN_KEY = "authToken";
const USER_DATA_KEY = "userData";

export const authStorage = {
    getToken(): string | null {
        if (typeof window === "undefined") return null;
        return localStorage.getItem(AUTH_TOKEN_KEY);
    },

    setToken(token: string): void {
        if (typeof window === "undefined") return;
        localStorage.setItem(AUTH_TOKEN_KEY, token);
    },

    removeToken(): void {
        if (typeof window === "undefined") return;
        localStorage.removeItem(AUTH_TOKEN_KEY);
    },

    getUser(): AdminResponse | null {
        if (typeof window === "undefined") return null;
        const data = localStorage.getItem(USER_DATA_KEY);
        if (!data) return null;
        try {
            return JSON.parse(data) as AdminResponse;
        } catch {
            return null;
        }
    },

    setUser(user: AdminResponse): void {
        if (typeof window === "undefined") return;
        localStorage.setItem(USER_DATA_KEY, JSON.stringify(user));
    },

    removeUser(): void {
        if (typeof window === "undefined") return;
        localStorage.removeItem(USER_DATA_KEY);
    },

    clearAuth(): void {
        this.removeToken();
        this.removeUser();
    },

    isAuthenticated(): boolean {
        return !!this.getToken();
    },
};
