# AURA – AI Powered Wellness, Safety & Social Assistance Platform with Blockchain Integrity

## MCA Main Project Report

---


















1.INTRODUCTION


















 








1. INTRODUCTION		

1.1 PROBLEM STATEMENT 

In today's digitally connected world, individuals face growing challenges related to personal wellness, mental health, and personal safety. Despite the availability of numerous mobile applications, most platforms address only one concern at a time — either fitness tracking, or emergency alerts, or social networking — forcing users to depend on multiple disconnected apps for their daily wellbeing and safety needs. Furthermore, existing emergency response systems are slow, unreliable, and lack any form of tamper-proof verification, making it difficult to ensure the authenticity and accountability of emergency records. Language barriers also create a significant gap in wellness communities, where users from different linguistic backgrounds are unable to share or consume content effectively. There is a clear need for a unified, intelligent platform that combines wellness management, emergency response with verifiable integrity, multilingual community engagement, and real-time communication — all in one secure and user-friendly solution.

1.2 PROPOSED SYSTEM

To address these challenges, AURA is designed as a smart, AI-powered wellness, safety, and social assistance platform that brings together personal health, emergency response, and community engagement into a single mobile application. The system uses Google Gemini AI for automatic language detection and real-time translation, enabling users from different linguistic backgrounds to interact seamlessly in a shared wellness community. AURA integrates a custom-built blockchain module developed in Go to create tamper-proof, cryptographically verified records of every SOS emergency event, ensuring accountability and data integrity. The platform provides real-time messaging via WebSocket, GPS-tracked walking sessions, customizable activity planning, and a comprehensive admin dashboard for content moderation and system monitoring. With its data-driven approach and intelligent decision-making capabilities, AURA helps individuals manage their wellness, stay safe during emergencies, and connect with a supportive community — all within a secure, modern, and feature-rich platform.

1.3 FEATURES OF THE PROPOSED SYSTEM

The proposed AURA system will offer the following key features:

1. User Registration and Authentication – Users can securely register and log in to the platform using Google OAuth, Phone OTP, or email/password authentication through Firebase, ensuring that personal data and wellness records remain protected.
2. Role-Based Access Control – The system provides different access levels for administrators and regular users, allowing secure management of wellness content, SOS events, user accounts, and platform settings.
3. Wellness Community Feed – Users can create, share, and interact with wellness posts across categories such as fitness, mental health, nutrition, and mindfulness, with admin moderation to maintain content quality.
4. AI-Based Multilingual Translation – An integrated Google Gemini AI model automatically detects the language of wellness posts and comments, and translates them to English, enabling inclusive cross-language community engagement.
5. SOS Emergency System with Blockchain Verification – Users can trigger one-tap emergency alerts that capture GPS coordinates, notify trusted contacts, and record the event on an immutable blockchain for tamper-proof verification.
6. Real-Time Messaging – Users can communicate through real-time chat powered by WebSocket/STOMP protocol, with message delivery and read receipts, within a follow-based social framework.
7. GPS Walking Tracker – The platform tracks walking sessions with real-time GPS, recording distance, duration, steps, calories, and route data for health monitoring.
8. Activity Planning and Tracking – Users can browse activity types, schedule personal activities, and log daily progress with duration, distance, and calorie tracking.
9. Admin Dashboard – Administrators can oversee platform operations through a Next.js web dashboard, managing users, moderating wellness content, monitoring SOS events with blockchain data, and broadcasting notifications.
10. Push Notifications – Firebase Cloud Messaging delivers real-time notifications for SOS alerts, follow requests, messages, and system announcements.












2. FUNCTIONAL REQUIREMENTS






2. FUNCTIONAL REQUIREMENTS

2.1 User Authentication
Login: Users can log in using Google OAuth, Phone OTP, or email/password through Firebase Authentication.
Registration: New users are created automatically upon first authentication, with profile completion required before accessing full features.
Session Management: Firebase ID tokens are stored locally and used for authenticated API requests. Session persistence ensures users remain logged in across app restarts.

2.2 Wellness Community Management
Create Wellness Posts: Users can create text and image-based wellness posts, selecting a category such as fitness, mental health, nutrition, or mindfulness.
Interact with Posts: Users can like and comment on wellness posts in the community feed.
AI Translation: Non-English posts and comments are automatically detected and translated to English using Google Gemini AI.
Content Moderation: All posts require admin approval before becoming visible to the community.

2.3 SOS Emergency System
SOS Trigger: Users can trigger a one-tap SOS alert that captures GPS coordinates, notifies trusted contacts, and records the event on the blockchain.
Trusted Contact Management: Users can add, edit, and remove trusted contacts with name, phone, email, relationship, and priority settings.
Offline SOS: SOS events can be triggered even without network connectivity, stored locally in Hive, and synced when the connection is restored.
Blockchain Verification: Each SOS event is recorded on a custom Go blockchain with a SHA-256 hash for tamper-proof verification.

2.4 Admin Controls and Data Management
User Management: Admins can view all registered users, their profiles, and account statuses through the admin dashboard.
Content Moderation: Admins can approve or reject wellness posts with optional rejection reasons.
SOS Monitoring: Admins can view all SOS events with full details including GPS coordinates, blockchain hash, and resolution status.
Notification Broadcasting: Admins can send broadcast notifications to all users or targeted notifications to specific users via Firebase Cloud Messaging.

2.5 User Profile Management
View and Edit Profile: Users can update their name, username, bio, profile image, gender, and date of birth.
Privacy Settings: Users can set their account as private, requiring follow request approval.
Activity History: Users can access their walking session history, activity logs, and daily progress records.
















3. NON-FUNCTIONAL REQUIREMENTS







3. NON-FUNCTIONAL REQUIREMENTS

PERFORMANCE
The platform must efficiently handle multiple users accessing the wellness feed, triggering SOS events, and using real-time messaging simultaneously. API responses and screen loads should complete within 2–3 seconds under normal conditions. The system should support concurrent users without performance degradation or noticeable delays in critical features like SOS triggering.

SCALABILITY
The system should be designed to scale as the user base grows, supporting increasing numbers of wellness posts, SOS events, messaging conversations, and activity records. The backend must maintain high availability with minimal downtime during updates and be capable of recovering quickly from failures to prevent disruption of emergency services.

USABILITY
The mobile interface should be intuitive and easy to navigate, allowing users to access wellness features, trigger SOS, and chat with contacts without confusion. Clear instructions, visual feedback, and smooth animations should guide users through the platform, ensuring a comfortable and efficient experience.

