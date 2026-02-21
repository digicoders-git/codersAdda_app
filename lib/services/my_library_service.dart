import 'package:coders_adda_app/models/my_learning_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class MyLibraryService {
  final ApiClient _apiClient = ApiClient();

  Future<MyLibraryResponse> getMyLibrary() async {
    try {
      final response = await _apiClient.get(ApiUrls.getMyLibrary);
      if (response['success'] == true) {
        return MyLibraryResponse.fromJson(response['data']);
      }
      return MyLibraryResponse.empty();
    } catch (e) {
      print('Error fetching my library: $e');
      rethrow;
    }
  }
}
