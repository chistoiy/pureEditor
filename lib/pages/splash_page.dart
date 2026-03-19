import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pure_editor/theme/app_theme.dart';
import 'package:pure_editor/providers/document_provider.dart';
import 'package:pure_editor/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await context.read<DocumentProvider>().init();
      await context.read<SettingsProvider>().init();

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      setState(() => _isInitialized = true);

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/main');
    } catch (e) {
      debugPrint('初始化失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = settingsProvider.isDarkMode;
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    size: 60,
                    color: textColor.withOpacity(0.6),
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.0, 1.0),
                  duration: 300.ms,
                ),
            const SizedBox(height: 32),
            Text(
              'Pure Edit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              '纯粹编辑器',
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.6)),
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
            const SizedBox(height: 24),
            if (!_isInitialized)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor.withOpacity(0.5),
                  ),
                ),
              )
            else
              Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.4),
                ),
              ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
