import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_theme_data.dart';

// Notifier per gestire il tema personalizzato, che contiene metodi per cambiare il tema
class CustomThemeNotifier extends StateNotifier<CustomThemeData> {
  SharedPreferences? prefs; // Riferimento a SharedPreferences

  // Costruttore
  CustomThemeNotifier()
    : super(CustomThemeData(themeColor: Colors.blue, isDarkMode: false)) {
    _initPrefs();
  }

  // Inizializza SharedPreferences e carica il tema salvato in precedenza
  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    state = _loadTheme();
    debugPrint(
      'Theme loaded: isDarkMode=${state.isDarkMode}, color=${state.themeColor.value}',
    );
  }

  // Carica il tema salvato da SharedPreferences
  CustomThemeData _loadTheme() {
    if (prefs == null) {
      debugPrint('SharedPreferences not initialized yet');
      return state;
    }

    final isDarkMode = prefs!.getBool('isDarkMode'); // legge la modalità in base alla chiave
    final colorValue = prefs!.getInt('themeColorValue');

    debugPrint(
      'Reading from SharedPreferences: isDarkMode=$isDarkMode, colorValue=$colorValue',
    );

    // Crea il tema personalizzato con i valori caricati e restituiscilo
    return CustomThemeData(
      themeColor: colorValue != null ? Color(colorValue) : Colors.blue,
      isDarkMode: isDarkMode ?? false,
    );
  }

  // Salva il tema corrente in SharedPreferences
  Future<void> _saveTheme(CustomThemeData theme) async {
    if (prefs == null) {
      debugPrint('Cannot save theme: SharedPreferences not initialized');
      return;
    }

    // Salva i valori del tema
    debugPrint(
      'Saving theme: isDarkMode=${theme.isDarkMode}, color=${theme.themeColor.value}',
    );
    final savedDark = await prefs!.setBool('isDarkMode', theme.isDarkMode);
    final savedColor = await prefs!.setInt(
      'themeColorValue',
      theme.themeColor.value,
    );
    debugPrint('Save result: isDarkMode=$savedDark, themeColor=$savedColor');
  }

  // Cambia la modalità tra chiara e scura
  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    await _saveTheme(state);
  }

  // Cambia il colore del tema in modo casuale
  Future<void> randomizeColor() async {
    state = state.copyWith(themeColor: CustomThemeData.random().themeColor);
    await _saveTheme(state);
  }
}
