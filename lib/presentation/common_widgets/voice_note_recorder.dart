import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';
import 'package:mesh_app/utils/media_picker_helper.dart';

class VoiceNoteRecorder extends StatefulWidget {
  final Function(File audioFile) onRecordingComplete;
  final VoidCallback onCancel;

  const VoiceNoteRecorder({
    super.key,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  late AnimationController _pulseController;
  StreamSubscription<Duration>? _durationSubscription;

  static const int maxRecordingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _durationSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final started = await MediaPickerHelper.startAudioRecording();
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start recording. Check microphone permissions.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _recordingDuration = Duration.zero;
    });

    _durationSubscription = MediaPickerHelper.getRecordingStream()?.listen((duration) {
      if (mounted) {
        setState(() {
          _recordingDuration = duration;
        });
        if (_recordingDuration.inSeconds >= maxRecordingSeconds) {
          _stopRecording();
        }
      }
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration = Duration(milliseconds: timer.tick * 100);
        });
        if (_recordingDuration.inSeconds >= maxRecordingSeconds) {
          _stopRecording();
        }
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _durationSubscription?.cancel();
    setState(() {
      _isRecording = false;
    });

    final audioFile = await MediaPickerHelper.stopAudioRecording();
    if (audioFile != null) {
      widget.onRecordingComplete(audioFile);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save recording'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    _durationSubscription?.cancel();
    setState(() {
      _isRecording = false;
    });
    await MediaPickerHelper.cancelAudioRecording();
    widget.onCancel();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).round()),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textHint.withAlpha((255 * 0.3).round()),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              _isRecording ? 'Recording Voice Note' : 'Record Voice Note',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              _isRecording
                  ? 'Tap stop when finished'
                  : 'Tap the microphone to start',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            if (_isRecording)
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 120 + (_pulseController.value * 20),
                        height: 120 + (_pulseController.value * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.errorColor.withAlpha(
                            (255 * (0.1 + _pulseController.value * 0.1)).round(),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.errorColor,
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.errorColor,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    '${maxRecordingSeconds - _recordingDuration.inSeconds}s remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              )
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentColor.withAlpha((255 * 0.1).round()),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentColor,
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppTheme.spacingXL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelRecording,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingM,
                      ),
                      side: const BorderSide(color: AppTheme.textHint),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording
                          ? AppTheme.errorColor
                          : AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(_isRecording ? 'Stop' : 'Start Recording'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
