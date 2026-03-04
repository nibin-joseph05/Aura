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
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Daily Wellness News',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient(brightness),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: responsive.horizontal(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: responsive.h(2)),
                  if (article.imageUrl != null) _buildHeroImage(responsive),
                  SizedBox(height: responsive.h(3)),
                  _buildMeta(responsive),
                  SizedBox(height: responsive.h(2)),
                  _buildTitle(responsive),
                  SizedBox(height: responsive.h(2.5)),
                  if (article.description != null &&
                      article.description!.isNotEmpty)
                    _buildBody(responsive),
                  SizedBox(height: responsive.h(4)),
                  if (article.url != null)
                    _buildReadMoreButton(context, responsive, isDark),
                  SizedBox(height: responsive.h(6)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(Responsive responsive) {
    return Hero(
      tag: 'news_image_${article.imageUrl}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: responsive.isTablet ? 300 : 240,
          width: double.infinity,
          child: Image.network(
            article.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: responsive.isTablet ? 300 : 240,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(
                  Icons.newspaper_rounded,
                  color: Colors.white24,
                  size: 56,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeta(Responsive responsive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (article.source != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              article.source!,
              style: TextStyle(
                color: const Color(0xFF60A5FA),
                fontSize: responsive.isTablet ? 12 : 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        if (article.source != null) const SizedBox(width: 12),
        const Icon(Icons.access_time_rounded, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Text(
          article.timeAgo.isNotEmpty ? article.timeAgo : 'Recently',
          style: TextStyle(
            color: Colors.white38,
            fontSize: responsive.isTablet ? 13 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: article.url ?? ''));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.link_rounded,
              color: Colors.white70,
              size: 18,
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
        fontSize: responsive.isTablet ? 26 : 22,
        fontWeight: FontWeight.w800,
        height: 1.3,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildBody(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.w(5)),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Text(
        '${article.description}\n\n...',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.88),
          fontSize: responsive.isTablet ? 16 : 15,
          height: 1.75,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildReadMoreButton(
    BuildContext context,
    Responsive responsive,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(article.url ?? '');
        if (uri != null) {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            debugPrint('Could not launch news URL: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open the article link.'),
                ),
              );
            }
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: responsive.h(2.2)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Read Full Coverage',
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.isTablet ? 16 : 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
