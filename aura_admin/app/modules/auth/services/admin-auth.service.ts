import { apiClient } from "@/app/core/network/api-client";
import { apiEndpoints } from "@/app/core/network/api-endpoints";
import {
    AdminLoginRequest,
    AdminLoginResponse,
    AdminResponse,
} from "@/app/modules/auth/models/admin.model";
import { authStorage } from "@/app/modules/auth/services/auth-storage";

interface AuthResult {
    success: boolean;
    error?: string;
    user?: AdminResponse;
}

const ERROR_MESSAGES: Record<number, string> = {
    0: "Unable to connect to the server. Please check your internet connection.",
    401: "Invalid credentials. Please check your email and password.",
    403: "Access denied. You don't have permission to access this resource.",
    404: "Service not available. Please try again later.",
    500: "Something went wrong on our end. Please try again later.",
};

function getErrorMessage(status: number, serverError?: string): string {
    if (serverError && serverError.length > 0) {
        return serverError;
    }
    return ERROR_MESSAGES[status] || "An unexpected error occurred. Please try again.";
}

export const adminAuthService = {
    async login(email: string, password: string): Promise<AuthResult> {
        if (!email.trim()) {
            return {
                success: false,
                error: "Please enter your email address.",
            };
        }

        if (!password) {
            return {
                success: false,
                error: "Please enter your password.",
            };
        }

        const loginData: AdminLoginRequest = { email, password };

        const loginResponse = await apiClient.post<AdminLoginResponse>(
            apiEndpoints.admin.login,
            loginData
        );

        if (loginResponse.error || !loginResponse.data) {
            return {
                success: false,
                error: getErrorMessage(loginResponse.status, loginResponse.error || undefined),
            };
        }

        authStorage.setToken(loginResponse.data.token);

        const userResponse = await apiClient.get<AdminResponse>(
            apiEndpoints.admin.current,
            true
        );

        if (userResponse.error || !userResponse.data) {
            authStorage.clearAuth();
            return {
                success: false,
                error: getErrorMessage(userResponse.status, userResponse.error || undefined),
            };
        }

        if (userResponse.data.role !== "ADMIN" && userResponse.data.role !== "SUPER_ADMIN") {
            authStorage.clearAuth();
            return {
                success: false,
                error: "Access denied. Only administrators can log in to this dashboard.",
            };
        }

        if (!userResponse.data.isActive) {
            authStorage.clearAuth();
            return {
                success: false,
                error: "Your account has been deactivated. Please contact support.",
            };
        }

        authStorage.setUser(userResponse.data);

        return {
            success: true,
            user: userResponse.data,
        };
    },

    async getCurrentUser(): Promise<AdminResponse | null> {
        if (!authStorage.isAuthenticated()) {
            return null;
        }

        const cachedUser = authStorage.getUser();
        if (cachedUser) {
            return cachedUser;
        }

        const response = await apiClient.get<AdminResponse>(
            apiEndpoints.admin.current,
            true
        );

        if (response.error || !response.data) {
            authStorage.clearAuth();
            return null;
        }

        authStorage.setUser(response.data);
        return response.data;
    },

    logout(): void {
        authStorage.clearAuth();
    },

    isAuthenticated(): boolean {
        return authStorage.isAuthenticated();
    },
};
