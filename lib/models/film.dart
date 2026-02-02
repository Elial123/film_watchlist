
import 'package:uuid/uuid.dart';

// Modello dati per rappresentare un film
class Film {
  final String id;
  final String titolo;
  final int anno;
  final String genere;
  final String descrizione;
  final bool visto;
  final String? immagine;
  final int valutazione; // Valutazione del film (0-5 stelle, 0 = non valutato)
  
  // Costruttore
  const Film({
    required this.id,
    required this.titolo,
    required this.anno,
    required this.genere,
    required this.descrizione,
    this.visto = false,
    this.immagine,
    this.valutazione = 0,
  });
  
  // Restituisce una copia del film con lo stato “visto” aggiornato
  Film copyAsWatched(bool markAsWatched) {
    return Film(
      id: id,
      titolo: titolo,
      anno: anno,
      genere: genere,
      descrizione: descrizione,
      visto: markAsWatched,
      immagine: immagine,
      valutazione: valutazione,
    );
  }
  
  // Restituisce una copia del film con la valutazione aggiornata
  Film copyWithRating(int newRating) {
    return Film(
      id: id,
      titolo: titolo,
      anno: anno,
      genere: genere,
      descrizione: descrizione,
      visto: visto,
      immagine: immagine,
      valutazione: newRating,
    );
  }

  @override
  String toString() {
    return "$titolo ($anno) - $genere, ${visto ? 'visto' : 'da vedere'}";
  }
  
  // Crea un'istanza di Film da una mappa JSON
  static Film fromJson(Map<String, dynamic> json, int index) {
    const uuid = Uuid();
    final titolo = json['titolo'] as String;
    final anno = json['anno'] as int;
    
    // Genera un UUID deterministico basato su titolo e anno
    // In questo modo lo stesso film avrà sempre lo stesso ID
    final id = uuid.v5(Uuid.NAMESPACE_URL, '$titolo-$anno');
    
    return Film(
      id: id,
      titolo: titolo,
      anno: anno,
      genere: json['genere'] as String,
      descrizione: json['descrizione'] as String,
      visto: false,
      immagine: json['immagine'] as String?,
      valutazione: 0,
    );
  }
  
  // Converte l'istanza di Film in una mappa JSON
  Map<String, dynamic> toJson() {
    return {
      'titolo': titolo,
      'anno': anno,
      'genere': genere,
      'descrizione': descrizione,
      'visto': visto,
      'immagine': immagine,
      'valutazione': valutazione,
    };
  }
}
