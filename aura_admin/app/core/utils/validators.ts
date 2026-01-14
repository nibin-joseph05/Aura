export const validators = {
    email: (value: string): string | undefined => {
        if (!value) {
            return "Email is required";
        }
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(value)) {
            return "Please enter a valid email address";
        }
        return undefined;
    },

    password: (value: string): string | undefined => {
        if (!value) {
            return "Password is required";
        }
        if (value.length < 6) {
            return "Password must be at least 6 characters";
        }
        return undefined;
    },

    required: (value: string, fieldName = "This field"): string | undefined => {
        if (!value || !value.trim()) {
            return `${fieldName} is required`;
        }
        return undefined;
    },

    minLength: (value: string, min: number, fieldName = "This field"): string | undefined => {
        if (value && value.length < min) {
            return `${fieldName} must be at least ${min} characters`;
        }
        return undefined;
    },

    maxLength: (value: string, max: number, fieldName = "This field"): string | undefined => {
        if (value && value.length > max) {
            return `${fieldName} must be at most ${max} characters`;
        }
        return undefined;
    },
};

export type ValidationErrors = Record<string, string | undefined>;

export const validateForm = (
    values: Record<string, string>,
    validationRules: Record<string, (value: string) => string | undefined>
): ValidationErrors => {
    const errors: ValidationErrors = {};

    for (const [field, validator] of Object.entries(validationRules)) {
        const error = validator(values[field] || "");
        if (error) {
            errors[field] = error;
        }
    }

    return errors;
};

export const hasErrors = (errors: ValidationErrors): boolean => {
    return Object.values(errors).some((error) => error !== undefined);
};
