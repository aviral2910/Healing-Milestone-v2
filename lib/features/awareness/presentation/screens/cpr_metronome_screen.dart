import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/awareness_providers.dart';
import '../../data/awareness_strings.dart';

class CprMetronomeScreen extends ConsumerStatefulWidget {
  const CprMetronomeScreen({super.key});

  @override
  ConsumerState<CprMetronomeScreen> createState() => _CprMetronomeScreenState();
}

class _CprMetronomeScreenState extends ConsumerState<CprMetronomeScreen>
    with SingleTickerProviderStateMixin {
  static const int _bpm = 110;
  static const int _beatIntervalMs = 545; // 60000 / 110 ≈ 545ms
  static const int _breathPauseSeconds = 5;

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _tickPlayerA = AudioPlayer();
  final AudioPlayer _tickPlayerB = AudioPlayer();
  bool _usePlayerA = true;
  bool _audioReady = false;

  Timer? _compressionTimer;
  Timer? _breathTimer;
  late AnimationController _pulseController;

  bool _isRunning = false;
  bool _isBreathPhase = false;
  int _breathSecondsLeft = _breathPauseSeconds;

  bool _beatSoundEnabled = true;
  bool _voiceEnabled = true;
  bool _hapticsEnabled = true;
  bool _handsOnlyMode = true;

  int _compressionCount = 0;
  int _cycleCount = 1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _initAudioAndTts();
  }

  Future<void> _initAudioAndTts() async {
    final lang = ref.read(awarenessProvider).language;
    final targetLocale = lang.ttsLocale;
    try {
      final available = await _tts.isLanguageAvailable(targetLocale);
      await _tts.setLanguage(available == true ? targetLocale : 'en-US');
    } catch (_) {
      await _tts.setLanguage('en-US');
    }
    await _tts.setSpeechRate(0.52);
    await _tts.setPitch(1.0);

    try {
      final dir = await getTemporaryDirectory();
      final tickFile = File('${dir.path}/cpr_metronome_tick.wav');
      if (!await tickFile.exists()) {
        await tickFile.writeAsBytes(_buildMetronomeClickWav());
      }
      await _tickPlayerA.setFilePath(tickFile.path);
      await _tickPlayerB.setFilePath(tickFile.path);
      await _tickPlayerA.setVolume(1.0);
      await _tickPlayerB.setVolume(1.0);
      if (mounted) {
        setState(() => _audioReady = true);
      }
    } catch (_) {
      // Fallback gracefully if audio setup fails in test/unsupported env
    }
  }

  /// Generates a crisp 40ms 880Hz percussive click as a 16-bit PCM WAV.
  Uint8List _buildMetronomeClickWav() {
    const sampleRate = 22050;
    const durationMs = 40;
    const numSamples = (sampleRate * durationMs) ~/ 1000;
    const dataSize = numSamples * 2;
    final buffer = ByteData(44 + dataSize);

    buffer.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    buffer.setUint32(4, 36 + dataSize, Endian.little);
    buffer.setUint32(8, 0x57415645, Endian.big); // "WAVE"
    buffer.setUint32(12, 0x666D7420, Endian.big); // "fmt "
    buffer.setUint32(16, 16, Endian.little);
    buffer.setUint16(20, 1, Endian.little);
    buffer.setUint16(22, 1, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little);
    buffer.setUint16(32, 2, Endian.little);
    buffer.setUint16(34, 16, Endian.little);
    buffer.setUint32(36, 0x64617461, Endian.big); // "data"
    buffer.setUint32(40, dataSize, Endian.little);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.exp(-t * 95.0);
      final wave = math.sin(2 * math.pi * 880.0 * t);
      final sample = (wave * envelope * 28000).round().clamp(-32768, 32767);
      buffer.setInt16(44 + i * 2, sample, Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  void _playBeatSound() {
    if (!_beatSoundEnabled || !_audioReady) return;
    final player = _usePlayerA ? _tickPlayerA : _tickPlayerB;
    _usePlayerA = !_usePlayerA;
    player.seek(Duration.zero).then((_) => player.play());
  }

  @override
  void dispose() {
    _compressionTimer?.cancel();
    _breathTimer?.cancel();
    _tts.stop();
    _tickPlayerA.dispose();
    _tickPlayerB.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleMetronome() {
    if (_isRunning) {
      _stopMetronome();
    } else {
      _startMetronome();
    }
  }

  void _startMetronome() {
    setState(() {
      _isRunning = true;
      _isBreathPhase = false;
    });
    final isHi = ref.read(awarenessProvider).language == AwarenessLanguage.hi;
    if (_voiceEnabled) {
      _tts.speak(
        isHi
            ? (_handsOnlyMode
                ? 'केवल हाथ से सी पी आर। लगातार जोर से और तेज दबाएं।'
                : '30 और 2 सी पी आर। 30 बार दबाएं, फिर 2 बचाव श्वास दें।')
            : (_handsOnlyMode
                ? 'Hands-only C P R. Push hard and fast continuously.'
                : '30 to 2 C P R. Give 30 compressions, then 2 rescue breaths.'),
      );
    }
    _startCompressionLoop();
  }

  void _startCompressionLoop() {
    _compressionTimer?.cancel();
    _onBeat();
    _compressionTimer = Timer.periodic(
      const Duration(milliseconds: _beatIntervalMs),
      (_) => _onBeat(),
    );
  }

  void _stopMetronome() {
    _compressionTimer?.cancel();
    _breathTimer?.cancel();
    _tts.stop();
    setState(() {
      _isRunning = false;
      _isBreathPhase = false;
    });
  }

  void _resetCounter() {
    _stopMetronome();
    setState(() {
      _compressionCount = 0;
      _cycleCount = 1;
      _breathSecondsLeft = _breathPauseSeconds;
    });
  }

  void _onBeat() {
    if (!mounted || _isBreathPhase) return;
    _pulseController.forward(from: 0.0);
    _playBeatSound();
    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }

    final nextCount = _compressionCount >= 30 ? 1 : _compressionCount + 1;
    final nextCycle =
        _compressionCount >= 30 ? _cycleCount + 1 : _cycleCount;

    setState(() {
      _compressionCount = nextCount;
      _cycleCount = nextCycle;
    });

    if (_compressionCount == 30) {
      final isHi = ref.read(awarenessProvider).language == AwarenessLanguage.hi;
      if (_handsOnlyMode) {
        if (_voiceEnabled) {
          _tts.speak(
            isHi ? '30 दबाव। दबाते रहें।' : '30 compressions. Keep pushing.',
          );
        }
      } else {
        _enterBreathPhase();
      }
    }
  }

  void _enterBreathPhase() {
    _compressionTimer?.cancel();
    setState(() {
      _isBreathPhase = true;
      _breathSecondsLeft = _breathPauseSeconds;
    });

    final isHi = ref.read(awarenessProvider).language == AwarenessLanguage.hi;
    if (_voiceEnabled) {
      _tts.speak(
        isHi
            ? 'दबाना रोकें। 2 बचाव श्वास दें।'
            : 'Stop compressions. Give 2 rescue breaths.',
      );
    }

    _breathTimer?.cancel();
    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isRunning) {
        timer.cancel();
        return;
      }
      if (_breathSecondsLeft > 1) {
        setState(() => _breathSecondsLeft--);
      } else {
        timer.cancel();
        setState(() {
          _isBreathPhase = false;
          _compressionCount = 0;
          _cycleCount++;
        });
        if (_voiceEnabled) {
          _tts.speak(
            isHi ? 'फिर से दबाना शुरू करें।' : 'Resume compressions.',
          );
        }
        _startCompressionLoop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final awarenessState = ref.watch(awarenessProvider);
    final s = AwarenessStrings(awarenessState.language);
    final emergencyNumber = awarenessState.emergencyNumber;

    final double progress = !_isRunning
        ? 0.0
        : _isBreathPhase
            ? _breathSecondsLeft / _breathPauseSeconds
            : _compressionCount / 30.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.cprCoach),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: primary.withValues(alpha: 0.12),
                foregroundColor: primary,
                side: BorderSide(color: primary.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => launchEmergencyDialer(context, emergencyNumber),
              icon: const Icon(Icons.call_outlined, size: 16),
              label: Text(
                'SOS $emergencyNumber',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              // Mode Toggle
              SegmentedButton<bool>(
                style: SegmentedButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  foregroundColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  selectedBackgroundColor: primary.withValues(alpha: 0.16),
                  selectedForegroundColor: primary,
                  side: BorderSide(color: theme.dividerColor),
                ),
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(s.handsOnly),
                    icon: const Icon(Icons.front_hand_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(s.breaths302),
                    icon: const Icon(Icons.air, size: 18),
                  ),
                ],
                selected: {_handsOnlyMode},
                onSelectionChanged: (val) {
                  setState(() => _handsOnlyMode = val.first);
                  if (_isRunning) {
                    _resetCounter();
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                _handsOnlyMode ? s.continuousDesc : s.breaths302Desc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),

              // Visual Metronome Ring + Breath Phase
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _toggleMetronome,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = (_isRunning && !_isBreathPhase)
                            ? 1.0 + (0.07 * (1.0 - _pulseController.value))
                            : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: SizedBox(
                            width: 240,
                            height: 240,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 236,
                                  height: 236,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 6,
                                    backgroundColor: theme.dividerColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isBreathPhase
                                          ? theme.colorScheme.onSurface
                                          : primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 214,
                                  height: 214,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isRunning
                                        ? (_isBreathPhase
                                            ? theme.cardColor
                                            : primary.withValues(alpha: 0.12))
                                        : theme.cardColor,
                                    border: Border.all(
                                      color: _isRunning
                                          ? (_isBreathPhase
                                              ? theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.45)
                                              : primary.withValues(alpha: 0.5))
                                          : theme.dividerColor,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        !_isRunning
                                            ? s.tapToStart
                                            : _isBreathPhase
                                                ? s.twoBreaths
                                                : s.push,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: _isBreathPhase
                                              ? theme.colorScheme.onSurface
                                              : primary,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        !_isRunning
                                            ? '$_bpm'
                                            : _isBreathPhase
                                                ? '${_breathSecondsLeft}s'
                                                : '$_compressionCount',
                                        style: theme.textTheme.headlineLarge
                                            ?.copyWith(
                                          fontSize: _isRunning ? 64 : 52,
                                          color: _isBreathPhase
                                              ? theme.colorScheme.onSurface
                                              : _isRunning
                                                  ? primary
                                                  : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        !_isRunning
                                            ? (_handsOnlyMode
                                                ? 'BPM • Continuous'
                                                : 'BPM • 30:2 Cycle')
                                            : _isBreathPhase
                                                ? s.giveTwoBreaths
                                                : 'of 30 • Cycle $_cycleCount',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Quick Technique Strip (Adapts to Hands-Only vs 30:2)
              Row(
                children: [
                  const _MetricChip(label: 'RATE', value: '100–120/m'),
                  const SizedBox(width: 8),
                  const _MetricChip(label: 'DEPTH', value: '5–6 cm'),
                  const SizedBox(width: 8),
                  _MetricChip(
                    label: _handsOnlyMode ? 'BREATHS' : 'CYCLE',
                    value: _handsOnlyMode ? 'None' : '30 : 2',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Audio / Voice / Haptics Controls
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ThemeToggleChip(
                      label: s.beatSound,
                      icon: _beatSoundEnabled
                          ? Icons.music_note_rounded
                          : Icons.music_off_rounded,
                      selected: _beatSoundEnabled,
                      onTap: () =>
                          setState(() => _beatSoundEnabled = !_beatSoundEnabled),
                    ),
                    const SizedBox(width: 8),
                    _ThemeToggleChip(
                      label: s.voice,
                      icon: _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                      selected: _voiceEnabled,
                      onTap: () {
                        setState(() => _voiceEnabled = !_voiceEnabled);
                        if (!_voiceEnabled) _tts.stop();
                      },
                    ),
                    const SizedBox(width: 8),
                    _ThemeToggleChip(
                      label: s.haptics,
                      icon: Icons.vibration,
                      selected: _hapticsEnabled,
                      onTap: () =>
                          setState(() => _hapticsEnabled = !_hapticsEnabled),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Reset counter',
                      onPressed: _resetCounter,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Primary Start / Pause Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _isRunning ? theme.cardColor : primary,
                    foregroundColor: _isRunning
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onPrimary,
                    side: _isRunning
                        ? BorderSide(color: theme.dividerColor)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _toggleMetronome,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    _isRunning ? s.pauseCpr : s.startBeat,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeToggleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.14) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                selected ? primary.withValues(alpha: 0.5) : theme.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selected
                    ? primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                letterSpacing: 1.0,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
