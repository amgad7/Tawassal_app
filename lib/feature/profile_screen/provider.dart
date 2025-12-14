import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_state_model.dart';

class StatsProvider with ChangeNotifier {
  UserStats _stats = UserStats(
    name: 'Little Star',
    age: 6,
    totalWords: 0,
    speechToTextCount: 0,
    textToSpeechCount: 0,
    currentStreak: 0,
    unlockedBadges: [],
    weeklyGoalProgress: 0.0,
  );

  UserStats get stats => _stats;
  static const String statsKey = 'user_stats';
  static const String _profileKey = 'user_profile';
  static const int _weeklyGoal = 20;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final String? profileJson = prefs.getString(_profileKey);

      if (profileJson != null) {
        final profile = json.decode(profileJson);
        _stats = UserStats(
          name: profile['name'] ?? 'Little Star',
          age: profile['age'] ?? 6,
          totalWords: 0,
          speechToTextCount: 0,
          textToSpeechCount: 0,
          currentStreak: 0,
          unlockedBadges: [],
          weeklyGoalProgress: 0.0,
        );
      } else {
        _stats = UserStats(
          name: 'Little Star',
          age: 6,
          totalWords: 0,
          speechToTextCount: 0,
          textToSpeechCount: 0,
          currentStreak: 0,
          unlockedBadges: [],
          weeklyGoalProgress: 0.0,
        );
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profile = {'name': _stats.name, 'age': _stats.age};
      await prefs.setString(_profileKey, json.encode(profile));
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  Future<void> updateFromSpeechToText(int wordCount) async {
    _stats = UserStats(
      name: _stats.name,
      age: _stats.age,
      totalWords: _stats.totalWords + wordCount,
      speechToTextCount: _stats.speechToTextCount + 1,
      textToSpeechCount: _stats.textToSpeechCount,
      currentStreak: _stats.currentStreak,
      unlockedBadges: _stats.unlockedBadges,
      weeklyGoalProgress: _calculateProgress(_stats.totalWords + wordCount),
    );

    await checkAndUnlockBadges();
    notifyListeners();
  }

  Future<void> updateFromTextToSpeech(int wordCount) async {
    _stats = UserStats(
      name: _stats.name,
      age: _stats.age,
      totalWords: _stats.totalWords + wordCount,
      speechToTextCount: _stats.speechToTextCount,
      textToSpeechCount: _stats.textToSpeechCount + 1,
      currentStreak: _stats.currentStreak,
      unlockedBadges: _stats.unlockedBadges,
      weeklyGoalProgress: _calculateProgress(_stats.totalWords + wordCount),
    );

    await checkAndUnlockBadges();
    notifyListeners();
  }

  double _calculateProgress(int totalWords) {
    final progress = totalWords / _weeklyGoal;
    return progress > 1.0 ? 1.0 : progress;
  }

  Future<void> checkAndUnlockBadges() async {
    final badges = UserStats.getAllBadges();
    final List<String> newBadges = List.from(_stats.unlockedBadges);

    for (var badge in badges) {
      if (!newBadges.contains(badge.id)) {
        bool unlock = false;

        switch (badge.id) {
          case 'first_word':
            unlock = _stats.totalWords >= 1;
            break;
          case 'word_wizard':
            unlock = _stats.totalWords >= 50;
            break;
          case 'super_speaker':
            unlock = _stats.speechToTextCount >= 10;
            break;
          case 'voice_master':
            unlock = _stats.textToSpeechCount >= 10;
            break;
          case 'streak_hero':
            unlock = _stats.currentStreak >= 7;
            break;
          case 'goal_getter':
            unlock = _stats.weeklyGoalProgress >= 1.0;
            break;
        }

        if (unlock) {
          newBadges.add(badge.id);
        }
      }
    }

    if (newBadges.length != _stats.unlockedBadges.length) {
      _stats = UserStats(
        name: _stats.name,
        age: _stats.age,
        totalWords: _stats.totalWords,
        speechToTextCount: _stats.speechToTextCount,
        textToSpeechCount: _stats.textToSpeechCount,
        currentStreak: _stats.currentStreak,
        unlockedBadges: newBadges,
        weeklyGoalProgress: _stats.weeklyGoalProgress,
      );
    }
  }

  Future<void> updateProfile(String name, int age) async {
    _stats = UserStats(
      name: name,
      age: age,
      totalWords: _stats.totalWords,
      speechToTextCount: _stats.speechToTextCount,
      textToSpeechCount: _stats.textToSpeechCount,
      currentStreak: _stats.currentStreak,
      unlockedBadges: _stats.unlockedBadges,
      weeklyGoalProgress: _stats.weeklyGoalProgress,
    );
    await saveProfile();
    notifyListeners();
  }
}
