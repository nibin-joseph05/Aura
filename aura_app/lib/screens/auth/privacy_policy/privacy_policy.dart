import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A1A2F),
              Color(0xFF134B73),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Privacy Policy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black38,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Introduction"),
                      _sectionText(
                        "Aura is committed to protecting your privacy. This Privacy Policy explains "
                            "how we collect, use, and safeguard your information when you use our app.",
                      ),
                      const Divider(color: Colors.white30, height: 30, thickness: 0.5),

                      _sectionTitle("Information We Collect"),
                      _bulletList(
                        [
                          "Phone number or email used for authentication",
                          "Basic profile information (name, photo) from Google sign-in",
                          "App usage data to improve app experience",
                          "Crash logs to identify issues and improve performance",
                        ],
                      ),
                      const Divider(color: Colors.white30, height: 30, thickness: 0.5),

                      _sectionTitle("How We Use Your Data"),
                      _bulletList(
                        [
                          "Enable authentication and account creation",
                          "Provide app features and personalized experiences",
                          "Improve security and prevent fraudulent activity",
                          "Monitor performance and fix app issues",
                        ],
                      ),
                      const Divider(color: Colors.white30, height: 30, thickness: 0.5),

                      _sectionTitle("Data Protection"),
                      _sectionText(
                        "All your data is securely stored using Firebase services. "
                            "We do not sell, trade, or share your personal information with third parties. "
                            "We implement industry-standard security measures to protect against unauthorized access.",
                      ),
                      const Divider(color: Colors.white30, height: 30, thickness: 0.5),

                      _sectionTitle("Your Control"),
                      _sectionText(
                        "You can request deletion of your account and associated data by contacting support. "
                            "You may also revoke Google permissions at any time through your Google account settings. "
                            "We respect your right to manage your information.",
                      ),
                      const Divider(color: Colors.white30, height: 30, thickness: 0.5),

                      _sectionTitle("Third-party Services"),
                      _sectionText(
                        "Aura uses Firebase Authentication, Firestore, Analytics, and Crashlytics. "
                            "These services follow strict data protection standards, and their use is governed by their "
                            "respective privacy policies.",
                      ),
                      const Divider(color: Colors.white30, height: 30, thickness: 0.5),

                      _sectionTitle("Changes to Policy"),
                      _sectionText(
                        "We may update this Privacy Policy to improve clarity or comply with new laws. "
                            "You will be notified of major changes via email or an in-app notification before they take effect. "
                            "Continued use of the app implies acceptance of the updated policy.",
                      ),

                      const SizedBox(height: 40),

                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white30)
                          ),
                          child: Text(
                            "Last updated: February 2025",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        height: 1.6,
        wordSpacing: 0.5,
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Icon(
                  Icons.fiber_manual_record,
                  color: Colors.lightBlueAccent,
                  size: 8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                    wordSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}