import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppUpdateType { none, soft, hard }

class AppUpdateInfo {
  final AppUpdateType type;
  final String currentVersion;
  final String targetVersion;
  final String title;
  final String message;
  final String storeUrl;

  const AppUpdateInfo({
    required this.type,
    required this.currentVersion,
    required this.targetVersion,
    required this.title,
    required this.message,
    required this.storeUrl,
  });

  static const AppUpdateInfo none = AppUpdateInfo(
    type: AppUpdateType.none,
    currentVersion: '',
    targetVersion: '',
    title: '',
    message: '',
    storeUrl: '',
  );
}

class AppUpdateService {
  static const String keyMinRequiredVersion = 'min_required_version';
  static const String keyLatestVersion = 'latest_version';
  static const String keyUpdateTitle = 'update_title';
  static const String keyUpdateMessage = 'update_message';
  static const String keyForceUpdateTitle = 'force_update_title';
  static const String keyForceUpdateMessage = 'force_update_message';
  static const String keyAndroidStoreUrl = 'android_store_url';
  static const String keyIosStoreUrl = 'ios_store_url';

  static const String _dismissedVersionPrefKey =
      'dismissed_soft_update_version';

  static const Map<String, dynamic> defaultRemoteConfigValues = {
    keyMinRequiredVersion: '1.0.0',
    keyLatestVersion: '1.0.0',
    keyUpdateTitle: 'Update Available',
    keyUpdateMessage:
        'A new version of Healing Milestones is available with improvements and bug fixes.',
    keyForceUpdateTitle: 'Update Required',
    keyForceUpdateMessage:
        'This version of Healing Milestones is no longer supported. Please update to continue safely.',
    keyAndroidStoreUrl:
        'https://play.google.com/store/apps/details?id=com.genesisapps.healingmilestones',
    keyIosStoreUrl: 'https://apps.apple.com/app/healing-milestones',
  };

  static Future<void> setDefaults() async {
    try {
      await FirebaseRemoteConfig.instance.setDefaults(
        defaultRemoteConfigValues,
      );
    } catch (e) {
      debugPrint('Failed to set Remote Config update defaults: $e');
    }
  }

  static Future<AppUpdateInfo> checkForUpdate(SharedPreferences prefs) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final rc = FirebaseRemoteConfig.instance;

      final minRequired = rc.getString(keyMinRequiredVersion).trim();
      final latest = rc.getString(keyLatestVersion).trim();

      final storeUrl = !kIsWeb && Platform.isIOS
          ? rc.getString(keyIosStoreUrl).trim()
          : rc.getString(keyAndroidStoreUrl).trim();

      if (minRequired.isNotEmpty &&
          _compareVersions(currentVersion, minRequired) < 0) {
        return AppUpdateInfo(
          type: AppUpdateType.hard,
          currentVersion: currentVersion,
          targetVersion: minRequired,
          title: rc.getString(keyForceUpdateTitle).trim().isNotEmpty
              ? rc.getString(keyForceUpdateTitle).trim()
              : defaultRemoteConfigValues[keyForceUpdateTitle] as String,
          message: rc.getString(keyForceUpdateMessage).trim().isNotEmpty
              ? rc.getString(keyForceUpdateMessage).trim()
              : defaultRemoteConfigValues[keyForceUpdateMessage] as String,
          storeUrl: storeUrl,
        );
      }

      if (latest.isNotEmpty && _compareVersions(currentVersion, latest) < 0) {
        final dismissedVersion = prefs.getString(_dismissedVersionPrefKey);
        if (dismissedVersion == latest) {
          return AppUpdateInfo.none;
        }
        return AppUpdateInfo(
          type: AppUpdateType.soft,
          currentVersion: currentVersion,
          targetVersion: latest,
          title: rc.getString(keyUpdateTitle).trim().isNotEmpty
              ? rc.getString(keyUpdateTitle).trim()
              : defaultRemoteConfigValues[keyUpdateTitle] as String,
          message: rc.getString(keyUpdateMessage).trim().isNotEmpty
              ? rc.getString(keyUpdateMessage).trim()
              : defaultRemoteConfigValues[keyUpdateMessage] as String,
          storeUrl: storeUrl,
        );
      }
    } catch (e) {
      debugPrint('AppUpdateService check failed: $e');
    }
    return AppUpdateInfo.none;
  }

  static Future<void> dismissSoftUpdate(
    SharedPreferences prefs,
    String targetVersion,
  ) async {
    await prefs.setString(_dismissedVersionPrefKey, targetVersion);
  }

  static Future<void> openStore(String storeUrl) async {
    if (storeUrl.isEmpty) return;
    final uri = Uri.tryParse(storeUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Returns negative if [a] < [b], 0 if equal, positive if [a] > [b].
  static int _compareVersions(String a, String b) {
    List<int> parse(String v) {
      final clean = v.split('+').first.split('-').first.trim();
      final parts = clean.split('.');
      return List<int>.generate(3, (i) {
        if (i >= parts.length) return 0;
        return int.tryParse(parts[i].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      });
    }

    final pa = parse(a);
    final pb = parse(b);
    for (int i = 0; i < 3; i++) {
      if (pa[i] != pb[i]) return pa[i].compareTo(pb[i]);
    }
    return 0;
  }
}
