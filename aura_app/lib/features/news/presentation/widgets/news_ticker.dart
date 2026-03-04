import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/responsive/responsive.dart';
import '../../data/models/news_article.dart';
import '../providers/news_provider.dart';

class NewsTicker extends ConsumerStatefulWidget {
  const NewsTicker({super.key});

  @override
  ConsumerState<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends ConsumerState<NewsTicker> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final newsAsync = ref.read(wellnessNewsProvider);
      final count = newsAsync.valueOrNull?.length ?? 0;
      if (count > 0 && _pageController.hasClients) {
        final next = (_currentPage + 1) % count;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() => _currentPage = next);
      }
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final newsAsync = ref.watch(wellnessNewsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: responsive.isTablet ? 34 : 28,
              height: responsive.isTablet ? 34 : 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.newspaper_rounded,
                color: Colors.white,
                size: responsive.isTablet ? 18 : 15,
              ),
            ),
            SizedBox(width: responsive.w(2.5)),
            Text(
              'Health & Wellness News',
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: responsive.w(1)),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontSize: responsive.isTablet ? 10 : 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.h(1.5)),
        newsAsync.when(
          data: (articles) {
            if (articles.isEmpty) return _buildEmptyState(responsive);
            return Column(
              children: [
                SizedBox(
                  height: responsive.isTablet ? 160 : 140,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: articles.length,
                    itemBuilder: (context, index) => _NewsCard(
                      article: articles[index],
                      responsive: responsive,
                    ),
                  ),
                ),
                SizedBox(height: responsive.h(1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    articles.length.clamp(0, 8),
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: i == _currentPage ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? const Color(0xFFEF4444)
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => _buildShimmer(responsive),
          error: (_, __) => _buildEmptyState(responsive),
        ),
      ],
    );
  }

  Widget _buildShimmer(Responsive responsive) {
    return Container(
      height: responsive.isTablet ? 160 : 140,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 2),
      ),
    );
  }

  Widget _buildEmptyState(Responsive responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: responsive.h(2.5),
        horizontal: responsive.w(4),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              color: Color(0xFFEF4444),
              size: 22,
            ),
          ),
          SizedBox(width: responsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No news available right now',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: responsive.isTablet ? 14 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.h(0.3)),
                Text(
                  'Health & wellness stories will appear here',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: responsive.isTablet ? 12 : 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  final Responsive responsive;

  const _NewsCard({required this.article, required this.responsive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/news-detail',
        arguments: article,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            if (article.imageUrl != null)
              Container(
                width: responsive.isTablet ? 130 : 110,
                color: Colors.white.withValues(alpha: 0.05),
                child: Image.network(
                  article.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withValues(alpha: 0.05),
                    child: const Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(responsive.w(3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (article.source != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              article.source!,
                              style: TextStyle(
                                color: const Color(0xFFEF4444),
                                fontSize: responsive.isTablet ? 10 : 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            article.timeAgo,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: responsive.isTablet ? 10 : 9,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: responsive.h(0.6)),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    if (article.description != null) ...[
                      SizedBox(height: responsive.h(0.5)),
                      Text(
                        article.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: responsive.isTablet ? 11 : 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
}
