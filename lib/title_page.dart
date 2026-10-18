import 'package:flutter/material.dart';

import 'data.dart';
import 'state.dart';
import 'widgets.dart';
import 'home.dart' show openTitle, playTitle;

/// AniLab-style title detail page, recreated from public screenshots:
/// full-bleed backdrop, centered title, gray TV/rating chips, meta line,
/// Share | white-pill Watch | My List row, synopsis, Episodes (series),
/// Related + You May Also Like portrait rails.
class TitlePage extends StatefulWidget {
  final AppState state;
  final TitleItem title;
  const TitlePage({super.key, required this.state, required this.title});
  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  int _seasonIdx = 0;

  TitleItem get t => widget.title;
  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _hero(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.synopsis,
                        style: const TextStyle(
                          color: Color(0xFFD8D8DC),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cast: ${t.castLine}',
                        style: const TextStyle(color: kDim, fontSize: 12.5),
                      ),
                      Text(
                        t.creatorLine,
                        style: const TextStyle(color: kDim, fontSize: 12.5),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _tileButton(
                              Icons.download_rounded,
                              t.isSeries
                                  ? 'Download S${_seasonIdx + 1}'
                                  : 'Download',
                              () => toast(context, 'Download started (demo)'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _tileButton(
                              Icons.play_circle_outline_rounded,
                              'Trailer',
                              () => playTitle(context, state, t),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (t.isSeries) _episodesSection(context),
                const SectionHeader('Related'),
                _portraitRail(context, _related()),
                const SectionHeader('You May Also Like'),
                _portraitRail(context, _alsoLike()),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final inList = state.inMyList(t.id);
    final h = MediaQuery.of(context).size.height * 0.52;
    return SizedBox(
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(t.backdrop, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black45, Colors.transparent, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 4,
            child: SafeArea(
              bottom: false,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 12,
            child: Column(
              children: [
                Text(
                  t.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MetaChip(t.isSeries ? 'TV' : 'MOVIE'),
                    const SizedBox(width: 8),
                    MetaChip(
                      t.maturity.replaceAll('+', '').trim().isEmpty
                          ? 'PG'
                          : 'PG ${t.maturity.replaceAll('+', '')}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${t.year}  •  ${t.isSeries ? 'Releasing' : 'Released'}  •  ${t.durationLabel}  •  ★ ${t.rating.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  t.genres.join(' • '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SideAction(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: () => toast(context, 'Share link copied (demo)'),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 38,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => playTitle(
                        context,
                        state,
                        t,
                        episode: t.isSeries
                            ? t.seasons[_seasonIdx].episodes.first
                            : null,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 24),
                      label: const Text(
                        'Watch',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SideAction(
                      icon: inList
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: 'My List',
                      onTap: () => state.toggleMyList(t.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: kTile,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _episodesSection(BuildContext context) {
    final season = t.seasons[_seasonIdx];
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 22, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Episodes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _seasonMenu(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: kTile,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Season ${season.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final ep in season.episodes) _episodeRow(context, ep),
        ],
      ),
    );
  }

  void _seasonMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Select Season',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            for (var i = 0; i < t.seasons.length; i++)
              ListTile(
                title: Text(
                  'Season ${t.seasons[i].number}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: i == _seasonIdx
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
                onTap: () {
                  setState(() => _seasonIdx = i);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _episodeRow(BuildContext context, Episode ep) {
    return GestureDetector(
      onTap: () => playTitle(context, state, t, episode: ep),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 34,
              child: Text(
                '${ep.number}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ep.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ep.durationLabel,
                    style: const TextStyle(color: kDim, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ep.synopsis,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kDim,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                const Icon(
                  Icons.play_circle_outline_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      toast(context, 'Episode download started (demo)'),
                  child: const Icon(
                    Icons.download_rounded,
                    color: kDim,
                    size: 21,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TitleItem> _related() {
    final rel = catalog
        .where((x) => x.id != t.id && x.genres.any(t.genres.contains))
        .toList();
    return (rel.isEmpty ? catalog.where((x) => x.id != t.id).toList() : rel)
        .take(6)
        .toList();
  }

  List<TitleItem> _alsoLike() {
    final first = _related().map((x) => x.id).toSet();
    final rest = catalog
        .where((x) => x.id != t.id && !first.contains(x.id))
        .toList();
    return (rest.isEmpty ? _related() : rest).take(6).toList();
  }

  Widget _portraitRail(BuildContext context, List<TitleItem> titles) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: titles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => PosterCard(
          title: titles[i],
          onTap: () => openTitle(context, state, titles[i]),
        ),
      ),
    );
  }
}
