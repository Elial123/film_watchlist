import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

// Widget per mostrare il conteggio dei film (totali, visti, da vedere)
class FilmsCountWidget extends ConsumerWidget {
  const FilmsCountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // c'è ref perché usa provider
    debugPrint('Building FilmsCountWidget');

    final filmCount = ref.watch(filmCountProvider);
    final filmList = ref.watch(filmListProvider);
    final watchedCount = filmList.where((film) => film.visto).length;
    final toWatchCount = filmCount - watchedCount;
    final colorScheme = Theme.of(context).colorScheme;

    return Container( // contenitore con padding e decorazione
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row( // widget che serve per mettere più widget uno accanto all’altro, in orizzontale
        mainAxisAlignment: MainAxisAlignment.spaceAround, // mette spazio uguale tra i widget figli
        children: [
          _CountColumn(
            label: 'Film totali',
            value: filmCount,
            color: colorScheme.onSecondaryContainer,
          ),
          _VerticalDivider(color: colorScheme.onSecondaryContainer),
          _CountColumn(
            label: 'Film visti',
            value: watchedCount,
            color: colorScheme.onSecondaryContainer,
          ),
          _VerticalDivider(color: colorScheme.onSecondaryContainer),
          _CountColumn(
            label: 'Da vedere',
            value: toWatchCount,
            color: colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}

// colonna con un numero e una label, per il conteggio
// una volta definita, non cambia mai il suo stato interno, quindi è StatelessWidget
class _CountColumn extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CountColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// separatore verticale personalizzato
// semplice linea verticale con altezza fissa
class _VerticalDivider extends StatelessWidget {
  final Color color;

  const _VerticalDivider({required this.color}); 

  @override
  Widget build(BuildContext context) { // non c'è ref perché non usa provider
    return Container(
      width: 1,
      height: 40,
      color: color.withOpacity(0.2),
    );
  }
}