SECURITY
Sensitive data, including user credentials, location information, and emergency records, must be encrypted during storage and transmission. The system implements Firebase Authentication for mobile users, JWT-based admin authentication with BCrypt password hashing, and Spring Security filter chains to ensure users can only access their authorized information.

MAINTAINABILITY
The platform follows modular and well-documented development practices using Flutter, Spring Boot, Go, and Next.js to simplify future updates and debugging. System logs are maintained for API requests, authentication events, and error tracking to support auditing and troubleshooting.

COMPATIBILITY
The mobile application is built with Flutter to ensure cross-platform compatibility across Android and iOS devices. The admin dashboard is compatible with modern web browsers such as Chrome, Firefox, Safari, and Edge, and supports both desktop and tablet devices.

SUPPORTABILITY
The system's architecture and codebase follow clean separation of concerns with feature-based module organization. User guidance through onboarding screens and contextual permissions ensure users understand platform features effectively.


















































4. UML DIAGRAMS



4.1 USE CASES
AURA Use Cases:

4.1.1 User Registration and Profile Setup

ID: UC-01
Name: User Registration and Profile Setup
Description:
Allows a new user to authenticate via Google, Phone, or Email and complete their profile to access the AURA platform.
Pre-conditions:
User is not already registered
System is online
Post-conditions:
User account is created successfully
User can access the Home screen after profile completion
Main Flow:
1. User opens the app and selects authentication method (Google / Phone / Email)
2. User completes the authentication flow (OAuth / OTP / Email-Password)
3. System creates a new user record in the database
4. User is redirected to Profile Completion screen
5. User enters name, username, gender, date of birth, and profile image
6. System validates the data and marks the profile as complete
7. User is redirected to the Home screen
Alternative Flow:
Username already taken → error message displayed
Missing or invalid fields → system requests valid input

4.1.2 User Login

ID: UC-02
Name: User Login
Description:
Allows registered users to log in using their preferred authentication method.
Pre-conditions:
User must be registered
Account must be active
Post-conditions:
User is authenticated
User is redirected to the Home screen
Main Flow:
1. User opens the app
2. User selects login method (Google / Phone / Email)
3. System verifies credentials through Firebase
4. System generates Firebase ID token
5. User is logged in and redirected to the Home screen
Alternative Flow:
Invalid credentials → error message
Invalid OTP → error message, login blocked

4.1.3 Create Wellness Post

ID: UC-03
Name: Create Wellness Post
Description:
Allows users to create wellness posts with content, category, and optional image for the community feed.
Pre-conditions:
User must be logged in
Profile must be complete
Post-conditions:
Post is created and submitted for admin approval
Main Flow:
1. User navigates to the Wellness Feed
2. User taps the Create Post button
3. User enters content text, selects a category, and optionally attaches an image
4. System sends the post to the backend
5. Backend calls Gemini AI for language detection and translation
6. Post is stored with approval status as pending
7. Post becomes visible in the feed after admin approval
Alternative Flow:
Content exceeds character limit → validation error displayed

4.1.4 SOS Emergency Trigger

ID: UC-04
Name: SOS Emergency Trigger
Description:
Allows users to trigger an emergency alert that captures location, notifies contacts, and records the event on the blockchain.
Pre-conditions:
User must be logged in
Location permission must be granted
Trusted contacts must be configured
Post-conditions:
SOS event is recorded in the database and on the blockchain
Trusted contacts are notified
Main Flow:
1. User navigates to the SOS screen
2. User taps the emergency trigger button
3. System captures GPS coordinates automatically
4. System creates an SOS event in the backend database
5. Backend sends event data to the Go blockchain service
6. Blockchain creates a new block with SHA-256 hash
7. System notifies trusted contacts via push notification
8. Confirmation screen displays blockchain hash and event details
Alternative Flow:
No network → event stored locally in Hive, synced later
Location permission denied → prompt user to enable location

4.1.5 Real-Time Messaging

ID: UC-05
Name: Real-Time Chat Messaging
Description:
Allows users to send and receive real-time text messages with other users they mutually follow.
Pre-conditions:
User must be logged in
Users must mutually follow each other
Post-conditions:
Message is delivered to the recipient in real-time
Main Flow:
1. User navigates to the Chat List
2. User selects a conversation or starts a new one
3. User types a message and taps Send
4. Message is transmitted via WebSocket/STOMP
5. Recipient receives the message instantly
6. Message status updates to DELIVERED and then READ

4.1.6 Walking Session Tracking

ID: UC-06
Name: GPS Walking Session
Description:
Allows users to track walking sessions with real-time GPS, recording distance, duration, and steps.
Pre-conditions:
User must be logged in
Location permission must be granted
Post-conditions:
Walking session data is stored in the database
Main Flow:
1. User navigates to the Walking screen
2. User taps Start Walking
3. System begins GPS tracking and records route points
4. User taps Stop when finished
5. System calculates distance, duration, steps, and calories
6. Summary screen displays session results with route map

4.1.7 Content Moderation (Admin)

ID: UC-07
Name: Wellness Content Moderation
Description:
Admin reviews, approves, or rejects wellness posts submitted by users.
Pre-conditions:
Admin must be logged in to the admin dashboard
Pending posts must exist
Post-conditions:
Post approval status is updated
Main Flow:
1. Admin navigates to the Wellness section in the dashboard
2. Admin views list of pending posts
3. Admin reviews post content and selects Approve or Reject
4. If rejected, admin enters a rejection reason
5. System updates the post status accordingly

4.1.8 User Management (Admin)

ID: UC-08
Name: Manage Users
Description:
Admin views and manages all registered user accounts.
Pre-conditions:
Admin must be logged in
Post-conditions:
User account status updated as needed


4.2 USE CASE DIAGRAM




Fig. 4.2.1 Use Case Diagram 


4.3 ACTIVITY DIAGRAM

4.3.1 USER



Fig. 4.2 Activity Diagram – User



4.3.2 ADMIN




Fig. 4.3 Activity Diagram – Admin



4.3.3 SOS EMERGENCY FLOW




Fig. 4.4 Activity Diagram – SOS Emergency Flow



4.4 CLASS DIAGRAM




Fig. 4.5 Class Diagram


























5. TEST CASES



5. TEST CASES

