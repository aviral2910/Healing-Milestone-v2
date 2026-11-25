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

class CprMetronomeScreen extends ConsumerStatefulWidget {
  const CprMetronomeScreen({super.key});

  @override
  ConsumerState<CprMetronomeScreen> createState() => _CprMetronomeScreenState();
}

class _CprMetronomeScreenState extends ConsumerState<CprMetronomeScreen>
    with SingleTickerProviderStateMixin {
  static const int _bpm = 110;
  static const int _beatIntervalMs = 545; // 60000 / 110 ≈ 545ms

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _tickPlayerA = AudioPlayer();
  final AudioPlayer _tickPlayerB = AudioPlayer();
  bool _usePlayerA = true;
  bool _audioReady = false;

  Timer? _timer;
  late AnimationController _pulseController;

  bool _isRunning = false;
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
    await _tts.setLanguage('en-US');
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
      // Fallback gracefully if audio file setup fails on test/unsupported env
    }
  }

  /// Generates a crisp 40ms 880Hz percussive click as a 16-bit PCM WAV.
  Uint8List _buildMetronomeClickWav() {
    const sampleRate = 22050;
    const durationMs = 40;
    const numSamples = (sampleRate * durationMs) ~/ 1000;
    const dataSize = numSamples * 2;
    final buffer = ByteData(44 + dataSize);

    // RIFF header
    buffer.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    buffer.setUint32(4, 36 + dataSize, Endian.little);
    buffer.setUint32(8, 0x57415645, Endian.big); // "WAVE"
    // fmt chunk
    buffer.setUint32(12, 0x666D7420, Endian.big); // "fmt "
    buffer.setUint32(16, 16, Endian.little); // PCM
    buffer.setUint16(20, 1, Endian.little); // Linear PCM
    buffer.setUint16(22, 1, Endian.little); // Mono
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little);
    buffer.setUint16(32, 2, Endian.little);
    buffer.setUint16(34, 16, Endian.little);
    // data chunk
    buffer.setUint32(36, 0x64617461, Endian.big); // "data"
    buffer.setUint32(40, dataSize, Endian.little);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.exp(-t * 95.0); // Fast percussive decay
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
    _timer?.cancel();
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
    setState(() => _isRunning = true);
    if (_voiceEnabled) {
      _tts.speak('Push hard and fast in the center of the chest.');
    }
    _onBeat();
    _timer = Timer.periodic(
      const Duration(milliseconds: _beatIntervalMs),
      (_) => _onBeat(),
    );
  }

  void _stopMetronome() {
    _timer?.cancel();
    _tts.stop();
    setState(() => _isRunning = false);
  }

  void _resetCounter() {
    _stopMetronome();
    setState(() {
      _compressionCount = 0;
      _cycleCount = 1;
    });
  }

  void _onBeat() {
    if (!mounted) return;
    _pulseController.forward(from: 0.0);
    _playBeatSound();
    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }

    setState(() {
      _compressionCount++;
      if (_compressionCount > 30) {
        _compressionCount = 1;
        _cycleCount++;
      }
    });

    if (_voiceEnabled && _compressionCount == 30) {
      if (_handsOnlyMode) {
        _tts.speak('30 compressions. Keep pushing.');
      } else {
        _tts.speak('30 compressions. Give 2 rescue breaths, then continue.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final emergencyNumber = ref.watch(awarenessProvider).emergencyNumber;
    final progress = _compressionCount / 30.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CPR Coach'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => launchEmergencyDialer(context, emergencyNumber),
              icon: const Icon(Icons.call_outlined, size: 16),
              label: Text('SOS $emergencyNumber'),
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
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Hands-Only'),
                    icon: Icon(Icons.front_hand_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('30:2 Breaths'),
                    icon: Icon(Icons.air, size: 18),
                  ),
                ],
                selected: {_handsOnlyMode},
                onSelectionChanged: (val) {
                  setState(() => _handsOnlyMode = val.first);
                },
              ),

              // Visual Metronome Ring + Progress
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _toggleMetronome,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale =
                            1.0 + (0.07 * (1.0 - _pulseController.value));
                        return Transform.scale(
                          scale: _isRunning ? scale : 1.0,
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
                                    value: _isRunning ? progress : 0.0,
                                    strokeWidth: 6,
                                    backgroundColor: theme.dividerColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 214,
                                  height: 214,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isRunning
                                        ? primary.withValues(alpha: 0.12)
                                        : theme.cardColor,
                                    border: Border.all(
                                      color: _isRunning
                                          ? primary.withValues(alpha: 0.5)
                                          : theme.dividerColor,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isRunning
                                            ? 'PUSH'
                                            : 'TAP TO START',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: primary,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isRunning
                                            ? '$_compressionCount'
                                            : '$_bpm',
                                        style: theme.textTheme.headlineLarge
                                            ?.copyWith(
                                          fontSize: _isRunning ? 64 : 52,
                                          color: _isRunning
                                              ? primary
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isRunning
                                            ? 'of 30 • Cycle $_cycleCount'
                                            : 'BPM Metronome',
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

              // Quick Technique Strip
              Row(
                children: [
                  _MetricChip(label: 'RATE', value: '100–120/m'),
                  const SizedBox(width: 8),
                  _MetricChip(label: 'DEPTH', value: '5–6 cm'),
                  const SizedBox(width: 8),
                  _MetricChip(label: 'RECOIL', value: 'Full Rise'),
                ],
              ),
              const SizedBox(height: 14),

              // Audio / Voice / Haptics Controls
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Beat Sound'),
                      selected: _beatSoundEnabled,
                      avatar: Icon(
                        _beatSoundEnabled
                            ? Icons.music_note_rounded
                            : Icons.music_off_rounded,
                        size: 16,
                      ),
                      onSelected: (v) => setState(() => _beatSoundEnabled = v),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Voice'),
                      selected: _voiceEnabled,
                      avatar: Icon(
                        _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                        size: 16,
                      ),
                      onSelected: (v) {
                        setState(() => _voiceEnabled = v);
                        if (!v) _tts.stop();
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Haptics'),
                      selected: _hapticsEnabled,
                      avatar: const Icon(Icons.vibration, size: 16),
                      onSelected: (v) => setState(() => _hapticsEnabled = v),
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
                    _isRunning ? 'Pause CPR Coach' : 'Start 110 BPM Beat',
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
