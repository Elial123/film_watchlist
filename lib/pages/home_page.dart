import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:film_watchlist/widgets/films_count_widget.dart';

import '../models/film.dart';
import '../providers.dart';
import '../widgets/films_viewer.dart';

// Home page dell'applicazione
class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
  }); // costruttore con chiave opzionale fornita dal genitore

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Osserviamo il provider che fornisce la lista dei film online
    final filmsAsyncValue = ref.watch(onlineFilmProvider);
    // Osserviamo il filtro "mostra solo i film visti"
    final showOnlyWatched = ref.watch(showOnlyWatchedProvider);
    // Osserviamo il filtro "mostra solo i film non visti"
    final showOnlyUnwatched = ref.watch(showOnlyUnwatchedProvider);
    // Osserviamo la lista locale dei film
    final localFilmList = ref.watch(filmListProvider);
    // Osserviamo la query di ricerca
    final searchQuery = ref.watch(searchQueryProvider);
    // Osserviamo la modalità di ricerca
    final isSearchMode = ref.watch(isSearchModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: isSearchMode
            ? TextField(
                autofocus: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Cerca film in base a titolo, genere, descrizione...',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              )
            : Text(ref.watch(appNameProvider)), // mostra il nome dell'app quando non è attiva la modalità di ricerca
        actions: [
          IconButton(
            icon: Icon(isSearchMode ? Icons.close : Icons.search),
            onPressed: () {
              if (isSearchMode) {
                // Chiudi la modalità di ricerca e cancella la query
                ref.read(isSearchModeProvider.notifier).state = false;
                ref.read(searchQueryProvider.notifier).state = '';
              } else {
                // Apri la modalità di ricerca
                ref.read(isSearchModeProvider.notifier).state = true;
              }
            },
          ),
        ],
      ),
      body: Padding(
        // widget con padding intorno al contenuto
        padding: const EdgeInsets.all(
          10,
        ), // 10 pixel di padding su tutti i lati
        child: SafeArea(
          // evita le aree non sicure del dispositivo
          minimum: EdgeInsets.all(10),
          child: filmsAsyncValue.when(
            data: (films) {
              // Sincronizza la lista locale con quella online
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // esegue il codice dopo build del widget
                // Controlla se i film online sono diversi da quelli locali
                if (films.isNotEmpty &&
                    (localFilmList.isEmpty ||
                        (!_filmsAreEqual(films, localFilmList)))) {
                  ref
                      .read(filmListProvider.notifier)
                      .setFilms(films); // aggiorna la lista locale
                }
              });

              // Filtra i film in base alla ricerca e all'opzione "solo film visti"
              var filteredFilms = localFilmList;

              // Applica il filtro di ricerca
              if (searchQuery.trim().isNotEmpty) {
                final query = searchQuery.toLowerCase();
                filteredFilms = filteredFilms.where((film) {
                  // filtro di ricerca
                  return film.titolo.toLowerCase().contains(query) ||
                      film.genere.toLowerCase().contains(query) ||
                      film.descrizione.toLowerCase().contains(query);
                }).toList();
              }

              // Applica il filtro "solo film visti"
              if (showOnlyWatched) {
                filteredFilms = filteredFilms
                    .where((film) => film.visto)
                    .toList();
              }
              
              // Applica il filtro "solo film non visti"
              if (showOnlyUnwatched) {
                filteredFilms = filteredFilms
                    .where((film) => !film.visto)
                    .toList();
              }

              return Column(
                // mostra la lista dei film e il conteggio
                children: [
                  Expanded(
                    child: _FilmListContent(films: filteredFilms),
                  ), // film elencati
                  const SizedBox(height: 20), // spazio tra lista e conteggio
                  FilmsCountWidget(), // widget per il conteggio dei film
                ],
              );
            }, // data
            // in caso di caricamento, mostra un indicatore di progresso
            loading: () => Center(
              child: CircularProgressIndicator(),
            ), // animazione di caricamento
            error: (error, stack) => Center(
              // mostra un messaggio di errore
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Errore nel caricamento dei film'),
                  SizedBox(height: 8),
                  Text('$error', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(onlineFilmProvider);
                    },
                    child: Text('Riprova'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Contenuto della lista dei film, adattivo in base alla larghezza disponibile
// Se lo schermo è stretto, mostra una lista verticale
// Se lo schermo è largo, mostra una griglia con più colonne
// Riceve la lista dei film da mostrare come parametro
// (già filtrata in base alla ricerca e ai filtri) e la visualizza di conseguenza
class _FilmListContent extends ConsumerWidget {
  final List films;

  const _FilmListContent({required this.films});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // layout adattivo in base alla larghezza disponibile
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          // nel caso di schermi stretti, mostra una lista verticale
          return ListView.separated(
            itemCount: films.length,
            itemBuilder: (context, index) {
              return FilmViewer(
                films[index],
                key: ValueKey(films[index].id),
              ); // widget per mostrare i dettagli del film
            },
            separatorBuilder: (context, index) => SizedBox(height: 20),
          );
        } else {
          // Layout per schermi più grandi, mostrando una griglia con due o più colonne
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // Numero di colonne adattivo
              crossAxisCount:
                  constraints.maxWidth ~/
                  320, // ogni colonna ha una larghezza minima di 320 pixel
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              mainAxisExtent: 180,
            ),
            itemCount: films.length,
            itemBuilder: (context, index) {
              return FilmViewer(films[index], key: ValueKey(films[index].id));
            },
          );
        }
      },
    );
  }
}

// Funzione helper per confrontare due liste di film (ignorando lo stato "visto")
bool _filmsAreEqual(List<Film> films1, List<Film> films2) {
  if (films1.length != films2.length)
    return false; // liste di lunghezza diversa

  for (int i = 0; i < films1.length; i++) {
    final f1 = films1[i];
    final f2 = films2[i];

    // Confronta tutti i campi tranne "visto"
    if (f1.id != f2.id ||
        f1.titolo != f2.titolo ||
        f1.anno != f2.anno ||
        f1.genere != f2.genere ||
        f1.descrizione != f2.descrizione ||
        f1.immagine != f2.immagine) {
      return false;
    }
  }

  return true;
}
