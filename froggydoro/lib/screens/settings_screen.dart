import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:froggydoro/models/timer_object.dart';
import 'package:froggydoro/providers/theme_provider.dart';
import 'package:froggydoro/providers/froggy_theme_provider.dart';
import 'package:froggydoro/screens/session_selection_screen.dart';
import 'package:froggydoro/services/database_service.dart';
import 'package:froggydoro/services/preferences_service.dart';
import 'package:froggydoro/widgets/dialog_helper.dart';
import 'package:froggydoro/widgets/settings_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final Function(int, int, int, int, int) updateTimer;

  const SettingsScreen({required this.updateTimer, super.key});

  static Future<String> getAmbience() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedAmbience') ?? 'Bonfire';
  }

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _DropdownMenu extends StatefulWidget {
  final List<String> options;
  final String initialValue;
  final ValueChanged<String?> onChanged;

  const _DropdownMenu({
    required this.options,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _DropdownMenuState createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<_DropdownMenu> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedValue,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedValue = newValue;
          });
          widget.onChanged(newValue);
        }
      },
      items:
          widget.options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
    );
  }
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isWakeLockEnabled = false;
  TimerObject? _selectedPreset;
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _loadWakeLock();
    _loadAmbience();
    _loadSelectedPreset();
  }

  /// Loads the wake lock setting from shared preferences and updates the state.
  void _loadWakeLock() async {
    final isWakeLockEnabled = await PreferencesService.loadWakeLock();
    setState(() {
      _isWakeLockEnabled = isWakeLockEnabled;
    });
    if (_isWakeLockEnabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  /// Saves the wake lock setting to shared preferences and applies it.
  void _saveWakeLock(bool isWakeLockEnabled) async {
    await PreferencesService.saveWakeLock(isWakeLockEnabled);
    if (isWakeLockEnabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  /// Loads the selected timer preset from the database and updates the state.
  Future<void> _loadSelectedPreset() async {
    if (_selectedPreset != null) return;
    final pickedPreset = await _databaseService.getPickedTimer();
    if (mounted) {
      setState(() {
        _selectedPreset = pickedPreset;
      });
    }
  }

  Color _getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Color(0xFFB0C8AE)
        : Color(0xFF586F51);
  }

  Color _getBackgroundBlockColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Color(0xFF3A4A38)
        : Color(0xFFE4E8CD);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        padding: const EdgeInsets.only(
          top: 16,
          right: 16,
          left: 16,
          bottom: 100,
        ),
        children: [
          Text(
            'General settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
            ),
          ),
          const SizedBox(height: 10),
          buildChangeThemeSetting(),
          const SizedBox(height: 20),
          buildChangeWakelockSetting(),
          const SizedBox(height: 20),
          buildChangeTimeSetting(),
          const SizedBox(height: 20),
          buildChangeAmbienceSetting(),
          const SizedBox(height: 10),
          buildResetButton(context),
          const SizedBox(height: 20),
          buildChangeFroggyThemeSetting(),
        ],
      ),
    );
  }

  final Map<String, Map<String, dynamic>> themeOptions = {
    'Light Mode': {'value': 'light', 'icon': Icons.wb_sunny},
    'Dark Mode': {'value': 'dark', 'icon': Icons.nightlight_round},
    'Follow System': {'value': 'system', 'icon': Icons.brightness_4},
  };

  String selectedTheme = 'Follow System';

  /// Builds the UI for changing the theme mode.
  Widget buildChangeThemeSetting() {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    // Get current theme name
    String currentThemeName =
        themeOptions.entries
            .firstWhere(
              (entry) =>
                  entry.value['value'] == _getStringFromThemeMode(themeMode),
              orElse: () => themeOptions.entries.last,
            )
            .key;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        SizedBox(height: 10),
        SettingsTile(
          title: 'Theme Mode',
          subtitle: currentThemeName,
          trailingIcon: Icons.arrow_drop_down,
          onTap: () {
            _showBottomSheet(
              context: context,
              children:
                  themeOptions.entries.map((entry) {
                    return ListTile(
                      leading: Icon(entry.value['icon']),
                      title: Text(entry.key),
                      onTap: () async {
                        final newThemeMode = _getThemeModeFromString(
                          entry.value['value'],
                        );
                        await themeNotifier.setThemeMode(newThemeMode);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// Converts a string representation of the theme mode to a `ThemeMode` object.
  ThemeMode _getThemeModeFromString(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        throw ArgumentError('Invalid theme mode: $themeMode');
    }
  }

  /// Converts a `ThemeMode` object to its string representation.
  String _getStringFromThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Builds the UI for changing the timer preset.
  Widget buildChangeTimeSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timer Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        SizedBox(height: 10),
        SettingsTile(
          title: 'Session',
          subtitle:
              _selectedPreset != null
                  ? "Preset: ${_selectedPreset!.name}"
                  : "No preset selected",
          trailingIcon: Icons.arrow_forward,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SessionSelectionScreen(
                      onSessionChanged: (workDuration, breakDuration, count) {
                        widget.updateTimer(
                          workDuration,
                          0,
                          breakDuration,
                          0,
                          count,
                        );
                      },
                    ),
              ),
            );
            await _loadSelectedPreset();
          },
        ),
      ],
    );
  }

  /// Builds the UI for toggling the wake lock setting.
  Widget buildChangeWakelockSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Always on display',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _getBackgroundBlockColor(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SwitchListTile(
            title: Text(
              'Enable',
              style: TextStyle(color: _getTextColor(context)),
            ),
            value: _isWakeLockEnabled,
            onChanged: (bool value) {
              setState(() {
                _isWakeLockEnabled = value;
              });
              _saveWakeLock(value);
            },
          ),
        ),
      ],
    );
  }

  static const List<String> ambienceOptions = [
    "None",
    "Bonfire",
    "Chirping",
    "Rain",
    "River",
  ];

  /// Saves the selected ambient sound setting to shared preferences.
  Future<void> _saveAmbience(String ambience) async {
    await PreferencesService.saveAmbience(ambience);
  }

  /// Loads the ambient sound setting from shared preferences and updates the state.
  Future<void> _loadAmbience() async {
    final ambience = await PreferencesService.loadAmbience();
    setState(() {
      selectedAmbience = ambience;
    });
  }

  String selectedAmbience = 'None';

  /// Builds the UI for changing the ambient sound setting.
  Widget buildChangeAmbienceSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ambience Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        SizedBox(height: 10),
        SettingsTile(
          title: 'Ambient Sounds',
          subtitle: selectedAmbience,
          trailingIcon: Icons.arrow_drop_down,
          onTap: () {
            _showBottomSheet(
              context: context,
              children:
                  ambienceOptions.map((String value) {
                    return ListTile(
                      title: Text(value),
                      onTap: () async {
                        setState(() {
                          selectedAmbience = value;
                        });
                        await _saveAmbience(value);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// Displays a bottom sheet with the provided list of widgets.
  void _showBottomSheet({
    required BuildContext context,
    required List<Widget> children,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        );
      },
    );
  }

  // Displays Reset All Progress button
  Widget buildResetButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _getBackgroundBlockColor(context),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                TimerDialogsHelper.showResetProgressConfirmationDialog(
                  context: context,
                  onConfirmed: () async {
                    await DatabaseService.instance.clearUserProgress();

                    setState(() {
                      _selectedPreset = null;
                    });

                    widget.updateTimer(25, 0, 5, 0, 2);
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Reset All Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: _getTextColor(context),
                      ),
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

  /// Builds the UI for changing the froggy companion theme.
  Widget buildChangeFroggyThemeSetting() {
    final froggyTheme = ref.watch(froggyThemeProvider);
    final froggyThemeNotifier = ref.read(froggyThemeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Froggy Companion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
        SizedBox(height: 10),
        SettingsTile(
          title: 'Froggy Theme',
          subtitle: froggyTheme.name,
          trailingIcon: Icons.arrow_drop_down,
          onTap: () {
            _showFroggyThemeBottomSheet(context, froggyThemeNotifier);
          },
        ),
      ],
    );
  }

  /// Displays the bottom sheet for selecting the froggy companion theme.
  void _showFroggyThemeBottomSheet(
    BuildContext context,
    FroggyThemeNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Text(
                'Choose Your Froggy Companion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(context),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: FroggyThemeNotifier.availableThemes.length,
                  itemBuilder: (context, index) {
                    final theme = FroggyThemeNotifier.availableThemes[index];
                    final isSelected =
                        ref.watch(froggyThemeProvider).name == theme.name;

                    return GestureDetector(
                      onTap: () async {
                        await notifier.setFroggyTheme(theme);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getBackgroundBlockColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              isSelected
                                  ? Border.all(
                                    color: _getTextColor(context),
                                    width: 2,
                                  )
                                  : null,
                        ),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.asset(
                                theme.workImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              theme.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getTextColor(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              theme.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getTextColor(context).withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
