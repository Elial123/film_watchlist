// Providers per l'applicazione Film Watchlist

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as pathprovider;
import 'package:path/path.dart' as path;

import 'models/custom_theme_data.dart';
import 'models/custom_theme_notifier.dart';
import 'models/film.dart';
import 'models/film_list.dart';

//  costante di Flutter che ti dice se l’app sta girando sul Web invece che su Android, iOS o desktop.
import 'package:flutter/foundation.dart' show kIsWeb;

// Provider per il nome dell'applicazione
final appNameProvider = Provider((ref) {
  debugPrint('Creating appNameProvider');
  return 'Film Watchlist';
});

// Provider per il tema personalizzato, gestito da CustomThemeNotifier
final customThemeProvider =
    StateNotifierProvider<CustomThemeNotifier, CustomThemeData>((ref) {
      return CustomThemeNotifier();
    });

// Provider per la lista di film, gestita dalla classe FilmList
final filmListProvider = StateNotifierProvider<FilmList, List<Film>>((ref) {
  debugPrint('Creating filmListProvider');
  return FilmList();
});

// Provider per il conteggio dei film nella lista
final filmCountProvider = Provider<int>((ref) {
  final filmList = ref.watch(filmListProvider);
  debugPrint('Creating filmCountProvider with count ${filmList.length}');
  return filmList.length;
});

// Funzione per caricare i dati da un URL
Future<String> _loadFromUrl(String url) async {
  final response = await http.get(Uri.parse(url)); // Effettua la richiesta HTTP
  if (response.statusCode != 200) {
    debugPrint('Failed to fetch data: ${response.statusCode}');
    throw Exception('Failed to load to-do items from network');
  }
  debugPrint('Data fetched successfully: ${response.contentLength} bytes');

  return response.body;
}

// Funzione per caricare i dati da un URL con caching su file
// La cache viene salvata in un file temporaneo e ha una durata di 1 ora
// Se run su web, la cache su file viene ignorata e si carica sempre da rete
// Se run on non-web, la cache viene salvata in un file temporaneo aggiornato ogni ora
Future<String> _cachedLoadFromUrl(String url, String cacheFilename) async {
  // Cache expiration time: 1 hour
  const cacheExpirationDuration = Duration(hours: 1);

  if (kIsWeb) {
    debugPrint('Running on web platform: skipping cache check');
    return _loadFromUrl(url);
  } else {
    // Determine full cache path
    final cacheDir = await pathprovider.getTemporaryDirectory();
    final cachePath = path.join(cacheDir.path, cacheFilename);
    debugPrint('Cache path: $cachePath');

    final cacheFile = File(cachePath);
    if (await cacheFile.exists()) {
      // Check cache age
      final lastModified = await cacheFile.lastModified();
      final cacheAge = DateTime.now().difference(lastModified);

      if (cacheAge < cacheExpirationDuration) {
        debugPrint(
          'Cache hit: Loading data from cache (age: ${cacheAge.inMinutes} minutes)',
        );
        // Cache hit and still valid
        final cachedData = await cacheFile
            .readAsString(); // legge il file di cache
        return cachedData; // restituisce i dati memorizzati nella cache
      } else {
        debugPrint(
          'Cache expired (age: ${cacheAge.inMinutes} minutes), fetching fresh data',
        );
        // Cache expired, delete and fetch fresh
        await cacheFile.delete();
      }
    }

    debugPrint('Cache miss: Fetching data from network');
    // Cache miss or expired, load from network
    final freshData = await _loadFromUrl(url);
    await cacheFile.writeAsString(
      freshData,
    ); // salva i dati freschi nella cache
    return freshData;
  }
}

// Funzione per cancellare manualmente la cache
Future<void> clearFilmCache() async {
  if (!kIsWeb) {
    final cacheDir = await pathprovider.getTemporaryDirectory(); // directory temporanea
    final cachePath = path.join(cacheDir.path, 'films.json'); // percorso del file di cache
    final cacheFile = File(cachePath);    // riferimento al file di cache

    if (await cacheFile.exists()) {
      await cacheFile.delete();
      debugPrint('Cache cleared manually');
    }
  }
}

// Provider per la lista di film scaricata online, serve per aggiornare i dati
// Utilizza la funzione _cachedLoadFromUrl per il caching
// validità della cache: 1 ora
// Invalidato manualmente quando si tocca "Ricarica dati" nelle impostazioni
final onlineFilmProvider = FutureProvider<List<Film>>((ref) async {
  debugPrint('Creating onlineFilmProvider');

  // Scarica i dati JSON dal URL con caching in file films.json
  final data = await _cachedLoadFromUrl(
    'https://raw.githubusercontent.com/Elial123/repo/refs/heads/main/db.json',
    'films.json',
  );

  // Decodifica JSON in mappa
  final Map<String, dynamic> jsonMap = jsonDecode(data);

  // Estrai la lista dei film dalla mappa JSON
  final List<dynamic> jsonFilmList = jsonMap['films'];

  // Converte ogni elemento JSON in Film usando fromJson
  final List<Film> filmList = jsonFilmList.asMap().entries.map((entry) {
    final index = entry.key;
    final filmJson = entry.value as Map<String, dynamic>;
    return Film.fromJson(filmJson, index);
  }).toList();

  // Debug: stampa informazioni sul primo film
  if (filmList.isNotEmpty) {
    debugPrint("Second film parsed: ${filmList[1].titolo}");
    debugPrint("Description: ${filmList[1].descrizione.substring(0, 50)}...");
    debugPrint("Image: ${filmList[1].immagine}");
  }

  debugPrint("Parsed ${filmList.length} films");

  return filmList;
});

// Provider per gestire il filtro "mostra solo film visti"
// Valore booleano, default false
final showOnlyWatchedProvider = StateProvider<bool>((ref) => false);

// Provider per gestire il filtro "mostra solo film non visti"
// Valore booleano, default false
final showOnlyUnwatchedProvider = StateProvider<bool>((ref) => false);

// Provider per la query di ricerca
// Valore stringa, default vuoto
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider per gestire la modalità di ricerca attiva
// Valore booleano, default false
final isSearchModeProvider = StateProvider<bool>((ref) => false);

// Provider per gestire l'indice della pagina corrente nella navigazione
// Valore intero, default 0 (home page)
final navigationIndexProvider = StateProvider<int>((ref) => 0);
