import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/news_article.dart';
import '../../data/service/news_api_service.dart';

final newsApiServiceProvider = Provider<NewsApiService>(
  (ref) => NewsApiService(),
);

final wellnessNewsProvider = FutureProvider.autoDispose<List<NewsArticle>>(
  (ref) => ref.read(newsApiServiceProvider).getWellnessNews(pageSize: 12),
);

final healthHeadlinesProvider = FutureProvider.autoDispose<List<NewsArticle>>(
  (ref) => ref.read(newsApiServiceProvider).getHealthHeadlines(pageSize: 12),
);