5.1 LOGIN
SR_NO	TEST CASE	FEATURE	DESCRIPTION	STEPS TO EXECUTE	EXPECTED RESULTS
1	TC-01	User Interface	Check the appearance of the login page	1. Load the authentication screen of AURA	UI elements should be properly aligned, login options and navigation links should function correctly
2	TC-02	Google Login	Verify login with Google OAuth	1. Open auth screen 2. Tap "Continue with Google" 3. Select Google account	User is authenticated and redirected to Home screen
3	TC-03	Phone Login	Verify login with phone OTP	1. Tap "Login with Phone" 2. Enter phone number 3. Enter OTP	OTP verified, user logged in, redirected to Home screen
4	TC-04	Email Login	Verify login with email and password	1. Tap "Login with Email" 2. Enter email and password 3. Tap Login	Credentials validated, user redirected to Home screen
5	TC-05	Invalid Login	Verify login with invalid credentials	1. Enter wrong email/password 2. Tap Login	User remains on login page with error message displayed

Table 5.1 Test Case For Login

5.2 REGISTRATION
SR_NO	TEST CASE	FEATURE	DESCRIPTION	STEPS TO EXECUTE	EXPECTED RESULTS
1	TC-01	User Interface	Check the appearance of the profile completion page	1. Complete authentication for first time	Profile completion UI elements properly aligned, input labels clear
2	TC-02	Profile Form	Verify behavior with empty fields	1. Open profile completion 2. Tap "Submit" without filling	Error messages displayed for required fields
3	TC-03	Profile Form	Validate form with duplicate username	1. Enter an already taken username 2. Tap "Submit"	Error message shown: "Username already taken"
4	TC-04	Profile Form	Check successful profile completion	1. Fill name, username, gender, DOB 2. Upload image 3. Tap "Submit"	Profile completed successfully, user redirected to Home screen
5	TC-05	Login After Registration	Verify session persistence	1. Complete registration 2. Close app 3. Reopen app	App auto-logs in using stored Firebase token

Table 5.2 Test Case For Registration

5.3 WELLNESS POSTS (USER)
SR_NO	TEST CASE	FEATURE	DESCRIPTION	STEPS TO EXECUTE	EXPECTED RESULTS
1	TC-01	Post Creation	Verify user can create a wellness post	1. Login 2. Navigate to Wellness Feed 3. Tap Create 4. Enter content, select category 5. Submit	Post created and submitted for admin approval
2	TC-02	Post Interaction	Verify user can like a post	1. Open Wellness Feed 2. Tap like button on a post	Like count incremented, like record created
3	TC-03	Comment	Verify user can comment on a post	1. Open a post 2. Enter comment 3. Submit	Comment created, AI translation triggered
4	TC-04	AI Translation	Verify non-English post is translated	1. Create post in Hindi 2. Submit	Language detected as "hi", translated content stored and displayed

Table 5.3 Test Case For Wellness Posts

5.4 SOS EMERGENCY
SR_NO	TEST CASE	FEATURE	DESCRIPTION	STEPS TO EXECUTE	EXPECTED RESULTS
1	TC-01	SOS Trigger	Verify SOS trigger with network	1. Login 2. Navigate to SOS 3. Tap trigger button	SOS event created, GPS captured, blockchain block created, contacts notified
2	TC-02	Offline SOS	Verify SOS trigger without network	1. Disable network 2. Tap SOS trigger	Event stored locally in Hive, queued for sync
3	TC-03	Blockchain Verify	Verify blockchain hash matches	1. View SOS event details 2. Check blockchain hash	Block hash matches blockchain record, chain validates as valid
4	TC-04	Trusted Contacts	Verify adding trusted contact	1. Navigate to SOS Settings 2. Add contact details 3. Save	Contact saved successfully with priority

Table 5.4 Test Case For SOS Emergency

5.5 MESSAGING
SR_NO	TEST CASE	FEATURE	DESCRIPTION	STEPS TO EXECUTE	EXPECTED RESULTS
1	TC-01	Send Message	Verify sending a text message	1. Open chat 2. Type message 3. Tap Send	Message delivered via WebSocket, status = SENT
2	TC-02	Read Receipt	Verify message read receipt	1. Recipient opens conversation	Message status updates to DELIVERED then READ
3	TC-03	New Chat	Verify creating new conversation	1. Navigate to user profile 2. Tap Message	New conversation created, chat screen opens

Table 5.5 Test Case For Messaging

5.6 ADMIN DASHBOARD
SR_NO	TEST CASE	FEATURE	DESCRIPTION	STEPS TO EXECUTE	EXPECTED RESULTS
1	TC-01	Post Moderation	Verify admin can approve a post	1. Login to admin dashboard 2. Navigate to Wellness 3. Approve post	Post marked as approved, visible to users
2	TC-02	Post Rejection	Verify admin can reject a post	1. Navigate to Wellness 2. Reject with reason	Post marked as not visible, rejection reason stored
3	TC-03	Broadcast	Verify sending broadcast notification	1. Navigate to Notifications 2. Compose message 3. Send	Notification sent to all users via FCM
4	TC-04	SOS Monitoring	Verify viewing SOS event details	1. Navigate to SOS Events 2. View event	Full event details with blockchain hash and maps URL displayed

Table 5.6 Test Case For Admin Dashboard






6. INPUT DESIGN AND
 OUTPUT DESIGN



6. INPUT DESIGN AND OUTPUT DESIGN

6.1 INPUT DESIGN
The input design of AURA focuses on simplicity, accuracy, and user-friendliness to ensure smooth data entry for both mobile users and administrators. The system is designed to minimize errors, validate critical inputs, and improve overall usability during wellness posting, SOS configuration, and activity management.

User Input Design:
Login and Registration Forms:
Users can authenticate using Google OAuth, Phone OTP, or Email/Password through Firebase Authentication.
Profile completion fields include name, username, gender, date of birth, and profile image.
Username fields include real-time availability checking to prevent duplicates.
Password fields include validation rules (minimum length and character requirements) to enhance account security.

Wellness Post Input:
Users can enter wellness content with a 500-character limit and select a category from predefined options (General, Motivation, Health Tip, Fitness, Mental Health, Nutrition, Mindfulness).
Optional image attachment is available through camera or gallery selection.
Comment input allows up to 1000 characters.

SOS Configuration Input:
SOS trigger requires a single tap with automatic GPS capture — no manual coordinate entry.
SOS Settings allow users to configure a custom emergency message (500 characters).
Trusted contact forms capture name, phone, email, relationship, and priority.

