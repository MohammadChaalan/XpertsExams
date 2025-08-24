class Video {
  final int id;
  final String title;
  final String duration;
  final String? url;

  Video({
    required this.id,
    required this.title,
    required this.duration,
    this.url,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'url': url,
      };
}
