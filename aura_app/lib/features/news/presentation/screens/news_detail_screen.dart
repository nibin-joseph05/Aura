import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../data/models/news_article.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient(brightness),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, responsive),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: responsive.horizontal(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: responsive.h(2)),
                        if (article.imageUrl != null)
                          _buildHeroImage(responsive),
                        SizedBox(height: responsive.h(2.5)),
                        _buildMeta(responsive),
                        SizedBox(height: responsive.h(1.5)),
                        _buildTitle(responsive),
                        SizedBox(height: responsive.h(2)),
                        if (article.description != null &&
                            article.description!.isNotEmpty)
                          _buildBody(responsive),
                        SizedBox(height: responsive.h(3)),
                        if (article.url != null)
                          _buildReadMoreButton(context, responsive),
                        SizedBox(height: responsive.h(4)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Responsive responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(4),
        vertical: responsive.h(1.5),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          if (article.source != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                article.source!,
                style: TextStyle(
                  color: const Color(0xFFEF4444),
                  fontSize: responsive.isTablet ? 12 : 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(Responsive responsive) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: responsive.isTablet ? 260 : 210,
        width: double.infinity,
        child: Image.network(
          article.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: responsive.isTablet ? 260 : 210,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.newspaper_rounded,
                color: Colors.white24,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeta(Responsive responsive) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded, color: Colors.white38, size: 14),
        const SizedBox(width: 5),
        Text(
          article.timeAgo.isNotEmpty ? article.timeAgo : 'Recently published',
          style: TextStyle(
            color: Colors.white38,
            fontSize: responsive.isTablet ? 13 : 12,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: article.url ?? ''));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.copy_rounded, color: Colors.white54, size: 14),
                const SizedBox(width: 5),
                Text(
                  'Copy link',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: responsive.isTablet ? 12 : 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(Responsive responsive) {
    return Text(
      article.title,
      style: TextStyle(
        color: Colors.white,
        fontSize: responsive.isTablet ? 24 : 20,
        fontWeight: FontWeight.bold,
        height: 1.35,
      ),
    );
  }

  Widget _buildBody(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        article.description!,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.82),
          fontSize: responsive.isTablet ? 15 : 14,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildReadMoreButton(BuildContext context, Responsive responsive) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(article.url ?? '');
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: responsive.h(2)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFF97316)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.open_in_new_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Read Full Article',
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.isTablet ? 16 : 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