Walking and Activity Input:
Walking sessions require only a Start/Stop button — GPS tracking is automatic.
Activity scheduling allows users to select activity type, set duration, and choose days.

Navigation and Interaction:
Users can easily navigate between Wellness Feed, SOS, Walking, Chat, Activities, and Profile screens via bottom navigation and drawer.
Search and filter options allow quick access to users, posts, and chat conversations.

Admin Input Design:
Authentication:
Admins log in using email and password through the admin dashboard.
Content Moderation:
Admins can approve or reject wellness posts with an optional rejection reason text field.
Notification Composer:
Admins can compose notifications with title, body, notification type selector, and target user selection or broadcast toggle.

Data Validation:
Real-time validation is applied across all forms, including authentication, profile completion, post creation, and SOS configuration.
Email format, password strength, phone number format, and character limits are validated at both frontend (Flutter/Next.js) and backend (Spring Boot) levels.
Mandatory fields are clearly marked to prevent incomplete submissions.
Clear and informative error messages guide users to correct mistakes quickly and efficiently.

6.2 OUTPUT DESIGN
6.2.1. Introduction to Output Design
The output design of AURA is focused on delivering clear, accurate, and actionable information to both mobile users and administrators. The system enhances user experience through interactive feeds, summary screens, real-time notifications, and structured analytics. All outputs are designed to be visually appealing, data-driven, and easy to interpret.

User Output Design:
Home Screen:
Displays tabbed navigation with wellness feed preview, quick action buttons for SOS, Walking, and Messaging, and a daily activity tracker widget.

Wellness Feed:
Card-based scrollable feed with user avatar, post content (original and translated), like count, comment count, category badge, and timestamp.

SOS Confirmation Screen:
Success overlay displaying blockchain hash, event ID, number of contacts notified, and Google Maps URL.

Walking Session Summary:
Displays distance (meters/km), duration, step count, calories burned, and route map with polyline visualization.

Chat List:
Conversation cards with participant name, last message preview, unread count badge, and timestamp.

Notification Screen:
Chronological notification list with type icons, title, body, and deep link actions.

Admin Output Design:
Dashboard:
StatCard components displaying total users, active SOS events, pending wellness posts, and notification counts.

User Management Table:
Paginated user list with name, email, phone, status, signup method, and last login.

SOS Events Table:
Event list with user details, coordinates, status badge, blockchain verification data, maps link, and timestamps.

Wellness Posts Table:
Post list with content preview, category, approval status, translation status, and moderation actions.

Key Output Features:
Real-Time Feedback: Users receive instant visual feedback after actions such as liking a post, sending a message, or triggering SOS.
Confirmation Messages: Displayed for actions like profile updates, post submissions, and SOS triggers.
Structured Reports: SOS event details, walking summaries, and activity logs are presented using cards, tables, and clear visual hierarchy across mobile and web interfaces.
Push Notifications: Real-time FCM notifications for SOS alerts, follow requests, messages, and system announcements.






 

























7. SYSTEM IMPLEMENTATION













7. System Implementation

7.1 Introduction
The AURA system is a multi-platform application developed to support personal wellness management, emergency safety, and community engagement. It is designed to help individuals manage their health, respond to emergencies with verifiable integrity, communicate in real-time, and participate in a multilingual wellness community. The mobile frontend is built using Flutter, offering a cross-platform, responsive, and interactive user interface that allows users to access wellness features, trigger SOS, track walks, and chat in real-time. The backend is implemented using Spring Boot, which handles API requests, authentication, wellness management, SOS processing, messaging, and content moderation. PostgreSQL is used as the database to store user profiles, wellness posts, SOS events, conversations, walking sessions, and activity logs in a structured and reliable manner. A custom blockchain module built in Go provides tamper-proof recording of emergency events. The admin dashboard is developed using Next.js with React and TypeScript for centralized platform governance. Google Gemini AI is integrated for automatic language detection and translation of wellness content. Firebase provides authentication services and push notification delivery. This overall architecture creates a scalable, secure, and intelligent platform that combines wellness, safety, and community features into a unified solution.

7.2 Project Structure
The AURA project follows a clean and modular architecture with clear separation between mobile frontend, backend, blockchain, and admin dashboard components, ensuring scalability, maintainability, and ease of development.

```
AURA/
│
├── aura_app/                              # Mobile Application (Flutter)
│   ├── lib/
│   │   ├── main.dart                      # App entry point
│   │   ├── app.dart                       # MaterialApp configuration
│   │   ├── core/
│   │   │   ├── api/                       # API configuration
│   │   │   ├── config/                    # App configuration
│   │   │   ├── constants/                 # App-wide constants
│   │   │   ├── network/
│   │   │   │   ├── connectivity/          # Network connectivity wrapper
│   │   │   │   ├── push/                  # FCM push notification handler
│   │   │   │   └── sync/                  # Background sync manager
│   │   │   ├── providers/                 # Global Riverpod providers
│   │   │   ├── routes/                    # Route generation (35+ routes)
│   │   │   ├── services/                  # Local notification service
│   │   │   ├── theme/                     # Light/Dark theme definitions
│   │   │   └── widgets/                   # 16 reusable widgets
│   │   └── features/
│   │       ├── auth/                      # Authentication module
│   │       ├── user/                      # User management module
│   │       ├── wellness/                  # Wellness feed module
│   │       ├── sos/                       # SOS emergency module
│   │       ├── messaging/                 # Real-time chat module
│   │       ├── walking/                   # Walking tracker module
│   │       ├── alarm/                     # Alarm system module
│   │       ├── activity_types/            # Activity types module
│   │       ├── user_activities/           # User activities module
│   │       ├── daily_activity/            # Daily activity module
│   │       ├── notification/              # Notifications module
│   │       └── home/                      # Home screen module
│   ├── pubspec.yaml                       # Flutter dependencies
│   └── .env                               # Environment variables (API_URL)
│
├── aura_backend/                          # Backend API (Spring Boot)
│   ├── src/main/java/com/backend/aura/
│   │   ├── AuraApplication.java           # Spring Boot entry point
│   │   ├── config/                        # CORS, Firebase, Security, WebSocket config
│   │   ├── core/                          # Centralized logging
│   │   └── modules/
│   │       ├── auth/                      # Authentication (Firebase + Admin JWT)
│   │       ├── user/                      # User management
│   │       ├── wellness/                  # Wellness posts, comments, likes
│   │       ├── sos/                       # SOS events, settings, live location
│   │       ├── messaging/                 # Conversations, messages, follow system
│   │       ├── notification/              # Push notifications
│   │       ├── activity/                  # Activities, walking, daily logs
│   │       └── admin/                     # Admin management
│   ├── pom.xml                            # Maven dependencies
│   └── application.properties             # Backend configuration
│
├── aura_chain/                            # Blockchain Module (Go)
│   ├── cmd/main.go                        # Entry point
│   ├── internal/
│   │   ├── block/block.go                 # Block struct with SHA-256 hashing
│   │   ├── blockchain/chain.go            # Chain management with mutex locking
│   │   ├── server/http.go                 # REST API server (Gorilla Mux)
│   │   ├── storage/file.go               # File-based block persistence
│   │   └── transaction/tx.go             # SOS transaction structure
│   ├── data/                              # Block JSON file storage
│   └── .env                               # Configuration (port, storage path)
│
├── aura_admin/                            # Admin Dashboard (Next.js)
│   ├── app/
│   │   ├── page.tsx                       # Landing/Login page
│   │   ├── admin/
│   │   │   ├── dashboard/page.tsx         # Analytics dashboard
│   │   │   ├── users/page.tsx             # User management
│   │   │   ├── wellness/page.tsx          # Wellness post moderation
│   │   │   ├── sos-events/page.tsx        # SOS event monitoring
│   │   │   ├── notifications/page.tsx     # Notification broadcasting
│   │   │   ├── activities/page.tsx        # Activity management
│   │   │   └── settings/page.tsx          # Admin settings
│   │   └── components/                    # Reusable UI components
│   ├── package.json                       # Frontend dependencies
│   └── .env                               # Environment variables (API_URL)
│
└── README.md                              # Project overview and setup guide
```

