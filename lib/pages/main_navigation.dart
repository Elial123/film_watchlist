import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'information_page.dart';

// Widget principale con Bottom Navigation Bar
class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    // Lista delle pagine
    final pages = [
      const HomePage(),
      const SettingsPage(),
      const InformationPage(),
    ];

    return Scaffold(
      body: IndexedStack( // Mantiene lo stato interno di ogni pagina (tutte create e tutte presenti nella UI)
                          // renede visibile solo la pagina corrente, le altre sono nascoste
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) { // Quando l'utente aggiorna l'indice selezionato, il widget si ricostruisce automaticamente
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Informazioni',
          ),
        ],
      ),
    );
  }
}
