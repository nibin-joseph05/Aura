import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../../../core/widgets/navigation/app_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(title: "Privacy Policy"),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.w(6),
                    vertical: responsive.h(2.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        responsive: responsive,
                        title: "Introduction",
                        content:
                            "Aura is committed to protecting your privacy. This Privacy Policy explains "
                            "how we collect, use, and safeguard your information when you use our app.",
                      ),
                      _buildDivider(),
                      _buildSectionWithBullets(
                        responsive: responsive,
                        title: "Information We Collect",
                        items: [
                          "Phone number or email used for authentication",
                          "Basic profile information (name, photo) from Google sign-in",
                          "App usage data to improve app experience",
                          "Crash logs to identify issues and improve performance",
                        ],
                      ),
                      _buildDivider(),
                      _buildSectionWithBullets(
                        responsive: responsive,
                        title: "How We Use Your Data",
                        items: [
                          "Enable authentication and account creation",
                          "Provide app features and personalized experiences",
                          "Improve security and prevent fraudulent activity",
                          "Monitor performance and fix app issues",
                        ],
                      ),
                      _buildDivider(),
                      _buildSection(
                        responsive: responsive,
                        title: "Data Protection",
                        content:
                            "All your data is securely stored using Firebase services. "
                            "We do not sell, trade, or share your personal information with third parties. "
                            "We implement industry-standard security measures to protect against unauthorized access.",
                      ),
                      _buildDivider(),
                      _buildSection(
                        responsive: responsive,
                        title: "Your Control",
                        content:
                            "You can request deletion of your account and associated data by contacting support. "
                            "You may also revoke Google permissions at any time through your Google account settings. "
                            "We respect your right to manage your information.",
                      ),
                      _buildDivider(),
                      _buildSection(
                        responsive: responsive,
                        title: "Third-party Services",
                        content:
                            "Aura uses Firebase Authentication, Firestore, Analytics, and Crashlytics. "
                            "These services follow strict data protection standards, and their use is governed by their "
                            "respective privacy policies.",
                      ),
                      _buildDivider(),
                      _buildSection(
                        responsive: responsive,
                        title: "Changes to Policy",
                        content:
                            "We may update this Privacy Policy to improve clarity or comply with new laws. "
                            "You will be notified of major changes via email or an in-app notification before they take effect. "
                            "Continued use of the app implies acceptance of the updated policy.",
                      ),
                      SizedBox(height: responsive.h(4)),
                      _buildLastUpdated(responsive),
                      SizedBox(height: responsive.h(2)),
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

  Widget _buildSection({
    required Responsive responsive,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(responsive, title),
        _buildSectionText(responsive, content),
      ],
    );
  }

  Widget _buildSectionWithBullets({
    required Responsive responsive,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(responsive, title),
        _buildBulletList(responsive, items),
      ],
    );
  }

  Widget _buildSectionTitle(Responsive responsive, String title) {
    final titleSize = responsive.isLargeTablet
        ? 28.0
        : responsive.isTablet
        ? 25.0
        : 22.0;

    return Padding(
      padding: EdgeInsets.only(
        top: responsive.h(2.2),
        bottom: responsive.h(0.8),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: titleSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSectionText(Responsive responsive, String text) {
    final textSize = responsive.isLargeTablet
        ? 20.0
        : responsive.isTablet
        ? 18.0
        : 16.0;

    return Text(
      text,
      style: TextStyle(
        color: Colors.white70,
        fontSize: textSize,
        height: 1.6,
        wordSpacing: 0.5,
      ),
    );
  }

  Widget _buildBulletList(Responsive responsive, List<String> items) {
    final textSize = responsive.isLargeTablet
        ? 20.0
        : responsive.isTablet
        ? 18.0
        : 16.0;

    final bulletSize = responsive.isLargeTablet
        ? 10.0
        : responsive.isTablet
        ? 9.0
        : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: responsive.h(0.8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: responsive.h(0.6)),
                child: Icon(
                  Icons.fiber_manual_record,
                  color: Colors.lightBlueAccent,
                  size: bulletSize,
                ),
              ),
              SizedBox(width: responsive.w(2)),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: textSize,
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

  Widget _buildDivider() {
    return const Divider(color: Colors.white30, height: 30, thickness: 0.5);
  }

  Widget _buildLastUpdated(Responsive responsive) {
    final textSize = responsive.isLargeTablet
        ? 17.0
        : responsive.isTablet
        ? 15.0
        : 13.0;

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(2.5),
          vertical: responsive.h(0.6),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(
            responsive.radius(AppDimensions.radiusM),
          ),
          border: Border.all(color: Colors.white30),
        ),
        child: Text(
          "Last updated: February 2025",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: textSize,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