Each backend module is responsible for specific operations such as request handling, data validation, business logic processing, and response formatting. The Flutter mobile app follows a feature-based architecture with data, domain, and presentation layers for each feature. The admin dashboard is developed as a modern Next.js application using reusable React components for a responsive and interactive administrative experience.

7.3. Database Design and Models
The AURA system utilizes PostgreSQL, a robust relational database management system, to ensure structured, consistent, and reliable data storage. Spring Data JPA with Hibernate is used as the Object-Relational Mapping (ORM) tool to define database models and manage relationships efficiently. The database is designed to maintain data integrity, scalability, and efficient handling of user information, wellness content, SOS events, conversations, and activity records.

Primary Data Models:
User Fields: uid, phone, email, name, username, profileImageUrl, gender, dob, bio, signupMethod, profileCompleted, isPrivate, fcmToken, accountStatus, createdAt, updatedAt, lastLoginAt
WellnessUpdate Fields: id, userId, content, imageUrl, category, likesCount, isApproved, isVisible, translatedContent, detectedLanguage, translationFailed, createdAt
SOSEvent Fields: id, userId, latitude, longitude, address, message, status, blockHash, blockIndex, triggeredAt, resolvedAt
Conversation Fields: id, participantOneId, participantTwoId, lastMessageAt, lastMessagePreview, unreadCountOne, unreadCountTwo
WalkingSession Fields: id, userId, startTime, endTime, distanceMeters, durationSeconds, stepsCount, caloriesBurned, routePointsJson

Relationships:
One-to-Many: A user can create multiple wellness posts, trigger multiple SOS events, participate in multiple conversations, and have multiple walking sessions.
Foreign Key References:
- WellnessUpdate.userId references User.uid
- SOSEvent.userId references User.uid
- WalkingSession.userId references User.uid
- Message.conversationId references Conversation.id
- TrustedContact.sosSettingsId references SOSSettings.id

Each model is structured to ensure smooth integration across system modules. The User model manages authentication and profile data. The WellnessUpdate and WellnessComment models handle community content with AI translation fields. The SOSEvent model captures emergency data with blockchain verification references. The Conversation and Message models support real-time messaging. This relational design ensures accurate data tracking, performance monitoring, and efficient retrieval of historical records.

7.3.1 Table name: Users
Field Name	Data Type	Constraints	Description
uid	VARCHAR(255)	PRIMARY KEY	Firebase UID - unique identifier
phone	VARCHAR(255)	UNIQUE	User phone number
email	VARCHAR(255)	UNIQUE	User email address
name	VARCHAR(255)	NOT NULL	Full name of the user
username	VARCHAR(255)	UNIQUE	Unique display username
profile_image_url	VARCHAR(255)	NULL	Profile image URL
gender	VARCHAR(50)	NULL	User gender
dob	VARCHAR(50)	NULL	Date of birth
bio	VARCHAR(200)	NULL	User biography
signup_method	VARCHAR(50)	NOT NULL	GOOGLE, PHONE, or EMAIL
profile_completed	BOOLEAN	DEFAULT FALSE	Profile completion flag
is_private	BOOLEAN	DEFAULT FALSE	Private account flag
fcm_token	VARCHAR(512)	NULL	Firebase Cloud Messaging token
account_status	VARCHAR(50)	DEFAULT 'ACTIVE'	ACTIVE, SUSPENDED, or DELETED
created_at	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	Date and time of registration
updated_at	TIMESTAMP	NULL	Last update time
last_login_at	TIMESTAMP	NULL	Last login time

Table 7.1 Users Table Database Design

7.3.2 Table name: SOS Events
Field Name	Data Type	Constraints	Description
id	UUID	PRIMARY KEY, AUTO	Unique identifier for each event
user_id	VARCHAR(255)	FOREIGN KEY REFERENCES Users(uid) ON DELETE CASCADE	References the Users table
latitude	DOUBLE	NOT NULL	GPS latitude
longitude	DOUBLE	NOT NULL	GPS longitude
address	VARCHAR(255)	NULL	Reverse geocoded address
message	VARCHAR(500)	NULL	Emergency message
contacts_notified	INTEGER	DEFAULT 0	Number of contacts notified
status	VARCHAR(50)	NOT NULL	TRIGGERED, ACKNOWLEDGED, or RESOLVED
triggered_at	TIMESTAMP	NOT NULL	Event trigger time
resolved_at	TIMESTAMP	NULL	Resolution time
resolved_by	VARCHAR(255)	NULL	Resolver identifier
resolution_notes	TEXT	NULL	Resolution details
synced_from_offline	BOOLEAN	DEFAULT FALSE	Offline sync flag
block_hash	VARCHAR(255)	NULL	Blockchain block hash
block_index	BIGINT	NULL	Blockchain block index
maps_url	VARCHAR(500)	NULL	Google Maps link

