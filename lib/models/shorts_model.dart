class ShortVideo {
  final String id;
  final String videoUrl;
  final String publicId;
  final String instructorName;
  final String caption;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final bool isActive;
  final DateTime createdAt;

  ShortVideo({
    required this.id,
    required this.videoUrl,
    required this.publicId,
    required this.instructorName,
    required this.caption,
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
    required this.isActive,
    required this.createdAt,
  });

  factory ShortVideo.fromJson(Map<String, dynamic> json) {
    return ShortVideo(
      id: json['_id'] ?? '',
      videoUrl: json['video']?['url'] ?? '',
      publicId: json['video']?['public_id'] ?? '',
      instructorName: json['instructorName'] ?? 'Unknown',
      caption: json['caption'] ?? '',
      totalLikes: json['totalLikes'] ?? 0,
      totalComments: json['totalComments'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  ShortVideo copyWith({
    String? id,
    String? videoUrl,
    String? publicId,
    String? instructorName,
    String? caption,
    int? totalLikes,
    int? totalComments,
    int? totalShares,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ShortVideo(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      publicId: publicId ?? this.publicId,
      instructorName: instructorName ?? this.instructorName,
      caption: caption ?? this.caption,
      totalLikes: totalLikes ?? this.totalLikes,
      totalComments: totalComments ?? this.totalComments,
      totalShares: totalShares ?? this.totalShares,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ShortComment {
  final String id;
  final String shortId;
  final CommentUser user;
  final String commentText;
  final bool isAdminReply;
  final DateTime createdAt;
  final List<ShortComment> replies;

  ShortComment({
    required this.id,
    required this.shortId,
    required this.user,
    required this.commentText,
    required this.isAdminReply,
    required this.createdAt,
    this.replies = const [],
  });

  factory ShortComment.fromJson(Map<String, dynamic> json) {
    var repliesList = json['replies'] as List? ?? [];
    return ShortComment(
      id: json['_id'] ?? '',
      shortId: json['shortId'] ?? '',
      user: CommentUser.fromJson(json['userId'] ?? {}),
      commentText: json['commentText'] ?? '',
      isAdminReply: json['isAdminReply'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      replies: repliesList.map((i) => ShortComment.fromJson(i)).toList(),
    );
  }
}

class CommentUser {
  final String id;
  final String name;
  final String email;
  final String profilePicture;

  CommentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    String pfp = '';
    // Handle user profile picture structure
    if (json['profilePicture'] is Map) {
      pfp = json['profilePicture']['url'] ?? '';
    } 
    // Handle admin profile photo string
    else if (json['profilePhoto'] is String) {
      pfp = json['profilePhoto'] ?? '';
    }
    // Fallback or generic profilePicture field
    else if (json['profilePicture'] is String) {
      pfp = json['profilePicture'] ?? '';
    }

    return CommentUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      profilePicture: pfp,
    );
  }
}