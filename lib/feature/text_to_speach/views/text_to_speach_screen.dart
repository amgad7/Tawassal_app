import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../../profile_screen/provider.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  bool isSpeaking = false;
  String selectedLanguage = 'en-US';

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeTts();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(selectedLanguage);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => isSpeaking = false);
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() => isSpeaking = false);
      }
    });
  }

  Future<void> _speak() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter some text first'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }

    setState(() => isSpeaking = true);
    await _flutterTts.setLanguage(selectedLanguage);

    final textToSpeak = _textController.text;
    final wordCount = textToSpeak.split(' ').length;

    await _flutterTts.speak(textToSpeak);

    context.read<StatsProvider>().updateFromTextToSpeech(wordCount);
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() => isSpeaking = false);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _textController.dispose();
    _flutterTts.stop();
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

            SizedBox(height: 30.h),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type Now',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    Container(
                      constraints: BoxConstraints(minHeight: 200.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 16.sp,
                          height: 1.5,
                          color: const Color(0xFF212121),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Your text will appear here...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20.w),
                        ),
                      ),
                    ),

                    if (isSpeaking) ...[
                      SizedBox(height: 20.h),
                      buildSpeakingIndicator(),
                    ],
                  ],
                ),
              ),
            ),

            _buildSpeakerButton(),

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
            'Text to Speech',
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
              () async {
                setState(() => selectedLanguage = 'en-US');
                await _flutterTts.setLanguage('en-US');
              },
            ),
          ),
          Expanded(
            child: _buildLanguageButton(
              'العربية',
              selectedLanguage == 'ar-SA',
              () async {
                setState(() => selectedLanguage = 'ar-SA');
                await _flutterTts.setLanguage('ar-SA');
              },
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

  Widget buildSpeakingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.volume_up_rounded, size: 20.sp, color: Colors.green[600]),
        SizedBox(width: 8.w),
        Text(
          'Speaking...',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.green[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakerButton() {
    return Center(
      child: GestureDetector(
        onTap: isSpeaking ? _stop : _speak,
        child: AnimatedBuilder(
          animation: isSpeaking
              ? _waveAnimation
              : const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            return Transform.scale(
              scale: isSpeaking ? _waveAnimation.value : 1.0,
              child: Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSpeaking
                      ? Colors.orange[400]
                      : const Color(0xFF4CAF50),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isSpeaking ? Colors.orange : const Color(0xFF4CAF50))
                              .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
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
