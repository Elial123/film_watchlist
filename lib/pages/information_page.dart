import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

// Pagina delle informazioni sull'applicazione
class InformationPage extends ConsumerWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmList = ref.watch(filmListProvider);
    final filmCount = filmList.length;
    final vistiCount = filmList.where((film) => film.visto).length;
    final daVedereCount = filmCount - vistiCount;

    final theme = Theme.of(context);
    // Quando non specifichi backgroundColor nell'AppBar, 
    // Flutter prende automaticamente il colore dal tema globale dell'app.
    // Usa themeColor del customThemeProvider per coerenza con il tema attuale.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informazioni Watchlist'),
      ),
      body: SingleChildScrollView( // rende la pagina scrollabile
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(theme: theme), // intestazione della pagina
            const SizedBox(height: 32),

            _StatisticsSection( // sezione delle statistiche contentente filmCount, vistiCount, daVedereCount
              filmCount: filmCount,
              vistiCount: vistiCount,
              daVedereCount: daVedereCount,
            ),

            const SizedBox(height: 32),

            _InfoSection( // sezione che spiega cos'è l'app ("Cos'è questa app?")
              title: 'Cos\'è questa app?',
              icon: Icons.info_outline,
              content:
                  'Questa applicazione ti permette di gestire la tua watchlist di film. '
                  'Puoi visualizzare film, segnarli come visti o da vedere, e tenere traccia '
                  'della tua collezione personale di cinema.',
            ),

            const SizedBox(height: 24),

            _InfoSection( // sezione che spiega le funzionalità ("Funzionalità")
              title: 'Funzionalità',
              icon: Icons.star_outline,
              content: '',
              children: const [ // elenco delle funzionalità
                _FeatureItem(
                  icon: Icons.view_list,
                  title: 'Visualizzazione Responsive',
                  description:
                      'Layout adattivo che cambia da lista a griglia in base alle dimensioni dello schermo',
                ),
                _FeatureItem(
                  icon: Icons.check_circle_outline,
                  title: 'Segna come Visto',
                  description: 'Tieni traccia dei film che hai già visto',
                ),
                _FeatureItem(
                  icon: Icons.palette_outlined,
                  title: 'Temi Personalizzabili',
                  description: 'Cambia il tema dell\'app con un semplice tocco',
                ),
                _FeatureItem(
                  icon: Icons.cloud_outlined,
                  title: 'Sincronizzazione Online',
                  description: 'I film vengono caricati da un servizio online',
                ),
              ],
            ),

            const SizedBox(height: 32),
            // sezione che mostra la distribuzione per genere ("Distribuzione per Genere")
            if (filmList.isNotEmpty) ...[
              _GenreDistribution(films: filmList),
              const SizedBox(height: 32),
            ],
            // sezione che mostra la versione dell'app ("Versione")
            Center(
              child: Text(
                'Versione 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget per l'intestazione della pagina dentro InformationPage
class _Header extends StatelessWidget {
  final ThemeData theme;

  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.movie_filter, size: 80, color: theme.colorScheme.primary), // icona grande
          const SizedBox(height: 16),
          Text(                                                                 // titolo principale
            'Film Watchlist',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(                                                                 // sottotitolo
            'La tua collezione personale di film',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Sezione delle statistiche dei film dentro InformationPage
class _StatisticsSection extends StatelessWidget {
  final int filmCount;
  final int vistiCount;
  final int daVedereCount;

  const _StatisticsSection({
    required this.filmCount,
    required this.vistiCount,
    required this.daVedereCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard( // card per film totali
            icon: Icons.movie,
            label: 'Film Totali',
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _StatCard( // card per film visti
            icon: Icons.check_circle,
            label: 'Visti',
            color: Colors.green,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _StatCard( // card per film da vedere
            icon: Icons.pending,
            label: 'Da Vedere',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

// Card per visualizzare una statistica specifica dentro la sezione delle statistiche
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final filmList = ref.watch(filmListProvider);
                final value = switch (label) {
                  'Film Totali' => filmList.length,
                  'Visti' => filmList.where((f) => f.visto).length,
                  _ => filmList.length - filmList.where((f) => f.visto).length,
                };
                return Text(
                  '$value',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Sezione informativa generica dentro InformationPage
class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final List<Widget>? children;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.content,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (content.isNotEmpty)
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        if (children != null) ...children!,
      ],
    );
  }
}

// Item che descrive una funzionalità dell'app dentro _InfoSection
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1), // sfondo leggero
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24), // icona della funzionalità dentro un cerchio
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // titolo della funzionalità
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600], // descrizione della funzionalità
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sezione che mostra la distribuzione dei film per genere dentro InformationPage
class _GenreDistribution extends StatelessWidget {
  final List films;

  // costruttore
  const _GenreDistribution({required this.films});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // conta i film per genere
    final genreCount = <String, int>{};
    for (final film in films) {
      genreCount[film.genere] = (genreCount[film.genere] ?? 0) + 1;
    }
    // ordina i generi per numero di film e salva in una lista
    final sortedGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // costruisce la UI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [ // intestazione della sezione
            Icon(Icons.category, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Distribuzione per Genere',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...sortedGenres.map((entry) { // per ogni genere costruisce una riga
          final percentage =
              (entry.value / films.length * 100).toStringAsFixed(0);
          
          // ritorna il widget per ogni genere con il suo conteggio e la barra di progresso
          return Padding( // padding tra le righe
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row( // riga con nome genere e numero film
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      '${entry.value} film ($percentage%)',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                // barra di progresso che mostra la percentuale
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: entry.value / films.length,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
