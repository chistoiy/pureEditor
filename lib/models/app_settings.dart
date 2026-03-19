import 'package:hive/hive.dart';

class AppSettings extends HiveObject {
  bool isDarkMode;
  ThemeModeType themeMode;
  int autoSaveInterval;
  bool autoFirstLineIndent;
  int indentChars;
  bool autoWrap;
  bool autoShowKeyboard;
  bool lockCursorDefault;
  bool markdownMode;
  int cursorSensitivity;
  bool fullScreenAdapt;
  double topPadding;
  double bottomPadding;
  double leftPadding;
  double rightPadding;
  String screenOrientation;
  bool privacyMode;
  bool appLockEnabled;
  String lockType;
  int lockDelay;
  int recycleBinRetention;
  bool autoBackup;
  int backupFrequency;
  int backupRetention;
  String lastEditedDocumentId;
  String defaultExportFormat;
  String defaultExportPath;
  String startupPage;
  bool isPro;
  double fontSize;
  double lineHeight;
  double paragraphSpacing;
  double firstLineIndent;
  bool showLineNumber;
  String paperStyle;
  String fontFamily;
  bool isBiometricEnabled;
  bool isScreenAwake;
  bool isSidebarOpen;
  bool isDetailedMode;

  AppSettings({
    this.isDarkMode = false,
    this.themeMode = ThemeModeType.system,
    this.autoSaveInterval = 3,
    this.autoFirstLineIndent = true,
    this.indentChars = 2,
    this.autoWrap = true,
    this.autoShowKeyboard = false,
    this.lockCursorDefault = false,
    this.markdownMode = false,
    this.cursorSensitivity = 2,
    this.fullScreenAdapt = true,
    this.topPadding = 0,
    this.bottomPadding = 0,
    this.leftPadding = 16,
    this.rightPadding = 16,
    this.screenOrientation = 'system',
    this.privacyMode = false,
    this.appLockEnabled = false,
    this.lockType = 'password',
    this.lockDelay = 0,
    this.recycleBinRetention = 30,
    this.autoBackup = true,
    this.backupFrequency = 24,
    this.backupRetention = 15,
    this.lastEditedDocumentId = '',
    this.defaultExportFormat = 'txt',
    this.defaultExportPath = '',
    this.startupPage = 'main',
    this.isPro = false,
    this.fontSize = 16,
    this.lineHeight = 1.5,
    this.paragraphSpacing = 8,
    this.firstLineIndent = 2,
    this.showLineNumber = false,
    this.paperStyle = 'default',
    this.fontFamily = 'default',
    this.isBiometricEnabled = false,
    this.isScreenAwake = false,
    this.isSidebarOpen = false,
    this.isDetailedMode = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'themeMode': themeMode.index,
      'autoSaveInterval': autoSaveInterval,
      'autoFirstLineIndent': autoFirstLineIndent,
      'indentChars': indentChars,
      'autoWrap': autoWrap,
      'autoShowKeyboard': autoShowKeyboard,
      'lockCursorDefault': lockCursorDefault,
      'markdownMode': markdownMode,
      'cursorSensitivity': cursorSensitivity,
      'fullScreenAdapt': fullScreenAdapt,
      'topPadding': topPadding,
      'bottomPadding': bottomPadding,
      'leftPadding': leftPadding,
      'rightPadding': rightPadding,
      'screenOrientation': screenOrientation,
      'privacyMode': privacyMode,
      'appLockEnabled': appLockEnabled,
      'lockType': lockType,
      'lockDelay': lockDelay,
      'recycleBinRetention': recycleBinRetention,
      'autoBackup': autoBackup,
      'backupFrequency': backupFrequency,
      'backupRetention': backupRetention,
      'lastEditedDocumentId': lastEditedDocumentId,
      'defaultExportFormat': defaultExportFormat,
      'defaultExportPath': defaultExportPath,
      'startupPage': startupPage,
      'isPro': isPro,
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'paragraphSpacing': paragraphSpacing,
      'firstLineIndent': firstLineIndent,
      'showLineNumber': showLineNumber,
      'paperStyle': paperStyle,
      'fontFamily': fontFamily,
      'isBiometricEnabled': isBiometricEnabled,
      'isScreenAwake': isScreenAwake,
      'isSidebarOpen': isSidebarOpen,
      'isDetailedMode': isDetailedMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      themeMode: ThemeModeType.values[json['themeMode'] ?? 0],
      autoSaveInterval: json['autoSaveInterval'] ?? 3,
      autoFirstLineIndent: json['autoFirstLineIndent'] ?? true,
      indentChars: json['indentChars'] ?? 2,
      autoWrap: json['autoWrap'] ?? true,
      autoShowKeyboard: json['autoShowKeyboard'] ?? false,
      lockCursorDefault: json['lockCursorDefault'] ?? false,
      markdownMode: json['markdownMode'] ?? false,
      cursorSensitivity: json['cursorSensitivity'] ?? 2,
      fullScreenAdapt: json['fullScreenAdapt'] ?? true,
      topPadding: (json['topPadding'] ?? 0).toDouble(),
      bottomPadding: (json['bottomPadding'] ?? 0).toDouble(),
      leftPadding: (json['leftPadding'] ?? 16).toDouble(),
      rightPadding: (json['rightPadding'] ?? 16).toDouble(),
      screenOrientation: json['screenOrientation'] ?? 'system',
      privacyMode: json['privacyMode'] ?? false,
      appLockEnabled: json['appLockEnabled'] ?? false,
      lockType: json['lockType'] ?? 'password',
      lockDelay: json['lockDelay'] ?? 0,
      recycleBinRetention: json['recycleBinRetention'] ?? 30,
      autoBackup: json['autoBackup'] ?? true,
      backupFrequency: json['backupFrequency'] ?? 24,
      backupRetention: json['backupRetention'] ?? 15,
      lastEditedDocumentId: json['lastEditedDocumentId'] ?? '',
      defaultExportFormat: json['defaultExportFormat'] ?? 'txt',
      defaultExportPath: json['defaultExportPath'] ?? '',
      startupPage: json['startupPage'] ?? 'main',
      isPro: json['isPro'] ?? false,
      fontSize: (json['fontSize'] ?? 16).toDouble(),
      lineHeight: (json['lineHeight'] ?? 1.5).toDouble(),
      paragraphSpacing: (json['paragraphSpacing'] ?? 8).toDouble(),
      firstLineIndent: (json['firstLineIndent'] ?? 2).toDouble(),
      showLineNumber: json['showLineNumber'] ?? false,
      paperStyle: json['paperStyle'] ?? 'default',
      fontFamily: json['fontFamily'] ?? 'default',
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
      isScreenAwake: json['isScreenAwake'] ?? false,
      isSidebarOpen: json['isSidebarOpen'] ?? false,
      isDetailedMode: json['isDetailedMode'] ?? false,
    );
  }