Table 7.2 SOS Events Table Database Design

7.3.3 Table name: Trusted Contacts
Field Name	Data Type	Constraints	Description
id	UUID	PRIMARY KEY, AUTO	Contact identifier
sos_settings_id	UUID	FOREIGN KEY REFERENCES SOS_Settings(id)	Parent settings reference
user_id	VARCHAR(255)	NOT NULL	Owner user ID
name	VARCHAR(255)	NOT NULL	Contact name
phone	VARCHAR(255)	NOT NULL	Contact phone number
email	VARCHAR(255)	NULL	Contact email
relationship	VARCHAR(255)	NULL	Relationship type
priority	INTEGER	DEFAULT 1	Notification priority
is_active	BOOLEAN	DEFAULT TRUE	Active flag
created_at	TIMESTAMP	NOT NULL	Creation time

Table 7.3 Trusted Contacts Table Database Design

7.3.4 Table name: Wellness Updates
Field Name	Data Type	Constraints	Description
id	VARCHAR(255)	PRIMARY KEY, AUTO (UUID)	Post identifier
user_id	VARCHAR(255)	FOREIGN KEY REFERENCES Users(uid) ON DELETE CASCADE	Author reference
content	VARCHAR(500)	NOT NULL	Post content text
image_url	VARCHAR(255)	NULL	Attached image URL
category	VARCHAR(50)	NOT NULL	Wellness category (enum)
likes_count	INTEGER	DEFAULT 0	Total like count
is_approved	BOOLEAN	DEFAULT FALSE	Admin approval status
is_visible	BOOLEAN	DEFAULT TRUE	Visibility flag
translated_content	VARCHAR(500)	NULL	AI translated English content
detected_language	VARCHAR(50)	NULL	Source language code
translation_failed	BOOLEAN	DEFAULT FALSE	Translation failure flag
created_at	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	Creation time

Table 7.4 Wellness Updates Table Database Design

7.3.5 Table name: Conversations
Field Name	Data Type	Constraints	Description
id	VARCHAR(255)	PRIMARY KEY, AUTO (UUID)	Conversation identifier
participant_one_id	VARCHAR(255)	NOT NULL	First participant user ID
participant_two_id	VARCHAR(255)	NOT NULL	Second participant user ID
created_at	TIMESTAMP	NULL	Creation time
last_message_at	TIMESTAMP	NULL	Last message time
last_message_preview	VARCHAR(255)	NULL	Preview of last message
unread_count_one	INTEGER	DEFAULT 0	Unread count for participant one
unread_count_two	INTEGER	DEFAULT 0	Unread count for participant two

Table 7.5 Conversations Table Database Design

7.3.6 Table name: Messages
Field Name	Data Type	Constraints	Description
id	VARCHAR(255)	PRIMARY KEY, AUTO (UUID)	Message identifier
conversation_id	VARCHAR(255)	FOREIGN KEY REFERENCES Conversations(id)	Parent conversation
sender_id	VARCHAR(255)	FOREIGN KEY REFERENCES Users(uid)	Message sender
content	TEXT	NOT NULL	Message content
type	VARCHAR(50)	DEFAULT 'TEXT'	TEXT, IMAGE, or SYSTEM
status	VARCHAR(50)	DEFAULT 'SENT'	SENT, DELIVERED, or READ
sent_at	TIMESTAMP	NULL	Send time
delivered_at	TIMESTAMP	NULL	Delivery time
read_at	TIMESTAMP	NULL	Read time

Table 7.6 Messages Table Database Design

7.3.7 Table name: Walking Sessions
Field Name	Data Type	Constraints	Description
id	VARCHAR(255)	PRIMARY KEY, AUTO (UUID)	Session identifier
user_id	VARCHAR(255)	FOREIGN KEY REFERENCES Users(uid) ON DELETE CASCADE	Walking user
start_time	TIMESTAMP	NOT NULL	Session start time
end_time	TIMESTAMP	NULL	Session end time
distance_meters	DOUBLE	DEFAULT 0.0	Total distance walked
duration_seconds	INTEGER	DEFAULT 0	Total duration
steps_count	INTEGER	DEFAULT 0	Step count
calories_burned	DOUBLE	NULL	Calories burned
route_points_json	TEXT	NULL	Serialized route data
is_active	BOOLEAN	DEFAULT TRUE	Active flag
created_at	TIMESTAMP	NOT NULL	Creation time

Table 7.7 Walking Sessions Table Database Design

7.4 URL Routing and Views
The AURA system uses Spring Boot for handling URL routing, ensuring efficient and structured communication between the Flutter mobile app, Next.js admin dashboard, and the backend services. Each API endpoint corresponds to specific functionalities such as user authentication, wellness management, SOS processing, real-time messaging, and administrative monitoring. The routing structure is modularized for better maintainability and scalability, with separate controller classes for each major feature.

Routing Structure
Routes are organized into different modules to maintain clear separation of concerns:
/api/auth – Handles Firebase token login and admin JWT authentication
/api/user – Manages user profile operations such as viewing and updating profile details
/api/wellness – Handles wellness post creation, feed retrieval, likes, and comments
/api/sos – Processes SOS event triggering, settings management, trusted contacts, and live location
/api/messaging – Manages conversations, messages, and follow relationships via WebSocket
/api/notifications – Handles push notification sending and broadcasting
/api/walking – Manages walking session start, update, and stop operations
/api/activities – Handles activity types, user activities, and daily logs
/api/admin – Provides administrative controls for user management, SOS monitoring, and wellness moderation

Example Endpoints
Endpoint	HTTP Method	Description
/api/auth/firebase/login	POST	Authenticate via Firebase token
/api/admin/auth/login	POST	Admin JWT login
/api/user/profile	GET	Retrieve user profile
/api/user/profile	PUT	Update user profile
/api/wellness/feed	GET	Get wellness feed
/api/wellness	POST	Create wellness post
/api/wellness/{id}/like	POST	Like or unlike a post
/api/wellness/{id}/comments	POST	Create a comment
/api/sos/trigger	POST	Trigger SOS event
/api/sos/settings	GET	Get SOS settings
/api/sos/contacts	POST	Add trusted contact
/api/sos/live/start	POST	Start live location session
/api/messaging/conversations	GET	Get user conversations
/api/messaging/follow	POST	Follow a user
/api/walking/start	POST	Start walking session
/api/walking/{id}/stop	PUT	Stop walking session
/api/notifications/broadcast	POST	Broadcast notification
/api/admin/sos/events	GET	Get all SOS events (Admin)

