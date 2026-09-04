import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/models/story_model.dart';

class AudioPlayerState {
  final bool isPlaying;
  final double progress;
  final double playbackSpeed;
  final Map<String, String>? selectedVoice;
  final List<Map<String, String>> availableVoices;
  final StoryModel? currentStory;

  const AudioPlayerState({
    this.isPlaying = false,
    this.progress = 0.0,
    this.playbackSpeed = 1.0,
    this.selectedVoice,
    this.availableVoices = const [],
    this.currentStory,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    double? progress,
    double? playbackSpeed,
    Map<String, String>? selectedVoice,
    List<Map<String, String>>? availableVoices,
    StoryModel? currentStory,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      availableVoices: availableVoices ?? this.availableVoices,
      currentStory: currentStory ?? this.currentStory,
    );
  }
}

class AudioPlayerNotifier extends Notifier<AudioPlayerState> {
  @override
  AudioPlayerState build() {
    Future.microtask(() => _initTts());
    return const AudioPlayerState();
  }

  late FlutterTts _flutterTts;
  Timer? _playbackTimer;

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    try {
      final dynamic systemVoices = await _flutterTts.getVoices;
      if (systemVoices is List) {
        final List<Map<String, String>> engVoices = [];
        final Set<String> seenLocales = {};
        for (var voice in systemVoices) {
          if (voice is Map &&
              voice["locale"] != null &&
              voice["name"] != null) {
            String locale = voice["locale"].toString();
            String name = voice["name"].toString();
            if (locale.startsWith("en-")) {
              if (seenLocales.contains(locale) ||
                  name.toLowerCase().contains("network"))
                continue;
              seenLocales.add(locale);
              String displayName = "English";
              if (locale.contains("US")) displayName = "American Accent";
              if (locale.contains("GB") || locale.contains("UK"))
                displayName = "British Accent";
              if (locale.contains("IN")) displayName = "Indian Accent";
              if (locale.contains("AU")) displayName = "Australian Accent";
              if (locale.contains("NG")) displayName = "Nigerian Accent";
              engVoices.add({
                "name": name,
                "locale": locale,
                "displayName": displayName,
              });
            }
          }
        }
        final order = [
          "American Accent",
          "British Accent",
          "Indian Accent",
          "Australian Accent",
          "Nigerian Accent",
        ];
        engVoices.sort((a, b) {
          int indexA = order.indexOf(a["displayName"] ?? "");
          int indexB = order.indexOf(b["displayName"] ?? "");
          if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
          if (indexA != -1) return -1;
          if (indexB != -1) return 1;
          return (a["displayName"] ?? "").compareTo(b["displayName"] ?? "");
        });

        final voices = engVoices.take(5).toList();
        Map<String, String>? initialVoice;
        if (voices.isNotEmpty) {
          initialVoice = voices.firstWhere(
            (v) => v["displayName"] == "American Accent",
            orElse: () => voices.first,
          );
        }

        state = state.copyWith(
          availableVoices: voices,
          selectedVoice: initialVoice,
        );
      }
    } catch (e) {
      debugPrint("Failed to load voices: $e");
    }

    _flutterTts.setSharedInstance(true);
    _flutterTts.awaitSpeakCompletion(false);
    _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers,
    ]);

    _flutterTts.setCompletionHandler(() {});
    _flutterTts.setCancelHandler(() {});
    _flutterTts.setPauseHandler(() {});
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _playbackTimer?.cancel();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> closePlayer() async {
    stop();
    state = AudioPlayerState(
      isPlaying: false,
      progress: 0.0,
      playbackSpeed: state.playbackSpeed,
      selectedVoice: state.selectedVoice,
      availableVoices: state.availableVoices,
      currentStory: null,
    );
  }

  void updateProgress(double value) {
    state = state.copyWith(progress: value);
  }

  void cancelTimer() {
    _playbackTimer?.cancel();
  }

  Future<void> changeSpeed(double speed) async {
    state = state.copyWith(playbackSpeed: speed);
    if (state.isPlaying) {
      await stop();
    }
  }

  Future<void> changeVoice(Map<String, String> voice) async {
    state = state.copyWith(selectedVoice: voice);
    if (state.isPlaying) {
      await stop();
    }
  }

  Future<void> togglePlayPause(StoryModel story) async {
    if (state.currentStory?.storyId != story.storyId) {
      // Switching stories
      state = state.copyWith(currentStory: story, progress: 0.0);
      await startPlaybackFrom(0.0);
      return;
    }

    if (state.isPlaying) {
      stop();
    } else {
      if (state.progress >= 1.0) {
        state = state.copyWith(progress: 0.0);
      }
      await startPlaybackFrom(state.progress);
    }
  }

  Future<void> startPlaybackFrom(double progressPercentage) async {
    if (state.currentStory == null) return;

    await _flutterTts.stop();
    _playbackTimer?.cancel();
    state = state.copyWith(isPlaying: true, progress: progressPercentage);

    try {
      final story = state.currentStory!;
      String fullText = story.description;
      if (story.heading.isNotEmpty) {
        String authorName = (!story.displayAuthorName)
            ? "Anonymous"
            : (story.author?.displayName ?? "Anonymous");
        String intro =
            "${story.heading}. A story by $authorName.\n\n...\n\n...\n\n";
        fullText = "$intro$fullText";
      }

      int cutIndex = (fullText.length * progressPercentage).toInt();
      while (cutIndex > 0 &&
          cutIndex < fullText.length &&
          fullText[cutIndex] != ' ' &&
          fullText[cutIndex] != '\n') {
        cutIndex--;
      }
      String textToRead = fullText.substring(cutIndex);

      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5 * state.playbackSpeed);
      await _flutterTts.setPitch(1.0);

      if (state.selectedVoice != null) {
        await _flutterTts.setVoice(state.selectedVoice!);
      }

      final List<String> chunks = [];
      int start = 0;
      while (start < textToRead.length) {
        int end = start + 3000;
        if (end > textToRead.length) {
          chunks.add(textToRead.substring(start));
          break;
        }
        int lastSpace = textToRead.lastIndexOf(RegExp(r'\s'), end);
        if (lastSpace <= start) lastSpace = end;
        chunks.add(textToRead.substring(start, lastSpace));
        start = lastSpace;
      }

      await _flutterTts.setQueueMode(1);

      final totalWordCount = fullText.split(RegExp(r'\s+')).length;
      final estimatedSeconds = (totalWordCount / (2.5 * state.playbackSpeed))
          .ceil();

      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!state.isPlaying) {
          timer.cancel();
          return;
        }
        final increment = estimatedSeconds > 0 ? (1.0 / estimatedSeconds) : 1.0;
        if (state.progress + increment >= 1.0) {
          state = state.copyWith(progress: 1.0, isPlaying: false);
          timer.cancel();
        } else {
          state = state.copyWith(progress: state.progress + increment);
        }
      });

      for (var chunk in chunks) {
        await _flutterTts.speak(chunk);
      }
    } catch (e) {
      state = state.copyWith(isPlaying: false);
      debugPrint('Error: $e');
    }
  }
}

final audioPlayerProvider =
    NotifierProvider<AudioPlayerNotifier, AudioPlayerState>(
      AudioPlayerNotifier.new,
    );
