/// App metadata kept in sync with [pubspec.yaml] version.
class AppInfo {
  AppInfo._();

  static const version = '1.0.0';
  static const buildNumber = '1';

  static String get versionLabel => version;
}
