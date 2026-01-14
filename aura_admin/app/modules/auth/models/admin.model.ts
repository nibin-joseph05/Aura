export interface AdminLoginRequest {
    email: string;
    password: string;
}

export interface AdminLoginResponse {
    token: string;
    message: string;
}

export interface AdminResponse {
    id: string;
    name: string;
    email: string;
    role: "SUPER_ADMIN" | "ADMIN";
    isActive: boolean;
    lastLoginAt: string | null;
    createdAt: string;
}
