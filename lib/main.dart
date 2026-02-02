import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:film_watchlist/pages/main_navigation.dart';

import 'providers.dart';

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

// Widget principale dell'applicazione
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(customThemeProvider); // osserva il tema personalizzato

    return MaterialApp( // espone il tema a tutta l'applicazione con context
      debugShowCheckedModeBanner: false,
      title: 'Film Watchlist',
      theme: ThemeData( // tema chiaro
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.themeColor, 
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: theme.themeColor, // colore di sfondo dell'AppBar
          surfaceTintColor: theme.themeColor, // colore di superficie dell'AppBar
        ),
      ),
      darkTheme: ThemeData( // tema scuro
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.themeColor, 
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(  // usa lo stesso colore del tema personalizzato
          backgroundColor: theme.themeColor, 
          surfaceTintColor: theme.themeColor,
        ),
      ),
      themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light, // applica il tema in base alla modalità
      home: const MainNavigation(), // pagina principale con navigazione, visibile in tutte le pagine
    );
  }
}
