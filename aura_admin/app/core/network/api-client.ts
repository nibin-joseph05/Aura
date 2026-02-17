import { appConfig } from "@/app/core/config/app-config";

type HttpMethod = "GET" | "POST" | "PUT" | "DELETE" | "PATCH";

interface RequestOptions {
    method?: HttpMethod;
    body?: unknown;
    headers?: Record<string, string>;
    requiresAuth?: boolean;
}

interface ApiResponse<T> {
    data: T | null;
    error: string | null;
    status: number;
    success: boolean;
}

function getNetworkErrorMessage(error: unknown): string {
    if (error instanceof TypeError && error.message === "Failed to fetch") {
        return "Unable to connect to the server. Please check if the backend is running and your network connection.";
    }
    if (error instanceof Error) {
        if (error.message.includes("CORS")) {
            return "Connection blocked by CORS policy. Please check backend CORS configuration.";
        }
        if (error.message.includes("NetworkError")) {
            return "Network error. Please check your internet connection.";
        }
        return error.message;
    }
    return "An unexpected network error occurred. Please try again.";
}

class ApiClient {
    private baseUrl: string;

    constructor() {
        this.baseUrl = appConfig.apiBaseUrl;
    }

    private getAuthToken(): string | null {
        if (typeof window === "undefined") return null;
        return localStorage.getItem("authToken");
    }

    async request<T>(endpoint: string, options: RequestOptions = {}): Promise<ApiResponse<T>> {
        const { method = "GET", body, headers = {}, requiresAuth = true } = options;

        const requestHeaders: Record<string, string> = {
            "Content-Type": "application/json",
            ...headers,
        };

        if (requiresAuth) {
            const token = this.getAuthToken();
            if (token) {
                requestHeaders["Authorization"] = `Bearer ${token}`;
            }
        }

        console.log(`============================================================`);
        console.log(`>>> ADMIN REQUEST  - ${method} ${endpoint}`);
        console.log(`>>> Auth           - ${requestHeaders["Authorization"] ? "Bearer ***" : "none"}`);
        if (body) {
            console.log(`>>> Body           -`, body);
        }

        try {
            const response = await fetch(`${this.baseUrl}${endpoint}`, {
                method,
                headers: requestHeaders,
                body: body ? JSON.stringify(body) : undefined,
            });

            const data = await response.json().catch(() => null);

            if (!response.ok) {
                console.log(`<<< ADMIN RESPONSE - ${method} ${endpoint} | status=${response.status} | ERROR`);
                console.log(`<<< Error          -`, data?.message || `Request failed with status ${response.status}`);
                console.log(`============================================================`);
                return {
                    data: null,
                    error: data?.message || `Request failed with status ${response.status}`,
                    status: response.status,
                    success: false,
                };
            }

            console.log(`<<< ADMIN RESPONSE - ${method} ${endpoint} | status=${response.status} | OK`);
            console.log(`============================================================`);
            return {
                data: data as T,
                error: null,
                status: response.status,
                success: true,
            };
        } catch (error) {
            console.error(`<<< ADMIN ERROR    - ${method} ${endpoint} |`, error);
            console.log(`============================================================`);
            return {
                data: null,
                error: getNetworkErrorMessage(error),
                status: 0,
                success: false,
            };
        }
    }

    get<T>(endpoint: string, requiresAuth = true): Promise<ApiResponse<T>> {
        return this.request<T>(endpoint, { method: "GET", requiresAuth });
    }

    post<T>(endpoint: string, body: unknown, requiresAuth = true): Promise<ApiResponse<T>> {
        return this.request<T>(endpoint, { method: "POST", body, requiresAuth });
    }

    put<T>(endpoint: string, body: unknown, requiresAuth = true): Promise<ApiResponse<T>> {
        return this.request<T>(endpoint, { method: "PUT", body, requiresAuth });
    }

    patch<T>(endpoint: string, body: unknown, requiresAuth = true): Promise<ApiResponse<T>> {
        return this.request<T>(endpoint, { method: "PATCH", body, requiresAuth });
    }

    delete<T>(endpoint: string, requiresAuth = true): Promise<ApiResponse<T>> {
        return this.request<T>(endpoint, { method: "DELETE", requiresAuth });
    }
}

export const apiClient = new ApiClient();
