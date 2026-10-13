import 'package:flutter/material.dart';

class SongImage extends StatelessWidget {
  final String url;
  final double size;
  final double radius;

  const SongImage({
    super.key,
    required this.url,
    required this.size,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    // shown when there is no image or it can't be loaded (e.g. offline)
    final placeholder = Container(
      width: size,
      height: size,
      color: Colors.grey.shade800,
      child: const Icon(Icons.music_note, color: Colors.white54),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? placeholder
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
    );
  }
}
