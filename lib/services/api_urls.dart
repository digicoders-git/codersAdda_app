class ApiUrls {
  static const String baseUrl = 'https://coders-adda-backend.onrender.com';

  // Auth Endpoints
  static const String requestOtp = '$baseUrl/users/request-otp';
  static const String verifyOtp = '$baseUrl/users/verify-otp';

  // Profile Endpoints
  static const String getProfile = '$baseUrl/users/profile';
  static const String updateProfile = '$baseUrl/users/update-profile';

  // Courses Endpoints
  static const String getAllCourses = '$baseUrl/courses';
  static const String getCourseDetails = '$baseUrl/course/get'; // We'll append /id manually
  static const String getCourseCategories = '$baseUrl/CourseCategory/get';
  static const String getCoursesByFilter = '$baseUrl/course/get'; 

  // Sliders Endpoints
  static const String getSliders = '$baseUrl/sliders/get';

  // Payment / Enrollment Endpoints
  static const String enrollFreeItem = '$baseUrl/payment/free';
  static const String createOrder = '$baseUrl/payment/create-order';
  static const String verifyPayment = '$baseUrl/payment/verify';

  // E-books Endpoints
  static const String getEbookCategories = '$baseUrl/ebooks-category/get-with-count';
  static const String getEbooks = '$baseUrl/ebook/get';
  static const String getEbookDetails = '$baseUrl/ebook/get'; // We'll append /id manually

  // Shorts Endpoints
  static const String getActiveShorts = '$baseUrl/shorts/get-active';
  static const String toggleShortLike = '$baseUrl/short-likes/toggle'; // We'll append /id
  static const String checkShortLike = '$baseUrl/short-likes/check'; // We'll append /id
  static const String getShortComments = '$baseUrl/short-comments/get'; // We'll append /id
  static const String addShortComment = '$baseUrl/short-comments/add'; // We'll append /id
  static const String deleteShortComment = '$baseUrl/short-comments/delete'; // We'll append /id

  // Add more endpoints as per your backend structure here
}
