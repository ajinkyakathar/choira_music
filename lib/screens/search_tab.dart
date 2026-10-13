import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_feed.dart';
import '../services/api_service.dart';
import '../widgets/list_status.dart';
import '../widgets/paged_footer.dart';
import '../widgets/song_tile.dart';
import 'playback.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // search while typing, but wait a moment so every key press
  // does not send a request
  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchFeed>().search(text);
    });
  }

  void _onSubmitted(String text) {
    _debounce?.cancel();
    context.read<SearchFeed>().search(text);
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    context.read<SearchFeed>().search('');
  }

  @override
  Widget build(BuildContext context) {
    if (!ApiService.hasClientId) return const MissingClientIdMessage();

    final feed = context.watch<SearchFeed>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: _onSubmitted,
                decoration: InputDecoration(
                  hintText: 'Search songs or artists',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clear,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (feed.isOffline) const OfflineBanner(),
            Expanded(child: _buildResults(feed)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(SearchFeed feed) {
    if (feed.query.isEmpty) {
      return const Center(
        child: Text(
          'Type a song or artist name',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    if (feed.songs.isEmpty) {
      return ListStatus(
        list: feed,
        emptyText: 'No songs found for "${feed.query}"',
      );
    }

    return RefreshIndicator(
      onRefresh: () => feed.reset(),
      child: ListView.builder(
        cacheExtent: 600,
        itemCount: feed.songs.length + 1, // +1 for the footer
        itemBuilder: (context, index) {
          if (index < feed.songs.length) {
            return SongTile(
              song: feed.songs[index],
              onTap: () => playFromList(context, feed.songs, index),
            );
          }
          return PagedFooter(
            key: ValueKey(feed.songs.length),
            list: feed,
          );
        },
      ),
    );
  }
}