Blockchain Endpoints (Go Service):
/block	POST	Add SOS block to blockchain
/block/{index}	GET	Get block by index
/validate	GET	Validate entire chain
/latest	GET	Get latest block

Views:
The mobile frontend, developed using Flutter, provides an intuitive and interactive user experience with the following key views:
Splash Screen: App loading with logo animation
Welcome Screen: Onboarding overview with authentication options
Home Screen: Tabbed navigation with wellness feed, SOS, walking, and activity access
Wellness Feed: Card-based scrollable community feed with AI translation toggle
SOS Screen: One-tap emergency trigger with GPS capture
Chat Screen: Real-time messaging interface with WebSocket delivery
Walking Screen: GPS-tracked walking session with live route map
Profile Screen: User details, followers, and activity history

HTTP Methods Used:
GET: Retrieve user profiles, wellness feed, conversations, walking history, and analytics
POST: Submit new authentication, wellness posts, SOS triggers, messages, and notification requests
PUT: Update profile information, walking sessions, and SOS event resolution
DELETE: Remove trusted contacts, wellness posts, or follow relationships

7.5 Templates and Frontend Integration
The mobile frontend of the AURA system is developed using Flutter, a cross-platform UI framework that enables native performance on both Android and iOS from a single codebase. The application follows a feature-based architecture to promote reusability, modularity, and clean code organization.

The app uses a consistent Material Design theme with support for both Light and Dark modes, managed through Riverpod state providers. A global bottom navigation bar and drawer provide access to Home, Wellness, SOS, Walking, Chat, Activities, and Profile sections. The user interface is fully responsive across different device sizes.

Static assets such as images, icons, and animations are organized within the assets/ directory for optimized performance and structured project management.

The admin dashboard frontend is built using Next.js with React and TypeScript, providing a modern and responsive web interface. It uses a sidebar layout component with navigation links to Dashboard, Users, Wellness, SOS Events, Notifications, Activities, and Settings pages.

Example Flutter screens/components:
- SplashScreen – App loading screen with animations
- AuthScreen – Authentication method selection
- ProfileCompleteScreen – First-time profile setup
- HomeScreen – Main navigation hub with tabbed content
- WellnessFeedScreen – Community wellness post feed
- SOSTriggerScreen – Emergency trigger interface
- ChatScreen – Real-time messaging interface
- WalkingScreen – GPS walking tracker with live map

7.6 User Authentication and Authorization
User authentication in AURA is implemented using Firebase Authentication for mobile users and JWT-based authentication for admin users.

Mobile Users:
Firebase Authentication supports three methods — Google OAuth, Phone OTP, and Email/Password. When a user authenticates, Firebase issues an ID token that is sent with every API request in the Authorization header. The Spring Boot backend verifies this token using the Firebase Admin SDK through a custom FirebaseAuthFilter that intercepts all incoming requests before they reach the controllers. The authenticated user context is stored in AuthenticatedUserContext for downstream use.

Admin Users:
The admin dashboard uses email/password login with JWT token-based session management. The /api/admin/auth/login endpoint validates credentials against BCrypt-hashed passwords and returns a JWT token signed with HMAC-SHA256. Tokens include adminId, email, and role claims and expire after 24 hours.

Custom User Roles are defined as follows:
Admin: Can manage all users, moderate wellness content, monitor SOS events with blockchain data, broadcast notifications, and oversee platform performance through the admin dashboard.
User: Can manage their own profile, create wellness posts, trigger SOS emergencies, chat with contacts, track walking sessions, and manage personal activities.

Role-Based Access Control (RBAC) is enforced using Spring Security filter chains. Administrative functionalities are restricted to authenticated admin users, while regular mobile users can only access their own operational data through Firebase-authenticated requests.

7.7 Forms and Validation
In AURA, forms are used to collect user input for various wellness and safety functionalities, including:
- Profile Completion: Captures name, username (with real-time availability check), gender, date of birth, profile image, and bio.
- Login: Accepts email/password, phone number with OTP, or Google OAuth.
- Wellness Post Creation: Allows text content (500 character limit), category selection, and optional image attachment.
- SOS Settings: Allows custom emergency message (500 characters) and trusted contact details.
- Comment Input: Text field for comments (1000 character limit).
- Walking Session: Start/Stop button with automatic GPS capture.
- Chat Message: Text field with send button.

Validation Rules:
- Mandatory fields are required to prevent incomplete submissions.
- Username must be unique — validated in real-time via API call.
- Email addresses must be in a valid format.
- Passwords are checked for strength and minimum security criteria.
- Character limits are enforced on post content, comments, bio, and emergency messages.

Error Handling and Feedback:
Custom error messages and real-time validation feedback guide users in correcting input mistakes. This improves usability and ensures accurate and reliable data entry across all wellness and safety forms.

7.8 Business Logic and Core Functionality
The core functionality of AURA focuses on wellness community management, SOS emergency handling, real-time communication, and activity tracking. The system implements the following business logic:

Wellness Community Management:
Users can create, like, and comment on wellness posts. All posts require admin approval before visibility. Non-English content is automatically detected and translated to English using Google Gemini AI. Translation results and status are tracked per post and comment.

SOS Emergency Processing:
When a user triggers SOS, the system captures GPS coordinates, creates an SOS event record, sends the event data to the Go blockchain service for immutable recording, and notifies all trusted contacts via push notifications. Offline SOS events are stored locally in Hive and synced when connectivity is restored.

Real-Time Messaging:
The messaging system uses WebSocket/STOMP protocol for instant message delivery. Users must mutually follow each other to chat. Message status transitions through SENT → DELIVERED → READ with timestamps for each state.

Walking Session Management:
GPS tracking captures route points, calculates distance, duration, steps, and calories. Sessions can be started and stopped by the user, with all data persisted to the backend.

Admin Controls:
Admins can moderate content, manage users, monitor SOS events with blockchain verification data, and broadcast notifications to the entire user base or specific users.

