class ApiEndpoints {
  static const me = "/api/auth/me";
  static const login = "/api/auth/login";
  static const userProfile = "/api/user";
  static const usernameAvailable = "/api/user/username-available";
  static const updateProfile = "/api/user/profile";
  static const uploadProfileImage = "/api/upload/profile-image";

  static const dailyActivities = "/api/daily-activities";
  static const syncDailyActivities = "/api/daily-activities/sync";

  static const activityCategories = "/api/admin/activity-categories";
  static const activityCategoriesActive =
      "/api/admin/activity-categories/active";

  static const activityTypes = "/api/admin/activity-types";
  static const activityTypesActive = "/api/admin/activity-types/active";
  static String activityTypesByCategory(String categoryId) =>
      "/api/admin/activity-types/category/$categoryId";

  static const userActivities = "/api/user/activities";
  static String userActivitiesForUser(String userId) =>
      "/api/user/activities/$userId";
  static String userActivitiesForDate(String userId, String date) =>
      "/api/user/activities/$userId/date/$date";

  static const activityLogs = "/api/user/activity-logs";
  static String activityLogsForDate(String userId, String date) =>
      "/api/user/activity-logs/$userId/date/$date";

  static const reminders = "/api/user/reminders";
  static String remindersForUser(String userId) =>
      "/api/user/reminders/$userId";
}