  AppSettings copyWith({
    bool? isDarkMode,
    ThemeModeType? themeMode,
    int? autoSaveInterval,
    bool? autoFirstLineIndent,
    int? indentChars,
    bool? autoWrap,
    bool? autoShowKeyboard,
    bool? lockCursorDefault,
    bool? markdownMode,
    int? cursorSensitivity,
    bool? fullScreenAdapt,
    double? topPadding,
    double? bottomPadding,
    double? leftPadding,
    double? rightPadding,
    String? screenOrientation,
    bool? privacyMode,
    bool? appLockEnabled,
    String? lockType,
    int? lockDelay,
    int? recycleBinRetention,
    bool? autoBackup,
    int? backupFrequency,
    int? backupRetention,
    String? lastEditedDocumentId,
    String? defaultExportFormat,
    String? defaultExportPath,
    String? startupPage,
    bool? isPro,
    double? fontSize,
    double? lineHeight,
    double? paragraphSpacing,
    double? firstLineIndent,
    bool? showLineNumber,
    String? paperStyle,
    String? fontFamily,
    bool? isBiometricEnabled,
    bool? isScreenAwake,
    bool? isSidebarOpen,
    bool? isDetailedMode,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeMode: themeMode ?? this.themeMode,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      autoFirstLineIndent: autoFirstLineIndent ?? this.autoFirstLineIndent,
      indentChars: indentChars ?? this.indentChars,
      autoWrap: autoWrap ?? this.autoWrap,
      autoShowKeyboard: autoShowKeyboard ?? this.autoShowKeyboard,
      lockCursorDefault: lockCursorDefault ?? this.lockCursorDefault,
      markdownMode: markdownMode ?? this.markdownMode,
      cursorSensitivity: cursorSensitivity ?? this.cursorSensitivity,
      fullScreenAdapt: fullScreenAdapt ?? this.fullScreenAdapt,
      topPadding: topPadding ?? this.topPadding,
      bottomPadding: bottomPadding ?? this.bottomPadding,
      leftPadding: leftPadding ?? this.leftPadding,
      rightPadding: rightPadding ?? this.rightPadding,
      screenOrientation: screenOrientation ?? this.screenOrientation,
      privacyMode: privacyMode ?? this.privacyMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      lockType: lockType ?? this.lockType,
      lockDelay: lockDelay ?? this.lockDelay,
      recycleBinRetention: recycleBinRetention ?? this.recycleBinRetention,
      autoBackup: autoBackup ?? this.autoBackup,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      backupRetention: backupRetention ?? this.backupRetention,
      lastEditedDocumentId: lastEditedDocumentId ?? this.lastEditedDocumentId,
      defaultExportFormat: defaultExportFormat ?? this.defaultExportFormat,
      defaultExportPath: defaultExportPath ?? this.defaultExportPath,
      startupPage: startupPage ?? this.startupPage,
      isPro: isPro ?? this.isPro,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      firstLineIndent: firstLineIndent ?? this.firstLineIndent,
      showLineNumber: showLineNumber ?? this.showLineNumber,
      paperStyle: paperStyle ?? this.paperStyle,
      fontFamily: fontFamily ?? this.fontFamily,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isScreenAwake: isScreenAwake ?? this.isScreenAwake,
      isSidebarOpen: isSidebarOpen ?? this.isSidebarOpen,
      isDetailedMode: isDetailedMode ?? this.isDetailedMode,
    );
  }
}

enum ThemeModeType { system, light, dark }
