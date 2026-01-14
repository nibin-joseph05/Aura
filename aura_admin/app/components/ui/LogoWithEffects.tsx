"use client";

import Image from "next/image";
import { appColors } from "@/app/core/constants/colors";

interface LogoWithEffectsProps {
    size?: number;
}

export default function LogoWithEffects({ size = 120 }: LogoWithEffectsProps) {
    return (
        <div className="relative flex items-center justify-center animate-pulse-light">
            <Image
                src="/logo/Aura-app-icon.png"
                alt="Aura Logo"
                width={size}
                height={size}
                className="rounded-full shadow-lg z-10"
                style={{ border: `4px solid ${appColors.accent}` }}
            />
            <div className="absolute inset-0 rounded-full animate-ripple-effect pointer-events-none"></div>

            <style jsx>{`
        @keyframes pulseLight {
          0% {
            box-shadow: 0 0 0px ${appColors.accent}b3, 0 0 0px ${appColors.primary}b3;
          }
          50% {
            box-shadow: 0 0 20px ${appColors.accent}b3, 0 0 30px ${appColors.primary}b3;
          }
          100% {
            box-shadow: 0 0 0px ${appColors.accent}b3, 0 0 0px ${appColors.primary}b3;
          }
        }
        .animate-pulse-light {
          animation: pulseLight 4s infinite ease-in-out;
        }

        @keyframes rippleEffect {
          0% {
            transform: scale(0.7);
            opacity: 0.5;
            border-color: ${appColors.accent}b3;
          }
          100% {
            transform: scale(1.4);
            opacity: 0;
            border-color: ${appColors.accent}00;
          }
        }
        .animate-ripple-effect {
          border: 2px solid ${appColors.accent}00;
          animation: rippleEffect 2s infinite ease-out;
        }
      `}</style>
        </div>
    );
}
