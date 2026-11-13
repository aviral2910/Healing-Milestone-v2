import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

enum AiFeatureMode { free, paid, disabled }

/// Controls AI feature availability (Story AI & Biomarker Extraction)
/// via Firebase Remote Config so features can be paused/hidden or
/// switched to paid without shipping a new app binary.
class AiAccessService {
  static const String keyStoryMode = 'ai_story_mode';
  static const String keyBiomarkerMode = 'ai_biomarker_mode';
  static const String keyPausedMessage = 'ai_paused_message';

  static const String _defaultPausedMessage =
      'AI features are temporarily paused. Please try again later.';

  static const Map<String, dynamic> defaultRemoteConfigValues = {
    keyStoryMode: 'free',
    keyBiomarkerMode: 'free',
    keyPausedMessage: _defaultPausedMessage,
  };

  static Future<void> setDefaults() async {
    try {
      await FirebaseRemoteConfig.instance.setDefaults(
        defaultRemoteConfigValues,
      );
    } catch (e) {
      debugPrint('Failed to set Remote Config AI defaults: $e');
    }
  }

  /// Parses Remote Config values forgivingly (case-insensitive + common aliases)
  /// so typos or synonyms like "paused", "off", "hide", or "pro" work safely.
  static AiFeatureMode parseMode(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'disabled':
      case 'disable':
      case 'off':
      case 'pause':
      case 'paused':
      case 'hide':
      case 'hidden':
      case 'false':
      case '0':
        return AiFeatureMode.disabled;
      case 'paid':
      case 'pro':
      case 'pay':
      case 'locked':
      case 'premium':
        return AiFeatureMode.paid;
      case 'free':
      case 'on':
      case 'open':
      case 'enabled':
      case 'true':
      case '1':
      default:
        return AiFeatureMode.free;
    }
  }

  static AiFeatureMode get storyMode {
    try {
      return parseMode(FirebaseRemoteConfig.instance.getString(keyStoryMode));
    } catch (_) {
      return AiFeatureMode.free;
    }
  }

  static AiFeatureMode get biomarkerMode {
    try {
      return parseMode(
        FirebaseRemoteConfig.instance.getString(keyBiomarkerMode),
      );
    } catch (_) {
      return AiFeatureMode.free;
    }
  }

  static String get pausedMessage {
    try {
      final msg = FirebaseRemoteConfig.instance
          .getString(keyPausedMessage)
          .trim();
      return msg.isEmpty ? _defaultPausedMessage : msg;
    } catch (_) {
      return _defaultPausedMessage;
    }
  }

  static Future<void> showUpgradePrompt(
    BuildContext context, {
    required String featureName,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$featureName is Pro'),
        content: Text(
          '$featureName is available on the Pro plan. Upgrade options will be available here.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
