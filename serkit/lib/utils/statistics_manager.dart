import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Achievement data model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int requiredCount;
  bool unlocked;
  int progress;
  
  Achievement({
    required this.id,
    required this.title, 
    required this.description, 
    required this.iconName,
    required this.requiredCount,
    this.unlocked = false,
    this.progress = 0,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'requiredCount': requiredCount,
      'unlocked': unlocked,
      'progress': progress,
    };
  }
  
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconName: json['iconName'],
      requiredCount: json['requiredCount'],
      unlocked: json['unlocked'],
      progress: json['progress'],
    );
  }
}

/// Game statistics data model
class GameStatistics {
  int totalGamesPlayed;
  int totalLevelsCompleted;
  int totalConnections;
  int totalUndos;
  int totalResets;
  int perfectCompletions;
  Duration totalPlayTime;
  int longestStreak;
  int currentStreak;
  
  GameStatistics({
    this.totalGamesPlayed = 0,
    this.totalLevelsCompleted = 0,
    this.totalConnections = 0,
    this.totalUndos = 0,
    this.totalResets = 0,
    this.perfectCompletions = 0,
    this.totalPlayTime = Duration.zero,
    this.longestStreak = 0,
    this.currentStreak = 0,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalLevelsCompleted': totalLevelsCompleted,
      'totalConnections': totalConnections,
      'totalUndos': totalUndos,
      'totalResets': totalResets,
      'perfectCompletions': perfectCompletions,
      'totalPlayTimeMs': totalPlayTime.inMilliseconds,
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
    };
  }
  
  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    return GameStatistics(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalLevelsCompleted: json['totalLevelsCompleted'] ?? 0,
      totalConnections: json['totalConnections'] ?? 0,
      totalUndos: json['totalUndos'] ?? 0,
      totalResets: json['totalResets'] ?? 0,
      perfectCompletions: json['perfectCompletions'] ?? 0,
      totalPlayTime: Duration(milliseconds: json['totalPlayTimeMs'] ?? 0),
      longestStreak: json['longestStreak'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
    );
  }
}

/// StatisticsManager to track player achievements and statistics
class StatisticsManager {
  static const String _statsKey = 'serkit_statistics';
  static const String _achievementsKey = 'serkit_achievements';
  static final StatisticsManager _instance = StatisticsManager._internal();
  
  factory StatisticsManager() => _instance;
  
  StatisticsManager._internal();
  
  GameStatistics _statistics = GameStatistics();
  List<Achievement> _achievements = [];
  DateTime? _sessionStartTime;
  final Set<String> _achievementListeners = {};
  
  /// Get current game statistics
  GameStatistics get statistics => _statistics;
  
  /// Get list of achievements
  List<Achievement> get achievements => _achievements;
  
  /// Initialize the manager
  Future<void> initialize() async {
    await _loadData();
    await _initializeAchievements();
    _sessionStartTime = DateTime.now();
  }
  
  /// Load saved data from storage
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load statistics
      final statsJson = prefs.getString(_statsKey);
      if (statsJson != null) {
        _statistics = GameStatistics.fromJson(jsonDecode(statsJson));
      }
      
