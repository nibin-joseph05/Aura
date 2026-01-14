"use client";

import { useState, FormEvent } from "react";
import InputField from "@/app/components/ui/InputField";
import Button from "@/app/components/ui/Button";
import { validators, hasErrors, ValidationErrors } from "@/app/core/utils/validators";
import { appColors } from "@/app/core/constants/colors";

interface LoginFormProps {
    onSubmit: (email: string, password: string) => Promise<void>;
    isLoading: boolean;
    error: string;
}

export default function LoginForm({ onSubmit, isLoading, error }: LoginFormProps) {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [errors, setErrors] = useState<ValidationErrors>({});
    const [touched, setTouched] = useState<Record<string, boolean>>({});

    const validateField = (field: string, value: string) => {
        let fieldError: string | undefined;

        if (field === "email") {
            fieldError = validators.email(value);
        } else if (field === "password") {
            fieldError = validators.password(value);
        }

        setErrors((prev) => ({ ...prev, [field]: fieldError }));
        return fieldError;
    };

    const handleBlur = (field: string, value: string) => {
        setTouched((prev) => ({ ...prev, [field]: true }));
        validateField(field, value);
    };

    const handleSubmit = async (e: FormEvent) => {
        e.preventDefault();

        const emailError = validators.email(email);
        const passwordError = validators.password(password);

        const newErrors: ValidationErrors = {
            email: emailError,
            password: passwordError,
        };

        setErrors(newErrors);
        setTouched({ email: true, password: true });

        if (hasErrors(newErrors)) {
            return;
        }

        await onSubmit(email, password);
    };

    return (
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
            {error && (
                <div
                    className="p-3 rounded-lg flex items-center gap-3"
                    style={{
                        backgroundColor: `${appColors.error}20`,
                        borderLeft: `4px solid ${appColors.error}`,
                    }}
                >
                    <span className="text-xl">⚠️</span>
                    <div>
                        <p className="font-medium" style={{ color: appColors.error }}>
                            Authentication Error
                        </p>
                        <p className="text-sm text-gray-300">{error}</p>
                    </div>
                </div>
            )}

            <div className="space-y-4">
                <InputField
                    id="email-address"
                    name="email"
                    type="email"
                    autoComplete="email"
                    placeholder="Email address"
                    value={email}
                    onChange={(e) => {
                        setEmail(e.target.value);
                        if (touched.email) validateField("email", e.target.value);
                    }}
                    onBlur={() => handleBlur("email", email)}
                    error={touched.email ? errors.email : undefined}
                />

                <InputField
                    id="password"
                    name="password"
                    type="password"
                    autoComplete="current-password"
                    placeholder="Password"
                    value={password}
                    onChange={(e) => {
                        setPassword(e.target.value);
                        if (touched.password) validateField("password", e.target.value);
                    }}
                    onBlur={() => handleBlur("password", password)}
                    error={touched.password ? errors.password : undefined}
                />
            </div>

            <div className="flex justify-center">
                <button
                    type="button"
                    className="text-sm font-medium transition-colors duration-200 hover:underline"
                    style={{ color: appColors.accent }}
                >
                    Forgot your password?
                </button>
            </div>

            <Button type="submit" isLoading={isLoading} fullWidth>
                Sign in
            </Button>
        </form>
    );
}