7.9 Testing and Debugging
Testing Process:
Unit Testing: Individual backend modules such as User Management, Wellness Service, SOS Service, Messaging Service, and Walking Service are tested to ensure correct data processing and business logic implementation.

API Testing: RESTful API endpoints for authentication, wellness operations, SOS triggering, messaging, and admin functions are tested to verify proper request handling, response accuracy, and error management.

Integration Testing: Interactions between the Flutter mobile app, Spring Boot backend, Go blockchain service, and Next.js admin dashboard are tested to confirm smooth data exchange, correct API integration, and seamless workflow execution.

User Acceptance Testing (UAT): The system is tested from the end-user perspective to ensure usability, accurate SOS triggering, correct AI translation, reliable messaging delivery, and proper walking tracking.

Tools Used:
Postman: For testing REST API endpoints and verifying request/response behavior.
Flutter DevTools: For inspecting widget trees, performance profiling, and debugging Dart code.
Browser Developer Tools: For debugging the Next.js admin dashboard, inspecting network requests, and testing UI rendering.

Debugging:
Spring Boot Logging: Custom AuraLogger utility with structured logging for API requests, authentication events, and error tracking.
Flutter Debug Console: Used to trace state changes, API responses, and widget rendering issues.
Go Server Logs: Used to monitor blockchain operations, block creation, and chain validation events.
Browser DevTools: Used to detect JavaScript errors, monitor network activity, and debug admin dashboard issues.


















8. AI Integration 
 








The AI Integration module in AURA enhances user experience by providing intelligent multilingual translation for the wellness community. This module breaks language barriers, enabling users from diverse linguistic backgrounds to share and consume wellness content seamlessly. The AI component uses Google Gemini API for language detection and real-time translation.

1. AI Translation Engine
The AI-powered translation engine automatically detects the language of wellness posts and comments and translates non-English content to English.
Purpose: To enable inclusive, cross-language participation in the wellness community.
Features:
- Automatically detects the source language of posts and comments.
- Translates non-English content to English using Google Gemini AI.
- Stores both original and translated content for display.
- Tracks translation status (PENDING, TRANSLATED, FAILED, NOT_NEEDED).
- Handles translation failures gracefully, displaying original content.
APIs / Technologies Used:
- Google Gemini AI API for language detection and translation.
- Spring Boot backend as a proxy for secure API key management.
- PostgreSQL database for storing translation results.

2. Translation Pipeline
The translation process follows a backend-mediated architecture:
- User creates a post or comment in any language.
- Flutter app sends content to Spring Boot backend via REST API.
- Backend sends content to Gemini AI for language detection.
- If the detected language is not English, a translation request is made.
- Both original content and English translation are stored in the database.
- Flutter app displays both versions with a translation toggle.

3. AI Data Model
The AI integration is embedded directly into the wellness data models:
WellnessUpdate: translatedContent, detectedLanguage, translationFailed
WellnessComment: originalContent, translatedContent, detectedLanguage, translationStatus

4. Security and Data Handling
The AI module operates only within authenticated user sessions. All translation requests are processed through the Spring Boot backend, which acts as a secure proxy for Gemini AI API calls. API keys are managed through environment variables and are never exposed to the client application. User-specific content is processed securely through role-based authorization mechanisms.



9. FUTURE ENHANCEMENTS



9. FUTURE ENHANCEMENTS

1. Improved User Interface (UI/UX):
Optimize the mobile experience with additional animations, accessibility features, and personalized theme options.
Implement personalized home screens displaying wellness recommendations, activity summaries, and safety insights tailored to each user's behavior.

2. Advanced Wellness Features:
Introduce group wellness challenges where users can create or join community challenges with leaderboards and milestones.
Enable video and audio content support in wellness posts for richer community engagement.

3. Safety and Emergency Enhancements:
Implement voice-based SOS triggering for hands-free emergency activation during critical situations.
Introduce geofencing-based safety zones — automatic SOS triggers activate when a user exits a designated safe area.
Add video calling integration for emergency verification between trusted contacts.

4. Intelligent Assistance and AI Enhancements:
Enhance the AI engine to provide sentiment analysis on wellness posts for community mental health monitoring.
Introduce an AI chatbot powered by Gemini for immediate wellness guidance and coping strategies.
Implement predictive SOS alerts based on movement patterns and location risk analysis.

5. Admin Panel Enhancements:
Offer detailed analytics on platform usage, user engagement, and community wellness trends.
Enable bulk management of users, posts, and notification campaigns.
Provide downloadable system-wide performance and sustainability reports.

6. Security Improvements:
Implement two-factor authentication (2FA) for admin logins.
Enhance data privacy through end-to-end encryption for messaging and secure session handling.

7. Platform and Infrastructure Enhancements:
Evolve the blockchain from single-node to a distributed multi-node network for enhanced immutability.
Containerize all four modules with Docker and orchestrate via Kubernetes for auto-scaling.
Add wearable device integration (smartwatches, fitness bands) for importing real-time health metrics.




































10. CONCLUSION



10. CONCLUSION

The AURA system provides an intelligent and comprehensive platform for personal wellness management, emergency safety, and community engagement. By combining a cross-platform Flutter mobile application with a robust Spring Boot backend, a custom Go blockchain for emergency verification, and a modern Next.js admin dashboard, the platform ensures secure, accurate, and seamless handling of wellness, safety, and communication features for both users and administrators. AURA simplifies complex wellness and emergency workflows through structured user interfaces, real-time interactions, and intelligent AI-powered translation, enabling individuals to manage their health, stay safe during emergencies, and connect with a supportive multilingual community.

In addition to its core capabilities, AURA integrates Google Gemini AI for automatic language detection and translation, a custom SHA-256 blockchain for tamper-proof emergency recording, and WebSocket-based real-time messaging for instant communication. The system supports multi-method authentication through Firebase, GPS-tracked walking sessions for health monitoring, and comprehensive activity planning with daily progress tracking. Future enhancements such as AI chatbot integration, voice-based SOS triggering, sentiment analysis, wearable device connectivity, and distributed blockchain networking will further strengthen the platform's effectiveness and scalability. Strong authentication mechanisms, role-based access control, Spring Security filter chains, and secure API communication ensure data privacy and system integrity.

Overall, AURA serves as a comprehensive and forward-thinking wellness and safety platform that empowers individuals to improve their personal health, respond to emergencies with verifiable integrity, and participate in an inclusive, AI-powered community — all within a single, unified solution.
