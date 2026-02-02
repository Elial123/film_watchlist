import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

// Pagina delle impostazioni, dove l'utente può modificare le preferenze dell'app
class SettingsPage extends ConsumerWidget { // usa ConsumerWidget per accedere ai provider tramite strumento ref
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Osserviamo i provider necessari, il widfget si ricostruirà al loro cambiamento
    final theme = ref.watch(customThemeProvider);
    final showOnlyWatched = ref.watch(showOnlyWatchedProvider);
    final showOnlyUnwatched = ref.watch(showOnlyUnwatchedProvider);
    final appName = ref.watch(appNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        children: [
          // Sezione Tema
          _SectionHeader(title: 'Aspetto'),
          SwitchListTile( // switch per attivare/disattivare la modalità scura
            title: const Text('Modalità scura'),
            subtitle: Text(
              theme.isDarkMode ? 'Tema scuro attivo' : 'Tema chiaro attivo',
            ),
            secondary: Icon(theme.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: theme.isDarkMode,
            onChanged: (value) {
              ref.read(customThemeProvider.notifier).toggleDarkMode();
            },
          ),
          ListTile( // cambia il colore del tema
            title: const Text('Colore tema'),
            subtitle: const Text('Cambia il colore principale dell\'app'),
            leading: CircleAvatar(
              backgroundColor: theme.themeColor,
              radius: 16,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ref.read(customThemeProvider.notifier).randomizeColor();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Colore tema aggiornato!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const Divider(), // separatore visivo

          // Sezione Filtri
          _SectionHeader(title: 'Filtri'),
          SwitchListTile(
            title: const Text('Mostra solo film visti'),
            subtitle: Text(
              showOnlyWatched
                  ? 'Visualizzando solo i film già visti'
                  : 'Visualizzando tutti i film',
            ),
            secondary: Icon(
              showOnlyWatched ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            value: showOnlyWatched,
            onChanged: (value) {
              ref.read(showOnlyWatchedProvider.notifier).state = value;
              // Se attivo questo filtro, disattivo l'altro
              if (value) {
                ref.read(showOnlyUnwatchedProvider.notifier).state = false;
              }
            },
          ),
          SwitchListTile(
            title: const Text('Mostra solo film non visti'),
            subtitle: Text(
              showOnlyUnwatched
                  ? 'Visualizzando solo i film da vedere'
                  : 'Visualizzando tutti i film',
            ),
            secondary: Icon(
              showOnlyUnwatched ? Icons.visibility_off : Icons.visibility_off_outlined,
            ),
            value: showOnlyUnwatched,
            onChanged: (value) {
              ref.read(showOnlyUnwatchedProvider.notifier).state = value;
              // Se attivo questo filtro, disattivo l'altro
              if (value) {
                ref.read(showOnlyWatchedProvider.notifier).state = false;
              }
            },
          ),
          const Divider(),

          // Sezione App
          _SectionHeader(title: 'Applicazione'),
          ListTile(
            title: const Text('Nome app'),
            subtitle: Text(appName),
            leading: const Icon(Icons.label_outline),
          ),
          ListTile(
            title: const Text('Versione'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
          ListTile(
            title: const Text('Ricarica dati'),
            subtitle: const Text('Aggiorna la lista dei film dal server'),
            leading: const Icon(Icons.refresh),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              // Cancella la cache
              await clearFilmCache();
              // Forza il ricaricamento dei dati
              ref.invalidate(onlineFilmProvider);
              // Attendi che i nuovi dati siano caricati
              await ref.read(onlineFilmProvider.future).then((films) {
                // Aggiorna la lista locale con i nuovi film
                ref.read(filmListProvider.notifier).setFilms(films);
              });
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dati ricaricati!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// Widget per l'intestazione delle sezioni
// usato per separare visivamente le tre sezioni nelle impostazioni (Aspetto, Filtri, Applicazione)
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
