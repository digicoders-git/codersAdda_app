import 'package:coders_adda_app/models/shorts_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class ShortsService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ShortVideo>> getActiveShorts() async {
    try {
      final response = await _apiClient.get(ApiUrls.getActiveShorts);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => ShortVideo.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching active shorts: $e');
      return [];
    }
  }

  Future<bool> checkIsLiked(String shortId) async {
    try {
      final response = await _apiClient.get('${ApiUrls.checkShortLike}/$shortId');
      return response['liked'] ?? false;
    } catch (e) {
      print('Error checking short like: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> toggleLike(String shortId) async {
    try {
      final response = await _apiClient.post('${ApiUrls.toggleShortLike}/$shortId', {});
      return response;
    } catch (e) {
      print('Error toggling short like: $e');
      rethrow;
    }
  }

  Future<List<ShortComment>> getShortComments(String shortId) async {
    try {
      final response = await _apiClient.get('${ApiUrls.getShortComments}/$shortId');
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => ShortComment.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching short comments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addComment(String shortId, String commentText) async {
    try {
      final body = {'commentText': commentText};
      final response = await _apiClient.post('${ApiUrls.addShortComment}/$shortId', body);
      return response;
    } catch (e) {
      print('Error adding short comment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      final response = await _apiClient.delete('${ApiUrls.deleteShortComment}/$commentId');
      return response;
    } catch (e) {
      print('Error deleting short comment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> replyToComment(String commentId, String commentText) async {
    try {
      final body = {'commentText': commentText};
      final response = await _apiClient.post('${ApiUrls.replyShortComment}/$commentId', body);
      return response;
    } catch (e) {
      print('Error replying to short comment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> editComment(String commentId, String commentText) async {
    try {
      final body = {'commentText': commentText};
      final response = await _apiClient.put('${ApiUrls.editShortComment}/$commentId', body);
      return response;
    } catch (e) {
      print('Error editing short comment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addShare(String shortId) async {
    try {
      final response = await _apiClient.post('${ApiUrls.addShortShare}/$shortId', {});
      return response;
    } catch (e) {
      print('Error adding short share: $e');
      rethrow;
    }
  }
}