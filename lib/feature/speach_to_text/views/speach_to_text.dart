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
  String recognizedText = '';
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
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
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

  Future<void> _startListening() async {
    if (!isInitialized) {
      await _initializeSpeech();
      if (!isInitialized) return;
    }

    setState(() {
      recognizedText = '';
      isListening = true;
    });

    await speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
        }
      },
      localeId: selectedLanguage,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _stopListening() async {
    await speech.stop();
    if (mounted) {
      setState(() => isListening = false);

      if (recognizedText.isNotEmpty) {
        final wordCount = recognizedText.split(' ').length;

        context.read<StatsProvider>().updateFromSpeechToText(wordCount);

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

  @override
  void dispose() {
    _pulseController.dispose();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildLanguageToggle(),
            SizedBox(height: 40.h),

            // Fixed: Wrapped content in Expanded to prevent overflow
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      if (!isListening && recognizedText.isEmpty)
                        _buildInitialState()
                      else
                        _buildRecognitionState(),
                    ],
                  ),
                ),
              ),
            ),

            _buildMicButton(),
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
      onTap: onTap,
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
          'Tap the microphone',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF212121),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Start speaking and I\'ll write it down',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRecognitionState() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Text(
          'What I heard:',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 20.h),
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
            recognizedText.isEmpty
                ? 'Your text will appear here...'
                : recognizedText,
            style: TextStyle(
              fontSize: 16.sp,
              color: recognizedText.isEmpty
                  ? Colors.grey[400]
                  : const Color(0xFF212121),
              height: 1.5,
            ),
          ),
        ),
        if (isListening) ...[
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 8.sp, color: Colors.red[400]),
              SizedBox(width: 8.w),
              Text(
                'Listening...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMicButton() {
    return Center(
      child: GestureDetector(
        onTap: isListening ? _stopListening : _startListening,
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
                          (isListening ? Colors.red : const Color(0xFF4CAF50))
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
    );
  }
}
