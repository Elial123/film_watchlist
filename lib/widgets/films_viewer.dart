import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:film_watchlist/providers.dart';
import '../models/film.dart';

// Widget per visualizzare le informazioni di un film
class FilmViewer extends ConsumerWidget {
  final Film film;

  const FilmViewer(this.film, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme; // Colori del tema corrente
    
    // Ottieni lo stato aggiornato dal provider
    final filmList = ref.watch(filmListProvider);
    final currentFilm = filmList.firstWhere(
      (f) => f.id == film.id,
      orElse: () => film,
    );

    return Card( // Usa un widget Card per un aspetto più elegante
      elevation: 0, // Rimuove l'ombra
      clipBehavior: Clip.antiAlias, // Ritagli i bordi del contenuto per non uscire dal Card
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), // Spaziatura esterna
      shape: RoundedRectangleBorder( // Bordo arrotondato del Card con personalizzazione del bordo
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: currentFilm.visto  // Cambia il colore del bordo se il film è visto
            ? scheme.primary // Tema primario dell' app se visto
            : scheme.outlineVariant.withOpacity(0.5), // Colore di outline se non visto
          width: currentFilm.visto ? 2 : 1,
        ),
      ),
      child: InkWell( // Aggiunge l'effetto di tocco
        onTap: () => ref.read(filmListProvider.notifier).toggleFilmWatched(currentFilm.id),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPoster(scheme, currentFilm), // Mostra il poster del film
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetails(context, scheme, currentFilm), // Mostra i dettagli del film
                ),
                _buildCheckbox(ref, currentFilm), // Checkbox per segnare come visto
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sotto-Widget per una migliore leggibilità ---

  // Costruisce il poster del film con un Hero widget per l'animazione
  Widget _buildPoster(ColorScheme scheme, Film currentFilm) {
    return Hero(
      tag: 'film_image_${currentFilm.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: currentFilm.immagine != null && currentFilm.immagine!.isNotEmpty
            ? Image.network(
                currentFilm.immagine!,
                width: 85,
                height: 125,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => _buildImagePlaceholder(scheme),
              )
            : _buildImagePlaceholder(scheme),
      ),
    );
  }
  
  // Placeholder per l'immagine del film in caso di assenza di poster o errore di caricamento
  Widget _buildImagePlaceholder(ColorScheme scheme) {
    return Container(
      width: 85,
      height: 125,
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.movie_creation_outlined, color: scheme.onSurfaceVariant),
    );
  }

  // Costruisce i dettagli del film come titolo, genere, anno e descrizione
  Widget _buildDetails(BuildContext context, ColorScheme scheme, Film currentFilm) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentFilm.titolo,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildBadge(scheme, currentFilm.genere), // Mostra il genere come badge
            const SizedBox(width: 8),
            Text(
              '${currentFilm.anno}', // Mostra l'anno di uscita
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Text(
            currentFilm.descrizione, // Mostra la descrizione del film
            style: textTheme.bodyMedium?.copyWith( // stile del testo
              color: scheme.onSurfaceVariant,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        _buildRatingStars(context, scheme, currentFilm), // Mostra la valutazione
      ],
    );
  }

// Costruisce un badge per il genere del film
  Widget _buildBadge(ColorScheme scheme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer, // Colore di sfondo del badge
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.onSecondaryContainer,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Costruisce le stelle per la valutazione del film
  Widget _buildRatingStars(BuildContext context, ColorScheme scheme, Film currentFilm) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) { // Genera 5 stelle
        return GestureDetector(
          onTap: () {
            // Tocca per impostare la valutazione
            final ref = ProviderScope.containerOf(context); // Ottieni il riferimento al provider
            final newRating = index + 1;
            ref.read(filmListProvider.notifier).updateFilmRating(
              currentFilm.id,
              currentFilm.valutazione == newRating ? 0 : newRating,
            );
          },
          child: Icon( // Mostra l'icona della stella piena o vuota
            index < currentFilm.valutazione ? Icons.star : Icons.star_border,
            color: scheme.primary,
            size: 18,
          ),
        );
      }),
    );
  }

// Costruisce il checkbox per segnare il film come visto o non visto
  Widget _buildCheckbox(WidgetRef ref, Film currentFilm) {
    return Align( // widget Align per posizionare il checkbox in alto a destra
      alignment: Alignment.topRight,
      child: Checkbox(
        value: currentFilm.visto,
        shape: const CircleBorder(), // Rende il checkbox più moderno
        onChanged: (_) => ref.read(filmListProvider.notifier).toggleFilmWatched(currentFilm.id),
      ),
    );
  }
}