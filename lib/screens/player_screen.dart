import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../utils.dart';
import '../widgets/song_image.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  // value of the slider while the user is dragging it
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;
    if (song == null) return const Scaffold();

    // artwork size depends on the screen so it also fits in landscape
    final screen = MediaQuery.of(context).size;
    final artSize = min(screen.width * 0.8, screen.height * 0.4);

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SongImage(url: song.image, size: artSize, radius: 20),
                const SizedBox(height: 24),
                Text(
                  song.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  song.album.isEmpty
                      ? song.artist
                      : '${song.artist} - ${song.album}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),

                // progress bar, updates with the playback position
                StreamBuilder<Duration>(
                  stream: player.audio.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final total =
                        player.audio.duration ?? Duration(seconds: song.duration);
                    final maxValue = total.inSeconds > 0
                        ? total.inSeconds.toDouble()
                        : 1.0;
                    final value = (_dragValue ?? position.inSeconds.toDouble())
                        .clamp(0.0, maxValue)
                        .toDouble();

                    return Column(
                      children: [
                        Slider(
                          value: value,
                          max: maxValue,
                          onChanged: (v) => setState(() => _dragValue = v),
                          onChangeEnd: (v) {
                            player.seek(Duration(seconds: v.toInt()));
                            setState(() => _dragValue = null);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatTime(Duration(seconds: value.toInt()))),
                              Text(formatTime(total)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 40,
                      onPressed: player.previous,
                      icon: const Icon(Icons.skip_previous),
                    ),
                    const SizedBox(width: 12),
                    if (player.isLoading)
                      const SizedBox(
                        width: 64,
                        height: 64,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      IconButton(
                        iconSize: 64,
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: player.togglePlay,
                        icon: Icon(
                          player.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                        ),
                      ),
                    const SizedBox(width: 12),
                    IconButton(
                      iconSize: 40,
                      onPressed: player.next,
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
                if (player.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${player.error} Tap play to try again.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
