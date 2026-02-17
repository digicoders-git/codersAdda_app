import 'package:coders_adda_app/models/shorts_model.dart';


abstract class ShortsService {
  Future<List<ShortVideo>> getShorts();
  Future<void> likeShort(String shortId);
  Future<void> commentOnShort(String shortId, String comment);
  Future<void> shareShort(String shortId);
}

class MockShortsService implements ShortsService {
  @override
  Future<List<ShortVideo>> getShorts() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      ShortVideo(
        id: '1',
        title: 'Flutter Animation Tips',
        creator: '@fluttermaster',
        thumbnail: 'https://picsum.photos/400/800?random=1',
        likes: 2500,
        comments: 356,
        description: 'Learn how to create smooth animations in Flutter with these pro tips! 🎬',
      ),
      // Add more shorts...
    ];
  }

  @override
  Future<void> likeShort(String shortId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> commentOnShort(String shortId, String comment) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> shareShort(String shortId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}