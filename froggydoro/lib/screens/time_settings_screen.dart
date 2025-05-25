import '../models/timer_object.dart';
import '../services/database_service.dart';
import '../widgets/time_step.dart';
import 'package:flutter/material.dart';

class TimeSettingsScreen extends StatefulWidget {
  final TimerObject preset;
  final Function(
    int workDuration,
    int breakDuration,
    int count,
    String presetName,
  )
  updateTimer;

  const TimeSettingsScreen({
    required this.preset,
    required this.updateTimer,
    super.key,
  });

  @override
  _TimeSettingsScreenState createState() => _TimeSettingsScreenState();
}

class _TimeSettingsScreenState extends State<TimeSettingsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;

  late TextEditingController _nameController;
  late int _workDuration;
  late int _breakDuration;
  late int _count;

  // Initializes the state with the preset values
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.preset.name);
    _workDuration = widget.preset.workDuration;
    _breakDuration = widget.preset.breakDuration;
    _count = widget.preset.count;
  }

  // Saves the changes made to the timer preset
  Future<void> _saveChanges() async {
    // Updates the preset in the database
    await _databaseService.updateTimer(
      widget.preset.id,
      _nameController.text,
      _workDuration,
      _breakDuration,
      count: _count,
    );

    // Updates the timer preset values after saving in the database
    widget.updateTimer(
      _workDuration,
      _breakDuration,
      _count,
      _nameController.text,
    );

    // Pops the screen to return to the previous screen
    Navigator.pop(context);
  }

  Color _getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFFABC2A9)
        : const Color(0xFF586F51);
    //? Colors.white
    //: Colors.black;
  }

  Color _getBackgroundBlockColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF3A4A38)
        : const Color(0xFFE4E8CD);
  }

  Color _getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF586F51)
        : Theme.of(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundBlockColor = _getBackgroundBlockColor(context);
    final textColor = _getTextColor(context);
    final cardColor = _getCardColor(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 40),

          // Froggydoro title (outside the background block)
          Center(
            child: Text(
              "Froggydoro",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor.withOpacity(0.85),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Background block container
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.92,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: backgroundBlockColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back arrow + Edit Session
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: textColor,
                            size: 28,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Edit Session",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Preset Name (slightly bigger)
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Name:",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              child: TextField(
                                controller: _nameController,
                                textAlign: TextAlign.right,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter name",
                                  hintStyle: TextStyle(
                                    color: textColor.withOpacity(0.85),
                                  ),
                                ),
                                style: TextStyle(
                                  color: textColor.withOpacity(0.85),
                                ),
                                cursorColor: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Work Duration
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TimeStep(
                        label: "Work Duration",
                        value: _workDuration,
                        unit: "min",
                        onIncrement: addWorkTime,
                        onDecrement: subtractWorkTime,
                      ),
                    ),

                    // Break Duration
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TimeStep(
                        label: "Break Duration",
                        value: _breakDuration,
                        unit: "min",
                        onIncrement: addBreakTime,
                        onDecrement: subtractBreakTime,
                      ),
                    ),

                    // Round Count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TimeStep(
                        label: "Round Count",
                        value: _count,
                        unit: "rounds",
                        onIncrement: addRound,
                        onDecrement: subtractRound,
                      ),
                    ),

                    const Spacer(),

                    // Save Button
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cardColor,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            "Save",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor.withOpacity(0.85),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Increments work time by 5 minutes, up to a maximum of 60 minutes
  void addWorkTime() {
    setState(() {
      if (_workDuration < 60) {
        _workDuration += 5;
      }
    });
  }

  // Decrements work time by 5 minutes, down to a minimum of 5 minutes
  void subtractWorkTime() {
    setState(() {
      if (_workDuration > 5) {
        _workDuration -= 5;
      }
    });
  }

  // Increments break time by 5 minutes, up to a maximum of 30 minutes
  void addBreakTime() {
    setState(() {
      if (_breakDuration < 30) {
        _breakDuration += 5;
      }
    });
  }

  // Decrements break time by 5 minutes, down to a minimum of 5 minutes
  void subtractBreakTime() {
    setState(() {
      if (_breakDuration > 5) {
        _breakDuration -= 5;
      }
    });
  }

  // Increments round count by 1, up to a maximum of 10 rounds
  void addRound() {
    setState(() {
      if (_count < 10) {
        _count += 1;
      }
    });
  }

  // Decrements round count by 1, down to a minimum of 1 round
  void subtractRound() {
    setState(() {
      if (_count > 1) {
        _count -= 1;
      }
    });
  }
}
