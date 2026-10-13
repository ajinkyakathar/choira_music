import 'package:flutter/material.dart';

import '../providers/paged_song_list.dart';

/// Shown instead of a list when it has no songs yet:
/// a spinner while loading, an error with Retry, or "nothing found".
class ListStatus extends StatelessWidget {
  final PagedSongList list;
  final String emptyText;

  const ListStatus({super.key, required this.list, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (list.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48),
              const SizedBox(height: 12),
              Text(list.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => list.loadMore(retry: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (list.isLoading || list.hasMore) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(child: Text(emptyText));
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text('You are offline. Showing saved songs.'),
    );
  }
}

class MissingClientIdMessage extends StatelessWidget {
  const MissingClientIdMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Jamendo client ID is missing. See the README.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
