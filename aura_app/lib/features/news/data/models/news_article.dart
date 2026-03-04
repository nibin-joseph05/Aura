class NewsArticle {
  final String? source;
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final String? publishedAt;

  const NewsArticle({
    this.source,
    this.author,
    required this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      source: json['source'] as String?,
      author: json['author'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      url: json['url'] as String?,
      imageUrl: json['imageUrl'] as String?,
      publishedAt: json['publishedAt'] as String?,
    );
  }

  String get timeAgo {
    if (publishedAt == null) return '';
    try {
      final date = DateTime.parse(publishedAt!);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
