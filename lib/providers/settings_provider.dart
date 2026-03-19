import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();
  Box<dynamic>? _settingsBox;
  bool _isInitialized = false;

  AppSettings get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  bool get isPro => _settings.isPro;
  bool get isInitialized => _isInitialized;
  ThemeMode get themeMode => _getThemeMode();

  ThemeMode _getThemeMode() {
    switch (_settings.themeMode) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      case ThemeModeType.system:
        return ThemeMode.system;
    }
  }

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
    final savedSettings = _settingsBox?.get('app_settings');
    if (savedSettings != null) {
      _settings = AppSettings.fromJson(
        Map<String, dynamic>.from(savedSettings),
      );
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await _settingsBox?.put('app_settings', _settings.toJson());
  }

  Future<void> toggleTheme() async {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _settings = _settings.copyWith(isDarkMode: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeType mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setAutoSaveInterval(int seconds) async {
    _settings = _settings.copyWith(autoSaveInterval: seconds);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDefaultExportFormat(String format) async {
    _settings = _settings.copyWith(defaultExportFormat: format);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDefaultExportPath(String path) async {
    _settings = _settings.copyWith(defaultExportPath: path);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setStartupPage(String page) async {
    _settings = _settings.copyWith(startupPage: page);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _settings = _settings.copyWith(fontSize: size);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLineHeight(double height) async {
    _settings = _settings.copyWith(lineHeight: height);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setParagraphSpacing(double spacing) async {
    _settings = _settings.copyWith(paragraphSpacing: spacing);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setFirstLineIndent(double indent) async {
    _settings = _settings.copyWith(firstLineIndent: indent);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setShowLineNumber(bool show) async {
    _settings = _settings.copyWith(showLineNumber: show);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setPaperStyle(String style) async {
    _settings = _settings.copyWith(paperStyle: style);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setFontFamily(String family) async {
    _settings = _settings.copyWith(fontFamily: family);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    _settings = _settings.copyWith(appLockEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _settings = _settings.copyWith(isBiometricEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLastEditedDocumentId(String id) async {
    _settings = _settings.copyWith(lastEditedDocumentId: id);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setPro(bool value) async {
    _settings = _settings.copyWith(isPro: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setScreenAwake(bool value) async {
    _settings = _settings.copyWith(isScreenAwake: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSidebarOpen(bool value) async {
    _settings = _settings.copyWith(isSidebarOpen: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDetailedMode(bool value) async {
    _settings = _settings.copyWith(isDetailedMode: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setAutoFirstLineIndent(bool value) async {
    _settings = _settings.copyWith(autoFirstLineIndent: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setAutoWrap(bool value) async {
    _settings = _settings.copyWith(autoWrap: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setAutoShowKeyboard(bool value) async {
    _settings = _settings.copyWith(autoShowKeyboard: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLockCursorDefault(bool value) async {
    _settings = _settings.copyWith(lockCursorDefault: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setMarkdownMode(bool value) async {
    _settings = _settings.copyWith(markdownMode: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setFullScreenAdapt(bool value) async {
    _settings = _settings.copyWith(fullScreenAdapt: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setPrivacyMode(bool value) async {
    _settings = _settings.copyWith(privacyMode: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setAutoBackup(bool value) async {
    _settings = _settings.copyWith(autoBackup: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setBackupFrequency(int value) async {
    _settings = _settings.copyWith(backupFrequency: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setBackupRetention(int value) async {
    _settings = _settings.copyWith(backupRetention: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setRecycleBinRetention(int value) async {
    _settings = _settings.copyWith(recycleBinRetention: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLockDelay(int value) async {
    _settings = _settings.copyWith(lockDelay: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setCursorSensitivity(int value) async {
    _settings = _settings.copyWith(cursorSensitivity: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setScreenOrientation(String value) async {
    _settings = _settings.copyWith(screenOrientation: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }
}
