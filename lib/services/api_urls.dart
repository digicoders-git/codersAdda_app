class ApiUrls {
  // Use http://10.0.2.2:3900 for Android Emulator to connect to localhost
  // Use http://localhost:3900 for Web/Windows testing
  static const String baseUrl = 'https://coders-adda-backend.onrender.com';
  // static const String baseUrl = 'http://192.168.29.234:3900';
  // static const String baseUrl = 'http://10.0.2.2:3900';

  // Auth Endpoints
  static const String requestOtp = '$baseUrl/users/request-otp';
  static const String verifyOtp = '$baseUrl/users/verify-otp';
  static const String googleLogin = '$baseUrl/users/google-login';

  static String resolveMediaUrl(dynamic mediaJson) {
    if (mediaJson == null) return '';
    String localUrl = mediaJson['localUrl'] ?? '';
    String cloudUrl = mediaJson['url'] ?? '';

    if (localUrl.isNotEmpty) {
      if (localUrl.contains('localhost')) {
        try {
          final uri = Uri.parse(localUrl);
          final baseUri = Uri.parse(baseUrl);
          localUrl = localUrl.replaceFirst('${uri.scheme}://${uri.host}:${uri.port}', '${baseUri.scheme}://${baseUri.host}:${baseUri.port}');
        } catch (e) {
          // Ignore parsing errors
        }
      }
      return localUrl;
    }
    return cloudUrl;
  }

  // Progress
  static const String updateProgress = "$baseUrl/progress/update";

  // Profile Endpoints
  static const String getProfile = '$baseUrl/users/profile';
  static const String updateProfile = '$baseUrl/users/update-profile';

  // Job Application Endpoints
  static const String applyJobUrl = "$baseUrl/job-applications/apply";
  static const String myJobApplicationsUrl = "$baseUrl/job-applications/my-applications";
  static const String withdrawJobApplicationUrl = "$baseUrl/job-applications/withdraw";
  static const String updateFcmToken = '$baseUrl/users/update-fcm-token';
  static const String getWallet = '$baseUrl/users/my-wallet';

  // Courses Endpoints
  static const String getAllCourses = '$baseUrl/courses';
  static const String getCourseDetails = '$baseUrl/course/get'; // We'll append /id manually
  static const String getCourseCategories = '$baseUrl/CourseCategory/course-count';
  static const String getCoursesByCategoryName = '$baseUrl/CourseCategory/get-by-name';
  static const String getCoursesByFilter = '$baseUrl/course/get'; 
  static const String getCurriculumByCourse = '$baseUrl/curriculum/get/by-course';
  static const String getLectureByTopic = '$baseUrl/lecture/get/by-topic'; 
  static const String addCourseReview = '$baseUrl/course/add-review'; // We'll append /id manually

  // Sliders Endpoints
  static const String getSliders = '$baseUrl/sliders/get';

  // Payment / Enrollment Endpoints
  static const String enrollFreeItem = '$baseUrl/payment/free';
  static const String createOrder = '$baseUrl/payment/create-order';
  static const String verifyPayment = '$baseUrl/payment/verify';

  // E-books Endpoints
  static const String getEbookCategories = '$baseUrl/ebooks-category/get-with-count';
  static const String getEbooksByCategoryName = '$baseUrl/ebooks-category/get-by-name';
  static const String getEbooks = '$baseUrl/ebook/get';
  static const String getEbookDetails = '$baseUrl/ebook/get'; // We'll append /id manually

  // Shorts Endpoints
  static const String getActiveShorts = '$baseUrl/shorts/get-active';
  static const String toggleShortLike = '$baseUrl/short-likes/toggle'; // We'll append /id
  static const String checkShortLike = '$baseUrl/short-likes/check'; // We'll append /id
  static const String getShortComments = '$baseUrl/short-comments/get'; // We'll append /id
  static const String addShortComment = '$baseUrl/short-comments/add'; // We'll append /id
  static const String deleteShortComment = '$baseUrl/short-comments/delete'; // We'll append /id

  // My Library Endpoints
  static const String getMyLibrary = '$baseUrl/users/my-library';

  // Subscription Endpoints
  static const String getSubscriptions = '$baseUrl/subscriptions/get';
  static const String getSubscriptionDetails = '$baseUrl/subscriptions/get'; // append /id

  // Jobs V3 Endpoints
  static const String getJobsV3 = '$baseUrl/job-v3/get';

  // Coupon Endpoints
  static const String validateCoupon = '$baseUrl/coupon/validate';

  // Ambassador Endpoints
  static const String applyAmbassador = '$baseUrl/ambassador/apply';
  static const String getAmbassadorStatus = '$baseUrl/ambassador/status';

  // Quiz Endpoints
  static const String getQuizzes = '$baseUrl/quiz/get';
  static const String submitQuizAttempt = '$baseUrl/quiz/attempt/submit';
  static const String getMyQuizAttempts = '$baseUrl/quiz/my-quiz';
  static const String issueQuizCertificate = '$baseUrl/quiz/certificate/issue';
  static const String getMyQuizCertificates = '$baseUrl/quiz/certificate/my-certificates';

  // FAQs Endpoints
  static const String getFaqs = '$baseUrl/faq';

  // Wallet & Payment Endpoints
  static const String walletTopup = '$baseUrl/payment/topup';
  static const String walletWithdraw = '$baseUrl/payment/withdraw';
  static const String paymentHistory = '$baseUrl/payment/history';
  static const String paymentSlipPrefix = '$baseUrl/payment/slip';

  // Support Ticket Endpoint
  static const String createSupportTicket = '$baseUrl/support-ticket/create';
  static const String getMySupportTickets = '$baseUrl/support-ticket/my-tickets';

  // Certificates API
  static String myCertificates = "$baseUrl/certificate/my-certificates";

  // Notifications
  static const String getMyNotifications = '$baseUrl/notifications/my-notifications';
  static const String getUnreadCount = '$baseUrl/notifications/unread-count';
  static const String markNotificationAsRead = '$baseUrl/notifications/mark-read'; // append /id
  static const String markAllAsRead = '$baseUrl/notifications/mark-all-read';
  static const String getNotificationSettings = '$baseUrl/notifications/settings';
  static const String updateNotificationSettings = '$baseUrl/notifications/settings';
}
