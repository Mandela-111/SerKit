import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/background_grid.dart';
import '../widgets/neon_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.6;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _musicEnabled = prefs.getBool('musicEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _soundVolume = prefs.getDouble('soundVolume') ?? 0.8;
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.6;
    });
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setDouble('soundVolume', _soundVolume);
    await prefs.setDouble('musicVolume', _musicVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: Stack(
        children: [
          const BackgroundGrid(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingsSection('Audio Settings', [
                    _buildSwitchSetting(
                      'Sound Effects',
                      _soundEnabled,
                      (value) {
                        setState(() {
                          _soundEnabled = value;
                          _saveSettings();
                        });
                      },
                    ),
                    
                    if (_soundEnabled)
                      _buildSliderSetting(
                        'Sound Volume',
                        _soundVolume,
                        (value) {
                          setState(() {
                            _soundVolume = value;
                            _saveSettings();
                          });
                        },
                      ),
                    
                    _buildSwitchSetting(
                      'Background Music',
                      _musicEnabled,
                      (value) {
                        setState(() {
                          _musicEnabled = value;
                          _saveSettings();
                        });
                      },
                    ),
                    
                    if (_musicEnabled)
                      _buildSliderSetting(
                        'Music Volume',
                        _musicVolume,
                        (value) {
                          setState(() {
                            _musicVolume = value;
                            _saveSettings();
                          });
                        },
                      ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  _buildSettingsSection('Gameplay Settings', [
                    _buildSwitchSetting(
                      'Vibration Feedback',
                      _vibrationEnabled,
                      (value) {
                        setState(() {
                          _vibrationEnabled = value;
                          _saveSettings();
                        });
                      },
                    ),
                  ]),
                  
                  const Spacer(),
                  
                  Center(
                    child: Column(
                      children: [
                        NeonButton(
                          text: 'RESET PROGRESS',
                          onPressed: _showResetConfirmation,
                          width: 250,
                          color: Colors.redAccent,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        NeonButton(
                          text: 'ABOUT',
                          onPressed: _showAboutDialog,
                          width: 250,
                          color: const Color(0xFF4CC9F0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFFF),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00FFFF),
                const Color(0xFF00FFFF).withOpacity(0.1),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
  
  Widget _buildSwitchSetting(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF00FFFF).withOpacity(0.5),
            activeColor: const Color(0xFF00FFFF),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSliderSetting(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF00FFFF),
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
              thumbColor: const Color(0xFF00FFFF),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: const Color(0xFF00FFFF).withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0,
              max: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        title: const Text(
          'Reset Progress',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Color(0xFF00FFFF)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('totalLevelsCompleted', 0);
              await prefs.setInt('currentLevel', 1);
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress has been reset'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text(
              'RESET',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFF4CC9F0), width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF4CC9F0)),
            SizedBox(width: 8),
            Text(
              'About SerKit',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SerKit is a circuit connection puzzle game with cyberpunk aesthetics.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2025 SerKit',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CC9F0)),
            ),
          ),
        ],
      ),
    );
  }
}
