
import 'package:flutter/material.dart';

class UserStats {
  final String name;
  final int age;
  final int totalWords;
  final int speechToTextCount;
  final int textToSpeechCount;
  final int currentStreak;
  final List<String> unlockedBadges;
  final double weeklyGoalProgress;

  UserStats({
    required this.name,
    required this.age,
    required this.totalWords,
    required this.speechToTextCount,
    required this.textToSpeechCount,
    required this.currentStreak,
    required this.unlockedBadges,
    required this.weeklyGoalProgress,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'totalWords': totalWords,
    'speechToTextCount': speechToTextCount,
    'textToSpeechCount': textToSpeechCount,
    'currentStreak': currentStreak,
    'unlockedBadges': unlockedBadges,
    'weeklyGoalProgress': weeklyGoalProgress,
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    name: json['name'] as String,
    age: json['age'] as int,
    totalWords: json['totalWords'] as int,
    speechToTextCount: json['speechToTextCount'] as int,
    textToSpeechCount: json['textToSpeechCount'] as int,
    currentStreak: json['currentStreak'] as int,
    unlockedBadges: List<String>.from(json['unlockedBadges']),
    weeklyGoalProgress: json['weeklyGoalProgress'] as double,
  );

  static List<Badge> getAllBadges() => [
    Badge(
      id: 'first_word',
      title: 'First Word',
      icon: Icons.star,
      requirement: 'Practice your first word',
      requiredCount: 1,
    ),
    Badge(
      id: 'word_wizard',
      title: 'Word Wizard',
      icon: Icons.menu_book_rounded,
      requirement: 'Practice 50 words',
      requiredCount: 50,
    ),
    Badge(
      id: 'super_speaker',
      title: 'Super Speaker',
      icon: Icons.mic_rounded,
      requirement: 'Use Speech to Text 10 times',
      requiredCount: 10,
    ),
    Badge(
      id: 'voice_master',
      title: 'Voice Master',
      icon: Icons.volume_up_rounded,
      requirement: 'Use Text to Speech 10 times',
      requiredCount: 10,
    ),
    Badge(
      id: 'streak_hero',
      title: 'Streak Hero',
      icon: Icons.local_fire_department_rounded,
      requirement: 'Practice 7 days in a row',
      requiredCount: 7,
    ),
    Badge(
      id: 'goal_getter',
      title: 'Goal Getter',
      icon: Icons.emoji_events,
      requirement: 'Complete weekly goal',
      requiredCount: 1,
    ),
  ];
}

class Badge {
  final String id;
  final String title;
  final IconData icon;
  final String requirement;
  final int requiredCount;

  Badge({
    required this.id,
    required this.title,
    required this.icon,
    required this.requirement,
    required this.requiredCount,
  });
}