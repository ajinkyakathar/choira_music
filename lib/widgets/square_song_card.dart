import 'package:flutter/material.dart';

import '../models/song.dart';
import 'song_image.dart';

/// Square card (artwork, title, artist) used in the Featured row.
class SquareSongCard extends StatelessWidget {
  static const double size = 140;

  final Song song;
  final VoidCallback onTap;

  const SquareSongCard({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SongImage(url: song.image, size: size, radius: 12),
            const SizedBox(height: 8),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
