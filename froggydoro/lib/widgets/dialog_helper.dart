import 'package:flutter/material.dart';
import 'achievement_popup.dart';

/// A helper class for displaying various timer-related dialogs and popups.
class TimerDialogsHelper {
  static void showSessionCompletePopup({
    required BuildContext context,
    required String messageTitle,
    required String messageBody,
    required VoidCallback onStartPressed,
    bool showStart = true,
    bool showPause = true,
    bool showReset = false,
  }) {
    // Dynamically set colors based on current theme (dark/light)
    final brightness = Theme.of(context).brightness;
    final backgroundColor =
        brightness == Brightness.dark
            ? const Color(0xFF3F5738)
            : const Color(0xFFF1F3E5);
    final buttonColor =
        brightness == Brightness.dark
            ? const Color(0xFFB0C8AE)
            : const Color(0xFF586F51);
    final textColor =
        brightness == Brightness.dark ? Colors.black : Colors.white;
    // Show the popup as a modal bottom sheet
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return SafeArea(
          child: Container(
            width: screenWidth,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  messageTitle,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  messageBody,
                  style: const TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showStart)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: textColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onStartPressed();
                        },
                        child: const Text('Start'),
                      ),
                    if (showPause) ...[
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: textColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Pause'),
                      ),
                    ],
                    if (showReset) ...[
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: textColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onStartPressed();
                        },
                        child: const Text('Okay'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Displays a confirmation dialog when the user attempts to reset the timer.
  static Future<void> showResetConfirmationDialog({
    required BuildContext context,
    required VoidCallback onConfirmed,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to reset the timer?'),
                SizedBox(height: 10),
                Text(
                  'This will clear the current progress and return to the start of the first work session.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirmed();
              },
            ),
          ],
        );
      },
    );
  }

  /// Displays a confirmation dialog when the user attempts to reset the progress.
  static Future<void> showResetProgressConfirmationDialog({
    required BuildContext context,
    required VoidCallback onConfirmed,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Reset Progress'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to reset the progress?'),
                SizedBox(height: 10),
                Text(
                  'This will reset all the progress (achievements, presets, calendar).',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirmed();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show an achievement unlocked popup with animation
  static void showAchievementDialog(
    BuildContext context,
    String achievementName,
    String description,
    String iconPath, {
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: AchievementPopup(
              achievementName: achievementName,
              description: description,
              iconPath: iconPath,
              onClose: () {
                Navigator.of(context).pop();
                onClose?.call();
              },
            ),
          ),
    );
  }
}
