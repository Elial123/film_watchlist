import 'dart:math';

import 'package:flutter/material.dart';

// Modello dati per rappresentare un tema personalizzato
class CustomThemeData {
  // Colore principale del tema
  final Color themeColor;
  final bool isDarkMode;
  
  // Costruttore
  CustomThemeData({required this.themeColor, required this.isDarkMode});
  
  // Genera un tema con un colore casuale (nel range dei colori primari di Flutter) e modalità chiara
  CustomThemeData.random() : 
    themeColor = Colors.primaries[Random().nextInt(Colors.primaries.length)],
    isDarkMode = false;

  // Copia il tema con modifiche opzionali
  CustomThemeData copyWith({Color? themeColor, bool? isDarkMode}) {
    return CustomThemeData(
      themeColor: themeColor ?? this.themeColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
