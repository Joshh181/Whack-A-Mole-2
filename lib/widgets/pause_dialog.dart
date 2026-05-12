import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../config/app_colors.dart';
import '../services/audio_service.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key});
// pause dialog
  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _PauseButton(
              label: 'RESUME',
              color: AppColors.resumeYellow,
              onPressed: () {
                audioService.playButtonClick();
                Navigator.pop(context);
                Provider.of<GameProvider>(context, listen: false).resumeGame();
                audioService.resumeBackgroundMusic();
              },
            ),
            const SizedBox(height: 12),
            _PauseButton(
              label: 'RESTART',
              color: AppColors.restartGreen,
              onPressed: () {
                audioService.playButtonClick();
                Navigator.pop(context);
                Provider.of<GameProvider>(context, listen: false).restartGame();
                audioService.playBackgroundMusic();
              },
            ),
            const SizedBox(height: 12),
            _PauseButton(
              label: 'HOME',
              color: AppColors.homeBlue,
              onPressed: () {
                audioService.playButtonClick();
                audioService.stopBackgroundMusic();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return _PauseButton(
                  label: 'Sound: ${settings.soundEffects ? "ON" : "OFF"}',
                  color: AppColors.soundRed,
                  onPressed: () => settings.toggleSoundEffects(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
//  pause button
class _PauseButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _PauseButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}