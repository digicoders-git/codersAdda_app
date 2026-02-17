class ShortVideo {
  final String id;
  final String title;
  final String creator;
  final String thumbnail;
  final int likes;
  final int comments;
  final String description;

  ShortVideo({
    required this.id,
    required this.title,
    required this.creator,
    required this.thumbnail,
    required this.likes,
    required this.comments,
    required this.description,
  });

  ShortVideo copyWith({
    String? id,
    String? title,
    String? creator,
    String? thumbnail,
    int? likes,
    int? comments,
    String? description,
  }) {
    return ShortVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      creator: creator ?? this.creator,
      thumbnail: thumbnail ?? this.thumbnail,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      description: description ?? this.description,
    );
  }
}