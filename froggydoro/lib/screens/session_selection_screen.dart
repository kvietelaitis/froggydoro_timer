import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:froggydoro/models/timer_object.dart';
import 'package:froggydoro/screens/time_settings_screen.dart';
import 'package:froggydoro/services/database_service.dart';

class SessionSelectionScreen extends StatefulWidget {
  final void Function(int workDuration, int breakDuration, int count)
  onSessionChanged;

  const SessionSelectionScreen({required this.onSessionChanged, super.key});

  @override
  State<SessionSelectionScreen> createState() => _SessionSelectionScreenState();
}

class _SessionSelectionScreenState extends State<SessionSelectionScreen> {
  List<TimerObject> _presets = [];
  final DatabaseService _databaseService = DatabaseService.instance;

  /// Method to initialize the state
  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  /// Method to load all presets from the database and update the state
  Future<void> _loadPresets() async {
    final allPresets = await _databaseService.getTimers();
    setState(() {
      _presets = allPresets;
    });
  }

  /// Method to select a preset and update the session
  Future<void> _selectPreset(TimerObject preset) async {
    await _databaseService.setPickedTimer(preset.id);

    widget.onSessionChanged(
      preset.workDuration,
      preset.breakDuration,
      preset.count,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  /// Method to edit a preset and navigate to the TimeSettingsScreen
  Future<void> _editPreset(TimerObject preset) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TimeSettingsScreen(
              preset: preset,
              updateTimer: (workDuration, breakDuration, count, presetName) {
                setState(() {
                  final index = _presets.indexWhere((p) => p.id == preset.id);
                  if (index != -1) {
                    _presets[index] = TimerObject(
                      id: preset.id,
                      name: presetName,
                      workDuration: workDuration,
                      breakDuration: breakDuration,
                      count: count,
                    );
                  }
                });
              },
            ),
      ),
    );
  }

  /// Method that adds a new preset and navigates to the TimeSettingsScreen
  void _addNewPreset() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TimeSettingsScreen(
              preset: TimerObject(
                id: 0,
                name: '',
                workDuration: 25,
                breakDuration: 5,
                count: 1,
              ),
              updateTimer: (workDuration, breakDuration, count, presetName) {
                setState(() {
                  final newPreset = TimerObject(
                    id: 0,
                    name: presetName,
                    workDuration: workDuration,
                    breakDuration: breakDuration,
                    count: count,
                  );

                  _databaseService
                      .addTimer(
                        newPreset.name,
                        newPreset.workDuration,
                        newPreset.breakDuration,
                        count: newPreset.count,
                      )
                      .then((id) {
                        final updatedPreset = newPreset.copyWith(id: id);

                        _presets.add(updatedPreset);

                        _loadPresets();
                      })
                      .catchError((e) {
                        log("Error inserting preset: $e");
                      });
                });
              },
            ),
      ),
    );
  }

  /// Method to show a confirmation dialog before deleting a preset
  Future<void> _showResetConfirmationDialog(
    BuildContext context,
    TimerObject preset,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        // Use different name for context
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            // Use if text might overflow
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this preset?'),
                SizedBox(height: 20),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Make reset action more prominent
              ),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                _databaseService.deleteTimer(preset.id);
                _loadPresets();
              },
            ),
          ],
        );
      },
    );
  }

  Color _getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFFABC2A9)
        : const Color(0xFF586F51);
  }

  Color _getIconColor(BuildContext context) {
    return _getTextColor(context);
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

  Color _getBorderColor() {
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundBlockColor = _getBackgroundBlockColor(context);
    final textColor = _getTextColor(context);
    final iconColor = textColor;
    final cardColor = _getCardColor(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Froggydoro',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 24,
            letterSpacing: -0.24,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          padding: const EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: 48.0,
          ),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: iconColor,
                          size: 28,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Session settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.add_box, color: iconColor, size: 28),
                    onPressed: _addNewPreset,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _presets.length,
                itemBuilder: (context, index) {
                  final preset = _presets[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        horizontal: 0,
                        vertical: -4,
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        preset.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.check_box, size: 18, color: iconColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${preset.count} times | ${preset.workDuration} min | ${preset.breakDuration} min',
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: iconColor,
                              size: 24,
                            ),
                            onPressed:
                                () => _showResetConfirmationDialog(
                                  context,
                                  preset,
                                ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_square,
                              color: iconColor,
                              size: 24,
                            ),
                            onPressed: () => _editPreset(preset),
                          ),
                        ],
                      ),
                      onTap: () => _selectPreset(preset),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
