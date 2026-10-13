import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/home_feed.dart';
import '../services/api_service.dart';
import '../widgets/list_status.dart';
import '../widgets/paged_footer.dart';
import '../widgets/song_tile.dart';
import '../widgets/square_song_card.dart';
import 'playback.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ApiService.hasClientId) return const MissingClientIdMessage();

    final feed = context.watch<HomeFeed>();

    return Center(
      // keeps the content readable on tablets and wide screens
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: RefreshIndicator(
          onRefresh: feed.refresh,
          child: CustomScrollView(
            // start loading the next page a bit before the end is visible
            cacheExtent: 600,
            slivers: [
              if (feed.isOffline)
                const SliverToBoxAdapter(child: OfflineBanner()),

              if (feed.featured.isNotEmpty) ...[
                const SliverToBoxAdapter(child: _SectionTitle('Featured')),
                SliverToBoxAdapter(child: _FeaturedRow(songs: feed.featured)),
              ],

              const SliverToBoxAdapter(child: _SectionTitle('Recommended')),

              if (feed.songs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ListStatus(list: feed, emptyText: 'No songs found'),
                )
              else
                SliverList.builder(
                  itemCount: feed.songs.length + 1, // +1 for the footer
                  itemBuilder: (context, index) {
                    if (index < feed.songs.length) {
                      return SongTile(
                        song: feed.songs[index],
                        onTap: () => playFromList(context, feed.songs, index),
                      );
                    }
                    // new key per page, so the footer asks for the next page
                    // each time it is built
                    return PagedFooter(
                      key: ValueKey(feed.songs.length),
                      list: feed,
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FeaturedRow extends StatelessWidget {
  final List<Song> songs;
  const _FeaturedRow({required this.songs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: songs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SquareSongCard(
          song: songs[index],
          onTap: () => playFromList(context, songs, index),
        ),
      ),
    );
  }
}
