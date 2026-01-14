"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import BackButton from "@/app/components/ui/BackButton";
import LogoWithEffects from "@/app/components/ui/LogoWithEffects";
import LoginForm from "@/app/modules/auth/components/LoginForm";
import PageLoader from "@/app/components/loaders/PageLoader";
import { useToast } from "@/app/components/ui/Toast";
import { adminAuthService } from "@/app/modules/auth/services/admin-auth.service";
import { gradients, appColors } from "@/app/core/constants/colors";

export default function AdminLoginPage() {
  const router = useRouter();
  const { showToast } = useToast();
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [loadingMessage, setLoadingMessage] = useState("Loading...");

  const handleLogin = async (email: string, password: string) => {
    setLoading(true);
    setLoadingMessage("Signing in...");
    setError("");

    const result = await adminAuthService.login(email, password);

    if (!result.success) {
      setError(result.error || "Login failed");
      showToast(result.error || "Login failed", "error");
      setLoading(false);
      return;
    }

    setLoadingMessage("Login successful! Redirecting...");
    showToast("Login successful!", "success");

    setTimeout(() => {
      router.push("/admin/dashboard");
    }, 1000);
  };

  return (
    <div
      className="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8 relative overflow-hidden"
      style={{ background: gradients.primaryDiagonal }}
    >
      {loading && <PageLoader message={loadingMessage} />}

      <div className="absolute inset-0 z-0 opacity-20 overflow-hidden">
        <div className="particle-layer pointer-events-none"></div>
        <div className="shimmer-layer pointer-events-none"></div>
      </div>

      <div
        className="max-w-md w-full space-y-8 p-10 rounded-xl shadow-2xl transform transition-all duration-300 hover:scale-[1.02] relative z-10 animate-fade-in-up"
        style={{
          backgroundColor: appColors.cardBg,
          border: `1px solid ${appColors.cardBorder}`,
          backdropFilter: "blur(10px)",
        }}
      >
        <div className="flex justify-start">
          <BackButton href="/" />
        </div>

        <div className="flex flex-col items-center">
          <div className="mb-6">
            <LogoWithEffects size={100} />
          </div>

          <h2
            className="mt-6 text-center text-3xl font-extrabold drop-shadow-lg"
            style={{
              background: `linear-gradient(to right, ${appColors.accent}, ${appColors.primary})`,
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
            }}
          >
            Aura Admin
          </h2>
          <p className="mt-2 text-center text-sm text-gray-400">
            Manage your platform with confidence
          </p>
        </div>

        <LoginForm onSubmit={handleLogin} isLoading={loading} error={error} />
      </div>

      <style jsx>{`
        .particle-layer,
        .shimmer-layer {
          position: absolute;
          width: 100%;
          height: 100%;
          pointer-events: none;
        }

        .particle-layer::before {
          content: "";
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: radial-gradient(
              circle at 10% 20%,
              ${appColors.accent}1a 0%,
              transparent 40%
            ),
            radial-gradient(
              circle at 90% 80%,
              ${appColors.primary}1a 0%,
              transparent 40%
            );
          animation: background-move 15s infinite alternate ease-in-out;
        }

        .shimmer-layer::after {
          content: "";
          position: absolute;
          top: -50%;
          left: -50%;
          width: 200%;
          height: 200%;
          background: linear-gradient(
            to right,
            transparent,
            rgba(255, 255, 255, 0.03) 5%,
            rgba(255, 255, 255, 0.08) 10%,
            transparent 15%
          );
          transform: rotate(45deg);
          animation: shimmer-background 8s infinite linear;
        }

        @keyframes background-move {
          0% {
            transform: translate(0, 0);
            opacity: 0.2;
          }
          50% {
            transform: translate(5%, 5%);
            opacity: 0.3;
          }
          100% {
            transform: translate(0, 0);
            opacity: 0.2;
          }
        }

        @keyframes shimmer-background {
          0% {
            transform: translateX(-100%) rotate(45deg);
          }
          100% {
            transform: translateX(100%) rotate(45deg);
          }
        }

        @keyframes fadeInOnLoad {
          0% {
            opacity: 0;
            transform: translateY(20px);
          }
          100% {
            opacity: 1;
            transform: translateY(0);
          }
        }
        .animate-fade-in-up {
          animation: fadeInOnLoad 0.8s ease-out forwards;
        }
      `}</style>
    </div>
  );
}
