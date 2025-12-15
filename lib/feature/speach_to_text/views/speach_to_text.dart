import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import '../../profile_screen/provider.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isInitialized = false;
  bool keepListening = false;
  String fullText = '';
  String currentSegment = '';
  String selectedLanguage = 'en-US';

  late AnimationController _pulseController;
  late Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    _initializeSpeech();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSpeech() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await speech.initialize(
        onError: (error) {
          debugPrint('Speech error: $error');
          if (keepListening && mounted) {
            Future.delayed(
              const Duration(milliseconds: 500),
              _restartListening,
            );
          }
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'notListening' && keepListening && mounted) {
            Future.delayed(
              const Duration(milliseconds: 500),
              _restartListening,
            );
          }
        },
      );
      if (mounted) {
        setState(() => isInitialized = available);
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Microphone Permission'),
        content: const Text(
          'This app needs microphone access to convert your speech to text. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (isListening) {
      await _stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    if (!isInitialized) {
      await _initializeSpeech();
      if (!isInitialized) return;
    }

    setState(() {
      isListening = true;
      keepListening = true;
    });

    await _beginListening();
  }

  Future<void> _beginListening() async {
    if (!keepListening || !mounted) return;

    try {
      await speech.listen(
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            currentSegment = result.recognizedWords;

            if (result.finalResult && currentSegment.isNotEmpty) {
              if (fullText.isEmpty) {
                fullText = currentSegment;
              } else {
                fullText = '$fullText $currentSegment';
              }
              currentSegment = '';
            }
          });
        },
        localeId: selectedLanguage,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        onSoundLevelChange: (level) {},
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
    } catch (e) {
      debugPrint('Listen error: $e');
      if (keepListening && mounted) {
        Future.delayed(const Duration(milliseconds: 500), _restartListening);
      }
    }
  }

  Future<void> _restartListening() async {
    if (!keepListening || !mounted) return;

    try {
      await speech.stop();
      await Future.delayed(const Duration(milliseconds: 200));

      if (keepListening && mounted) {
        await _beginListening();
      }
    } catch (e) {
      debugPrint('Restart error: $e');
    }
  }

  Future<void> _stopListening() async {
    setState(() {
      keepListening = false;
      isListening = false;
    });

    await speech.stop();

    if (mounted) {
      final finalText = fullText.isEmpty
          ? currentSegment
          : currentSegment.isEmpty
          ? fullText
          : '$fullText $currentSegment';

      if (finalText.isNotEmpty) {
        final wordCount = finalText
            .split(' ')
            .where((w) => w.isNotEmpty)
            .length;
        context.read<StatsProvider>().updateFromSpeechToText(wordCount);

        setState(() {
          fullText = finalText;
          currentSegment = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Saved $wordCount ${wordCount == 1 ? 'word' : 'words'}! ',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _clearText() async {
    setState(() {
      fullText = '';
      currentSegment = '';
    });
  }

  @override
  void dispose() {
    keepListening = false;
    _pulseController.dispose();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = fullText.isEmpty
        ? currentSegment
        : currentSegment.isEmpty
        ? fullText
        : '$fullText $currentSegment';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildLanguageToggle(),
            SizedBox(height: 40.h),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      if (!isListening && displayText.isEmpty)
                        _buildInitialState()
                      else
                        buildRecognitionState(displayText),
                    ],
                  ),
                ),
              ),
            ),

            buildControlButtons(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp),
            ),
          ),
          Text(
            'Speech to Text',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.more_vert_rounded, size: 22.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildLanguageButton(
              'English',
              selectedLanguage == 'en-US',
              () => setState(() => selectedLanguage = 'en-US'),
            ),
          ),
          Expanded(
            child: _buildLanguageButton(
              'العربية',
              selectedLanguage == 'ar-SA',
              () => setState(() => selectedLanguage = 'ar-SA'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: isListening ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(26.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 60.h),
        Container(
          width: 200.w,
          height: 200.h,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mic_none_rounded,
            size: 100.sp,
            color: Colors.grey[300],
          ),
        ),
        SizedBox(height: 40.h),
        Text(
          'Tap to Start Recording',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF212121),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Speak clearly into your microphone\nPress stop when you\'re done',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget buildRecognitionState(String displayText) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transcript:',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            if (displayText.isNotEmpty && !isListening)
              TextButton.icon(
                onPressed: _clearText,
                icon: Icon(Icons.clear, size: 16.sp),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[400],
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          constraints: BoxConstraints(minHeight: 150.h),
          child: Text(
            displayText.isEmpty ? 'Start speaking...' : displayText,
            style: TextStyle(
              fontSize: 16.sp,
              color: displayText.isEmpty
                  ? Colors.grey[400]
                  : const Color(0xFF212121),
              height: 1.5,
            ),
          ),
        ),
        if (isListening) ...[
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8.sp, color: Colors.red[400]),
                SizedBox(width: 8.w),
                Text(
                  'Listening... Speak now',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (!isListening && displayText.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            'Word count: ${displayText.split(' ').where((w) => w.isNotEmpty).length}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget buildControlButtons() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: isListening
                  ? pulseAnimation
                  : const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: isListening ? pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening
                          ? Colors.red[400]
                          : const Color(0xFF4CAF50),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isListening
                                      ? Colors.red
                                      : const Color(0xFF4CAF50))
                                  .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 36.sp,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            isListening ? 'Tap to Stop' : 'Tap to Start',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
