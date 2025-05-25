import 'package:flutter/material.dart';
import 'package:froggydoro/screens/achievement_screen.dart';
import 'package:froggydoro/screens/calendar_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0; // 0 for calendar, 1 for achievements

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onButtonTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final backgroundBlockColor =
        brightness == Brightness.dark
            ? const Color(0xFF3A4A38)
            : const Color(0xFFE4E8CD);
    final bubbleColor =
        brightness == Brightness.dark
            ? const Color(0xFF63805C)
            : const Color(0xFFC8CBB2);
    final textColor =
        brightness == Brightness.dark ? Color(0xFFB0C8AE) : Color(0xFF586F51);

    return Scaffold(
      body: Column(
        children: [
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _onButtonTapped(0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _currentIndex == 0
                                ? bubbleColor
                                : backgroundBlockColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                      ),
                      child: Text(
                        'Calendar',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _onButtonTapped(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _currentIndex == 1
                                ? bubbleColor
                                : backgroundBlockColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                      ),
                      child: Text(
                        'Achievements',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PageView content area
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const ClampingScrollPhysics(), // For smooth snapping
              children: const [CalendarScreen(), AchievementsScreen()],
            ),
          ),
        ],
      ),
    );
  }
}
