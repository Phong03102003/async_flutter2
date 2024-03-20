class Article {
  final String? source;
  final String? author;
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? content;
  final String category;

  Article(this.source, this.author, this.title, this.description, this.url,
      this.urlToImage, this.publishedAt, this.content, this.category);

  factory Article.fromJson(Map<String, dynamic> json) {
    final keywords = {
      'Politics': [
        'politics',
        'election',
        'government',
        'party',
        'congress',
        'president',
        'parliament',
        'democracy'
      ],
      'Sports': [
        'sports',
        'football',
        'basketball',
        'tennis',
        'racing',
        'olympics'
      ],
      'Health': [
        'health',
        'medical',
        'disease',
        'virus',
        'healthcare',
        'hospital'
      ],
      'Music': [
        'music',
        'song',
        'band',
        'singer',
        'musician',
        'album',
        'concert',
        'artist',
        'pop',
        'rock'
      ],
      'Tech': [
        'technology',
        'industry',
        'innovation',
        'device',
        'app',
        'internet',
        'software',
        'hardware',
        'startup',
        'coding'
      ]
    };

    final title = json['title']?.toString().toLowerCase() ?? '';
    final description = json['description']?.toString().toLowerCase() ?? '';

    String category = 'General'; // Default to General

    keywords.forEach((key, value) {
      if (value.any((keyword) => title.contains(keyword)) ||
          value.any((keyword) => description.contains(keyword))) {
        category = key;
      }
    });

    return Article(
        json['source'] != null ? json['source']['name'] : null,
        json['author'],
        json['title'] ?? '',
        json['description'] ?? '',
        json['url'] ?? '',
        json['urlToImage'],
        json['publishedAt'] ?? '',
        json['content'],
        category);
  }
}
