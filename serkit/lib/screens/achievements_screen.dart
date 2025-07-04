import 'package:flutter/material.dart';
import '../utils/statistics_manager.dart';
import '../widgets/background_grid.dart';
import '../widgets/neon_button.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StatisticsManager _statisticsManager = StatisticsManager();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const BackgroundGrid(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      NeonButton(
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFF00FFFF), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF00FFFF),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF9D4EDD).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF9D4EDD), width: 2),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    tabs: const [
                      Tab(text: 'ACHIEVEMENTS'),
                      Tab(text: 'STATISTICS'),
                    ],
                  ),
                ),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAchievementsTab(),
                      _buildStatisticsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsTab() {
    final achievements = _statisticsManager.achievements;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final isUnlocked = achievement.unlocked;
          
          return Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnlocked ? const Color(0xFF00FFFF) : Colors.grey.shade700,
                width: 2,
              ),
              boxShadow: isUnlocked ? [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ] : [],
            ),
            child: Stack(
              children: [
                // Achievement details
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        achievement.title,
                        style: TextStyle(
                          color: isUnlocked ? const Color(0xFF00FFFF) : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        achievement.description,
                        style: TextStyle(
                          color: isUnlocked ? Colors.white70 : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      // Progress
                      if (!isUnlocked) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: achievement.progress / achievement.requiredCount,
                            backgroundColor: Colors.grey.shade800,
                            color: const Color(0xFF9D4EDD),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${achievement.progress}/${achievement.requiredCount}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Icon overlay
                if (isUnlocked)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.check_circle,
                      color: const Color(0xFF00FFFF),
                      size: 20,
                    ),
                  ),
                
                // Lock overlay for locked achievements
                if (!isUnlocked)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatisticsTab() {
    final stats = _statisticsManager.statistics;
    final hours = stats.totalPlayTime.inHours;
    final minutes = stats.totalPlayTime.inMinutes % 60;
    
    final statItems = [
      {
        'icon': Icons.videogame_asset,
        'title': 'Games Played',
        'value': '${stats.totalGamesPlayed}',
      },
      {
        'icon': Icons.check_circle,
        'title': 'Levels Completed',
        'value': '${stats.totalLevelsCompleted}',
      },
      {
        'icon': Icons.bolt,
        'title': 'Connections Made',
        'value': '${stats.totalConnections}',
      },
      {
        'icon': Icons.undo,
        'title': 'Undos Used',
        'value': '${stats.totalUndos}',
      },
      {
        'icon': Icons.refresh,
        'title': 'Resets Used',
        'value': '${stats.totalResets}',
      },
      {
        'icon': Icons.star,
        'title': 'Perfect Levels',
        'value': '${stats.perfectCompletions}',
      },
      {
        'icon': Icons.timer,
        'title': 'Play Time',
        'value': '$hours h $minutes m',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Longest Streak',
        'value': '${stats.longestStreak}',
      },
      {
        'icon': Icons.flash_on,
        'title': 'Current Streak',
        'value': '${stats.currentStreak}',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: statItems.length,
        itemBuilder: (context, index) {
          final item = statItems[index];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF9D4EDD).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9D4EDD).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: const Color(0xFF9D4EDD),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Title
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                // Value
                Text(
                  item['value'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
