import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/froggy_theme_provider.dart';
import 'timer_display.dart';

class MainTimerSection extends ConsumerWidget {
  final double screenWidth;
  final double screenHeight;
  final ValueNotifier<int> secondsNotifier;
  final bool isBreakTime;
  final int currentRound;
  final int roundCountSetting;
  final String Function(int) formatTime;
  final Widget Function(BuildContext) buildButtons;
  final VoidCallback onTestDurations;

  const MainTimerSection({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.secondsNotifier,
    required this.isBreakTime,
    required this.currentRound,
    required this.roundCountSetting,
    required this.formatTime,
    required this.buildButtons,
    required this.onTestDurations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final froggyTheme = ref.watch(froggyThemeProvider);
    String roundsText = "Round $currentRound of $roundCountSetting";

    return Column(
      mainAxisAlignment:
          MainAxisAlignment.start, // Changed from start to spaceEvenly
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight * 0.05),
        Text(
          isBreakTime ? "Break Time" : "Work Time",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            fontSize: screenWidth * 0.06,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          roundsText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        SizedBox(height: screenHeight * 0.075),
        Image.asset(
          isBreakTime ? froggyTheme.breakImage : froggyTheme.workImage,
          height: screenHeight * 0.2,
          color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        ),
        SizedBox(height: screenHeight * 0.03),
        TimerDisplay(
          secondsNotifier: secondsNotifier,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.15,
          ),
          fontSize: screenWidth * 0.15,
          formatTime: formatTime,
        ),
        SizedBox(height: screenHeight * 0.02),
        buildButtons(context),
        SizedBox(height: screenHeight * 0.01),
        ElevatedButton(
          onPressed: onTestDurations,
          child: const Text('Load Test Durations'),
        ),
      ],
    );
  }
}
