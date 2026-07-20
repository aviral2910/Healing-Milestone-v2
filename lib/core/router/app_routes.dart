class AppRoutes {
  static const String home = '/';
  static const String phoneAuth = '/phone-auth';
  static const String verifyOtp = '/verify-otp';
  static const String create = '/create';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String professionalOnboarding = '/professional-onboarding';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String userList = '/user-list';
  static const String settings = '/settings';
  static const String themeSelection = '/theme-selection';
  static const uat = '/uat';

  // Dynamic routes
  static const String publicProfilePath = '/user/:id';
  static String publicProfile(String id) => '/user/$id';

  static const String storyDetailPath = '/story/:id';
  static String storyDetail(String id) => '/story/$id';
}