      // Load achievements
      final achievementsJson = prefs.getString(_achievementsKey);
      if (achievementsJson != null) {
        final List<dynamic> achievementsList = jsonDecode(achievementsJson);
        _achievements = achievementsList.map((e) => Achievement.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading statistics: $e');
      }
    }
  }
  
  /// Save data to storage
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save statistics
      await prefs.setString(_statsKey, jsonEncode(_statistics.toJson()));
      
      // Save achievements
      final achievementsJson = jsonEncode(_achievements.map((e) => e.toJson()).toList());
      await prefs.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving statistics: $e');
      }
    }
  }
  
  /// Create default achievements
  Future<void> _initializeAchievements() async {
    // Only initialize if no achievements exist yet
    if (_achievements.isNotEmpty) return;
    
    _achievements = [
      Achievement(
        id: 'first_connection',
        title: 'First Connection',
        description: 'Make your first connection',
        iconName: 'connect',
        requiredCount: 1,
      ),
      Achievement(
        id: 'circuit_master',
        title: 'Circuit Master',
        description: 'Complete 10 levels',
        iconName: 'trophy',
        requiredCount: 10,
      ),
      Achievement(
        id: 'perfect_10',
        title: 'Perfect 10',
        description: 'Complete 10 levels with perfect solutions',
        iconName: 'star',
        requiredCount: 10,
      ),
      Achievement(
        id: 'quick_thinker',
        title: 'Quick Thinker',
        description: 'Complete a level in under 10 seconds',
        iconName: 'clock',
        requiredCount: 1,
      ),
      Achievement(
        id: 'persistence',
        title: 'Persistence',
        description: 'Complete a level after 5 resets',
        iconName: 'reset',
        requiredCount: 1,
      ),
    ];
    
    await _saveData();
  }
  
  /// Update statistics when a level is completed
  Future<void> onLevelComplete(int level, int moves, int optimalMoves, Duration levelTime) async {
    _statistics.totalLevelsCompleted++;
    _statistics.totalGamesPlayed++;
    _statistics.currentStreak++;
    
    // Update longest streak if needed
    if (_statistics.currentStreak > _statistics.longestStreak) {
      _statistics.longestStreak = _statistics.currentStreak;
    }
    
    // Check if it was a perfect completion
    if (moves == optimalMoves) {
      _statistics.perfectCompletions++;
      _updateAchievementProgress('perfect_10', 1);
    }
    
    // Quick completion achievement
    if (levelTime.inSeconds <= 10) {
      _updateAchievementProgress('quick_thinker', 1);
    }
    
    // Level completion achievement
    _updateAchievementProgress('circuit_master', 1);
    
    await _saveData();
    _notifyAchievementListeners();
  }
  
  /// Record when the player adds a connection
  Future<void> onConnectionAdded() async {
    _statistics.totalConnections++;
    
    // First connection achievement
    _updateAchievementProgress('first_connection', 1);
    
    await _saveData();
    _notifyAchievementListeners();
  }
  
  /// Record when the player uses an undo
  Future<void> onUndo() async {
    _statistics.totalUndos++;
    await _saveData();
  }
  
  /// Record when the player resets a level
  Future<void> onReset(int resetCount) async {
    _statistics.totalResets++;
    
    // Persistence achievement
    if (resetCount >= 5) {
      _updateAchievementProgress('persistence', 1);
    }
    
    await _saveData();
    _notifyAchievementListeners();
  }
  
  /// Record when the player fails a level
  Future<void> onLevelFailed() async {
    _statistics.totalGamesPlayed++;
    _statistics.currentStreak = 0;
    await _saveData();
  }
  
  /// Update session play time
  Future<void> updatePlayTime() async {
    if (_sessionStartTime != null) {
      final now = DateTime.now();
      final sessionDuration = now.difference(_sessionStartTime!);
      _statistics.totalPlayTime += sessionDuration;
      _sessionStartTime = now;
      await _saveData();
    }
  }
  
  /// Update achievement progress
  void _updateAchievementProgress(String achievementId, int amount) {
    for (final achievement in _achievements) {
      if (achievement.id == achievementId && !achievement.unlocked) {
        achievement.progress += amount;
        
        if (achievement.progress >= achievement.requiredCount) {
          achievement.unlocked = true;
          // Play achievement sound or show notification
        }
        
        break;
      }
    }
  }
  
  /// Register listener for achievement updates
  void addAchievementListener(String id) {
    _achievementListeners.add(id);
  }
  
  /// Remove listener
  void removeAchievementListener(String id) {
    _achievementListeners.remove(id);
  }
  
  /// Notify listeners of changes
  void _notifyAchievementListeners() {
    // This would typically use a proper event system
    // For now it's just a placeholder for the implementation
  }
  
  /// Reset all statistics and achievements (for testing)
  Future<void> resetAllData() async {
    _statistics = GameStatistics();
    
    for (final achievement in _achievements) {
      achievement.unlocked = false;
      achievement.progress = 0;
    }
    
    await _saveData();
  }
}
