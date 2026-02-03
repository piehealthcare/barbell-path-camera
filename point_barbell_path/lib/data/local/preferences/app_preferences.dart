import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class AppPreferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isOnboardingComplete =>
      _prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;

  static Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(AppConstants.keyOnboardingComplete, value);

  static bool get isDarkMode =>
      _prefs.getBool(AppConstants.keyDarkMode) ?? false;

  static Future<void> setDarkMode(bool value) =>
      _prefs.setBool(AppConstants.keyDarkMode, value);

  static String get language =>
      _prefs.getString(AppConstants.keyLanguage) ?? 'ko';

  static Future<void> setLanguage(String value) =>
      _prefs.setString(AppConstants.keyLanguage, value);

  static String get lastExercise =>
      _prefs.getString(AppConstants.keyLastExercise) ?? 'squat';

  static Future<void> setLastExercise(String value) =>
      _prefs.setString(AppConstants.keyLastExercise, value);

  static double get cameraDistance =>
      _prefs.getDouble(AppConstants.keyCameraDistance) ?? 2.5;

  static Future<void> setCameraDistance(double value) =>
      _prefs.setDouble(AppConstants.keyCameraDistance, value);
}
