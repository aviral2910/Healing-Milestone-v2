class AppRoutes {
  static const String splash = '/splash';
  static const String ascensionTransition = '/ascension-transition';
  static const String suspended = '/suspended';
  static const String home = '/';
  static const String search = '/search';
  static const String phoneAuth = '/phone-auth';
  static const String verifyOtp = '/verify-otp';
  static const String timeCapsulesVault = '/time-capsules-vault';


  static const String create = '/create';
  static const String createPostGuided = '/create/guided';
  static const String createPostManual = '/create/manual';
  static const String createPostSettings = '/create/settings';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String professionalOnboarding = '/professional-onboarding';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String userList = '/user-list';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String themeSelection = '/theme-selection';
  static const String accessibilitySettings = '/accessibility-settings';
  static const String drafts = '/drafts';
  static const String adminSubmissions = '/admin-submissions';
  static const String supportChat = '/support-chat';
  static const uat = '/uat';

  // Dynamic routes
  static const String publicProfilePath = '/user/:id';
  static String publicProfile(String id) => '/user/$id';

  static const String storyDetailPath = '/story/:id';
  static String storyDetail(String id) => '/story/$id';

  static const String reportStoryPath = '/report/:id';
  static String reportStory(String id) => '/report/$id';
}
