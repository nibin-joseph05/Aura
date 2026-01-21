import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

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
              const AppHeader(title: 'Help & FAQ', showBack: true),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: responsive.horizontal(5),
                  child: Column(
                    children: [
                      SizedBox(height: responsive.h(2)),
                      _buildFaqItem(
                        responsive,
                        question: 'How do I trigger an SOS alert?',
                        answer:
                            'From the home screen, tap the SOS button in the center of the navigation bar. Long-press to start the 5-second countdown. Your location will be sent to all trusted contacts.',
                      ),
                      _buildFaqItem(
                        responsive,
                        question: 'How do I add trusted contacts?',
                        answer:
                            'Go to My Account → Emergency Contacts → tap the + icon to add a new contact. You can also import contacts from your phone.',
                      ),
                      _buildFaqItem(
                        responsive,
                        question: 'Does the app work offline?',
                        answer:
                            'Yes! Aura uses offline-first architecture. Your data is stored locally and synced when you\'re back online. Pending actions are queued automatically.',
                      ),
                      _buildFaqItem(
                        responsive,
                        question: 'How do I create a wellness post?',
                        answer:
                            'Tap the "Post" button on home or go to Feed → tap the + icon. Select a category, write your content, and submit. Posts are reviewed before appearing publicly.',
                      ),
                      _buildFaqItem(
                        responsive,
                        question: 'Can I change the app theme?',
                        answer:
                            'Yes! Go to My Account → Appearance and choose between Light, Dark, or System (follows your device settings).',
                      ),
                      _buildFaqItem(
                        responsive,
                        question: 'How is my data protected?',
                        answer:
                            'We use industry-standard encryption and secure authentication through Firebase. Your location data is only shared during SOS events with contacts you choose.',
                      ),
                      SizedBox(height: responsive.h(3)),
                      _buildContactSupport(responsive, context),
                      SizedBox(height: responsive.h(3)),
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

  Widget _buildFaqItem(
    Responsive responsive, {
    required String question,
    required String answer,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.h(1.5)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: responsive.w(4)),
        childrenPadding: EdgeInsets.fromLTRB(
          responsive.w(4),
          0,
          responsive.w(4),
          responsive.h(2),
        ),
        iconColor: Colors.white54,
        collapsedIconColor: Colors.white38,
        title: Text(
          question,
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.isTablet ? 15 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: Colors.white70,
              fontSize: responsive.isTablet ? 14 : 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupport(Responsive responsive, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.w(5)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.support_agent,
            color: AppColors.accent,
            size: responsive.isTablet ? 48 : 40,
          ),
          SizedBox(height: responsive.h(1.5)),
          Text(
            'Need more help?',
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.h(0.5)),
          Text(
            'Our support team is here for you',
            style: TextStyle(
              color: Colors.white54,
              fontSize: responsive.isTablet ? 14 : 12,
            ),
          ),
          SizedBox(height: responsive.h(2)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support email: support@auraapp.com'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.email_outlined),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: responsive.h(1.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
