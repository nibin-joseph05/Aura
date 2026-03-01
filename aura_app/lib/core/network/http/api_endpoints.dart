class ApiEndpoints {
  static const me = "/api/auth/me";
  static const login = "/api/auth/login";
  static const register = "/api/auth/register";
  static const userProfile = "/api/user";
  static const usernameAvailable = "/api/user/username-available";
  static const updateProfile = "/api/user/profile";
  static const uploadProfileImage = "/api/upload/profile-image";
  static const verifyEmailSend = "/api/user/verify-email/send";
  static const verifyEmailConfirm = "/api/user/verify-email/confirm";

  static const changePassword = "/api/user/password/change";
  static const forgotPassword = "/api/auth/password/forgot";
  static const resetPassword = "/api/auth/password/reset";

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

  static const sosSettings = "/api/user/sos";
  static const sosMessage = "/api/user/sos/message";
  static const sosContacts = "/api/user/sos/contacts";
  static String sosContactById(String contactId) =>
      "/api/user/sos/contacts/$contactId";
  static const sosTrigger = "/api/user/sos/trigger";
  static const sosEvents = "/api/user/sos/events";

  static const wellnessFeed = "/api/user/wellness/feed";
  static const wellnessMyUpdates = "/api/user/wellness/my-updates";
  static const wellnessTrending = "/api/user/wellness/trending";
  static const wellnessUpdates = "/api/user/wellness/updates";
}
