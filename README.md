# AURA: Safety, Wellness & Community AI Platform

![AURA Banner](https://img.shields.io/badge/AURA-Safety--Wellness-2F80ED?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring--Boot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![Next.js](https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white)

**AURA** (AI-powered Universal Relief and Assistance) is an integrated ecosystem designed to redefine personal safety and community wellness. By combining real-time emergency response, social wellness engagement, and immutable blockchain logging, AURA provides a holistic solution for modern safety and health monitoring.

---

## 🌟 Key Pillars

- **🚨 Immediate Safety**: Pulse-trigger SOS system with live location streaming and automated notification pipeline.
- **🌱 Community Wellness**: A social platform for sharing health goals, activities, and achievements with AI-powered moderation and translation.
- **🛡️ Data Integrity**: A custom Go-based blockchain service ensuring all emergency logs are immutable and verifiable.
- **🤖 Intelligent Assistance**: Integrated LLMs (Gemini AI) for real-time language detection, translation, and content safety.

---

## 🏗️ Project Architecture

AURA is composed of four primary modules:

1.  **Mobile App (`/aura_app`)**: The user interface for safety triggers, social feed, and activity tracking (Flutter).
2.  **Backend (`/aura_backend`)**: The central engine orchestrating services, databases, and external integrations (Spring Boot).
3.  **Blockchain (`/aura_chain`)**: A secure ledger for logging critical system events (Go).
4.  **Admin Dashboard (`/aura_admin`)**: A command center for platform administrators and moderators (Next.js).

---

## 🛠️ Technology Stack

| Module | Core Technologies |
| :--- | :--- |
| **Frontend** | Flutter, Riverpod, Hive, Dio, STOMP |
| **Backend** | Spring Boot 3, JPA, PostgreSQL, Spring Security, JWT |
| **Blockchain** | Go, SHA-256 Hashing, File Persistence |
| **Admin Panel** | Next.js, Tailwind CSS, TypeScript |
| **AI/Cloud** | Gemini AI, Firebase Auth, FCM, Cloud Storage |

---

## 🚀 Getting Started

For detailed setup instructions, architecture deep-dives, and technical workflows, please refer to the comprehensive system documentation:

👉 **[AURA_SYSTEM_OVERVIEW.md](./AURA_SYSTEM_OVERVIEW.md)**

### Quick Summary of Modules:
- **`aura_app`**: Run `flutter pub get` followed by `flutter run`.
- **`aura_backend`**: Use `mvn spring-boot:run` (requires PostgreSQL and Firebase setup).
- **`aura_chain`**: Run `go run cmd/main.go` from the blockchain directory.
- **`aura_admin`**: Run `npm install` and `npm run dev`.

---

## 📄 Documentation

A complete technical manual is available in this repository:
- [AURA System Overview](./AURA_SYSTEM_OVERVIEW.md)
- [Project Features Summary](./AURA_SYSTEM_OVERVIEW.md#14-key-features-summary)
- [System Workflows](./AURA_SYSTEM_OVERVIEW.md#15-system-workflows)

---

## 🛡️ License

This project is documented for professional review and system overview purposes.
