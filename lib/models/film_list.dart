import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:film_watchlist/models/film.dart';

class FilmList extends StateNotifier<List<Film>> {
  // Riferimento a SharedPreferences per la persistenza dello stato "visto"
  SharedPreferences? _prefs;
  // Chiave per salvare gli ID dei film visti in SharedPreferences
  static const String _watchedFilmsKey = 'watched_films';
  // Chiave per salvare le valutazioni dei film in SharedPreferences in baswe a id:rating
  static const String _filmRatingsKey = 'film_ratings';
  
  // Costruttore
  FilmList() : super([]) { // Chiama il costruttore della classe genitore StateNotifier<List<Film>> passando una lista vuota [] come stato iniziale.
    _initPrefs();
  }
  
  // Inizializza SharedPreferences, ovvero il sistema di archiviazione locale
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance(); // ottieni l'istanza di SharedPreferences
    debugPrint('FilmList: SharedPreferences initialized');
  }

  // Carica gli ID dei film visti da SharedPreferences
  Set<String> _loadWatchedFilmIds() {
    if (_prefs == null) return {}; // se non inizializzato, ritorna insieme vuoto
    // altrimenti, carica la lista degli ID salvati
    final watchedIds = _prefs!.getStringList(_watchedFilmsKey) ?? [];
    debugPrint('Loaded ${watchedIds.length} watched film IDs from storage');
    return watchedIds.toSet();
  }

  // Salva gli ID dei film visti in SharedPreferences
  Future<void> _saveWatchedFilmIds() async {
    if (_prefs == null) { // se non inizializzato, non fare nulla
      debugPrint('Cannot save watched films: SharedPreferences not initialized');
      return;
    }
    // altrimenti, salva gli ID dei film visti
    final watchedIds = state.where((film) => film.visto).map((film) => film.id).toList();
    await _prefs!.setStringList(_watchedFilmsKey, watchedIds); 
    debugPrint('Saved ${watchedIds.length} watched film IDs to storage');
  }

  // Carica le valutazioni dei film da SharedPreferences
  Map<String, int> _loadFilmRatings() {
    if (_prefs == null) return {}; // se non inizializzato, ritorna mappa vuota
    final ratingsString = _prefs!.getString(_filmRatingsKey); // carica la stringa salvata
    if (ratingsString == null) return {}; // se nulla, ritorna mappa vuota
    
    try {
      // Converte la stringa JSON in una mappa di valutazioni
      final Map<String, dynamic> decoded = {}; // id: rating
      final pairs = ratingsString.split(','); // separa ogni coppia id:rating
      for (final pair in pairs) {            // per ogni coppia id:rating
        if (pair.isEmpty) continue;         // salta se vuota
        final parts = pair.split(':');     // separa id e rating
        if (parts.length == 2) {          // se ha esattamente due parti
          decoded[parts[0]] = int.parse(parts[1]); // aggiungi alla mappa
        }
      }
      return decoded.cast<String, int>(); // converte la mappa dinamica in mappa stringa-int
    } catch (e) {
      debugPrint('Error loading film ratings: $e');
      return {};
    }
  }

  // Salva le valutazioni dei film in SharedPreferences
  Future<void> _saveFilmRatings() async {
    if (_prefs == null) {
      debugPrint('Cannot save film ratings: SharedPreferences not initialized');
      return;
    }
    
    // Crea una stringa con tutte le valutazioni in formato id:rating separate da virgola
    final ratings = state.where((film) => film.valutazione > 0)
        .map((film) => '${film.id}:${film.valutazione}')
        .join(',');
    
    await _prefs!.setString(_filmRatingsKey, ratings); // salva la stringa in base alla chiave
    debugPrint('Saved film ratings to storage');
  }

  // Imposta la lista di film, caricando lo stato "visto" da SharedPreferences
  void setFilms(List<Film> films) {
    final watchedIds = _loadWatchedFilmIds();
    final ratings = _loadFilmRatings();
    
    // Debug: stampa informazioni sui film ricevuti
    debugPrint('setFilms called with ${films.length} films');
    if (films.isNotEmpty) {
      debugPrint('First film: ${films[0].titolo} - ${films[0].descrizione.substring(0, 50)}...');
    }
    
    // Aggiorna la lista di film, applicando lo stato "visto" salvato
    state = [
      for (final film in films)
        if (watchedIds.contains(film.id) || ratings.containsKey(film.id))
          film.copyAsWatched(watchedIds.contains(film.id))
              .copyWithRating(ratings[film.id] ?? 0)
        else
          film,
    ];
    
    // Debug: verifica che la lista sia stata aggiornata
    if (state.isNotEmpty) {
      debugPrint('State updated: ${state[0].titolo} - ${state[0].descrizione.substring(0, 50)}...');
    }
    
    debugPrint('Set ${films.length} films, ${watchedIds.length} marked as watched');
  }
  
    // metodo per invertire lo stato visto di un film
    void toggleFilmWatched(String id) {
      final newItems = [ // crea una nuova lista di film con lo stato aggiornato
        for (final item in state)
          if (item.id == id) 
            item.copyAsWatched(!item.visto) 
          else 
            item,
      ];
  
      state = newItems; // aggiorna lo stato 
      _saveWatchedFilmIds(); // aggiorna lista id salvati
    }
    
    // Metodo per aggiornare la valutazione di un film
    void updateFilmRating(String id, int rating) {
      final newItems = [
        for (final item in state)
          if (item.id == id)
            item.copyWithRating(rating) 
          else 
            item,
      ];
      
      state = newItems;
      _saveFilmRatings(); // salva le valutazioni
    }
  }