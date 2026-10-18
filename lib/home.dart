import 'dart:async';

import 'package:flutter/material.dart';

import 'data.dart';
import 'state.dart';
import 'widgets.dart';
import 'title_page.dart';
import 'player_page.dart';

void openTitle(BuildContext context, AppState state, TitleItem t) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TitlePage(state: state, title: t),
    ),
  );
}

void playTitle(
  BuildContext context,
  AppState state,
  TitleItem t, {
  Episode? episode,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PlayerPage(state: state, title: t, episode: episode),
    ),
  );
}

// ----------------------------------------------------------------- shell
class AppShell extends StatefulWidget {
  final AppState state;
  const AppShell({super.key, required this.state});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: kBg,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: IndexedStack(
                index: _tab,
                children: [
                  HomeTab(state: state),
                  GenresTab(state: state),
                  LatestTab(state: state),
                  SearchTab(state: state),
                  MyListTab(state: state),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _AniNavBar(
                index: _tab,
                onTap: (i) => setState(() => _tab = i),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// AniLab-style bottom nav: 5 outline icons + labels on pure black,
/// white = active, gray = inactive. No tiles, no gradients.
class _AniNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _AniNavBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, IconData, String)>[
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.theater_comedy_outlined, Icons.theater_comedy, 'Genres'),
      (Icons.monitor_outlined, Icons.monitor_rounded, 'Latest'),
      (Icons.search_outlined, Icons.search_rounded, 'Search'),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, 'My List'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == index;
              final color = active ? Colors.white : kDim;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? items[i].$2 : items[i].$1,
                        color: color,
                        size: 26,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].$3,
                        style: TextStyle(color: color, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ home
class HomeTab extends StatefulWidget {
  final AppState state;
  const HomeTab({super.key, required this.state});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _heroCtrl = PageController();
  Timer? _heroTimer;
  int _heroPage = 0;

  List<TitleItem> get _featured => [
    byId('dhaka2077'),
    byId('dragon'),
    byId('ronin'),
    byId('dream'),
  ];

  @override
  void initState() {
    super.initState();
    _heroTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_heroCtrl.hasClients) return;
      final next = (_heroPage + 1) % _featured.length;
      _heroCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cw = catalog.where((t) => state.progressFor(t) > 0).toList();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.54,
          child: Stack(
            children: [
              PageView.builder(
                controller: _heroCtrl,
                itemCount: _featured.length,
                onPageChanged: (i) => _heroPage = i,
                itemBuilder: (context, i) =>
                    _HeroSlide(title: _featured[i], state: state),
              ),
              // top bar over hero: logo left, local profile right
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Row(
                      children: [
                        const MovieBoxLogo(size: 28),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _profileSheet(context),
                          child: AvatarWidget(profile: state.profile, size: 34),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SectionHeader('Spotlight'),
        _rail(
          catalog
              .map(
                (t) => PosterCard(
                  title: t,
                  onTap: () => openTitle(context, state, t),
                ),
              )
              .toList(),
        ),
        const SectionHeader('Trending'),
        _landscapeRail(context, [
          byId('dragon'),
          byId('dhaka2077'),
          byId('bunny'),
          byId('ocean'),
        ]),
        if (cw.isNotEmpty) ...[
          const SectionHeader('Continue Watching'),
          _landscapeRail(context, cw, withProgress: true),
        ],
        const SectionHeader('Top Airing'),
        _rail(
          [byId('dhaka2077'), byId('ronin'), byId('noir'), byId('dragon')]
              .map(
                (t) => PosterCard(
                  title: t,
                  onTap: () => openTitle(context, state, t),
                ),
              )
              .toList(),
        ),
        const SectionHeader('New Releases'),
        _landscapeRail(context, [
          byId('noir'),
          byId('dream'),
          byId('ronin'),
          byId('dhaka2077'),
        ]),
        const SectionHeader('Recommended for You'),
        _rail(
          catalog.reversed
              .map(
                (t) => PosterCard(
                  title: t,
                  onTap: () => openTitle(context, state, t),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 26),
        const Center(
          child: Text(
            'Demo UI — fictional titles, open sample videos',
            style: TextStyle(color: kFaint, fontSize: 11),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _rail(List<Widget> cards) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => cards[i],
      ),
    );
  }

  Widget _landscapeRail(
    BuildContext context,
    List<TitleItem> titles, {
    bool withProgress = false,
  }) {
    final state = widget.state;
    return SizedBox(
      height: 151,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: titles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => LandscapeCard(
          title: titles[i],
          state: withProgress ? state : null,
          progressRatio: withProgress ? null : 0,
          onTap: () => openTitle(context, state, titles[i]),
        ),
      ),
    );
  }

  void _profileSheet(BuildContext context) {
    final state = widget.state;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Profiles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Stored only on this device — no account, no server.',
                style: TextStyle(color: kDim, fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < state.profiles.length; i++)
                    GestureDetector(
                      onTap: () {
                        state.switchProfile(i);
                        Navigator.pop(ctx);
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: i == state.activeProfile
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: AvatarWidget(
                              profile: state.profiles[i],
                              size: 56,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.profiles[i].name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Manage profiles from the My List tab',
                style: TextStyle(color: kFaint, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final TitleItem title;
  final AppState state;
  const _HeroSlide({required this.title, required this.state});

  @override
  Widget build(BuildContext context) {
    final inList = state.inMyList(title.id);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(title.backdrop, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black38, Colors.transparent, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.45, 1],
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 14,
          child: Column(
            children: [
              Text(
                title.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              MetaChip(title.isSeries ? 'TV' : 'MOVIE'),
              const SizedBox(height: 9),
              Text(
                '${title.year}  •  ${title.durationLabel}  •  ★ ${title.rating.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 5),
              Text(
                title.genres.join(' • '),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        horizontal: 34,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => openTitle(context, state, title),
                    icon: const Icon(Icons.info_outline_rounded, size: 22),
                    label: const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SideAction(
                    icon: inList
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: 'My List',
                    onTap: () => state.toggleMyList(title.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- genres
const List<String> kAllGenres = [
  'Action',
  'Adventure',
  'Animation',
  'Comedy',
  'Crime',
  'Documentary',
  'Drama',
  'Family',
  'Fantasy',
  'Horror',
  'Mystery',
  'Romance',
  'Sci-Fi',
  'Surreal',
  'Thriller',
  'Anime',
];

class GenresTab extends StatelessWidget {
  final AppState state;
  const GenresTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Text(
              'Genres',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 62,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: kAllGenres.length,
              itemBuilder: (context, i) {
                final g = kAllGenres[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GenreResultsPage(state: state, genre: g),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kTile,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      g,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GenreResultsPage extends StatelessWidget {
  final AppState state;
  final String genre;
  const GenreResultsPage({super.key, required this.state, required this.genre});

  @override
  Widget build(BuildContext context) {
    final results = catalog
        .where((t) => t.genres.contains(genre) || t.kind == genre)
        .toList();
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        genre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? const Center(
                          child: Text(
                            'No titles in this genre yet (demo)',
                            style: TextStyle(color: kDim),
                          ),
                        )
                      : PosterGrid(state: state, titles: results),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 3-column poster grid used by Latest / Search / Genre pages (AniLab style).
class PosterGrid extends StatelessWidget {
  final AppState state;
  final List<TitleItem> titles;
  const PosterGrid({super.key, required this.state, required this.titles});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.704,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: titles.length,
      itemBuilder: (context, i) => PosterCard(
        title: titles[i],
        width: double.infinity,
        onTap: () => openTitle(context, state, titles[i]),
      ),
    );
  }
}

// ---------------------------------------------------------------- latest
class LatestTab extends StatelessWidget {
  final AppState state;
  const LatestTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final ordered = [...catalog]..sort((a, b) => b.year.compareTo(a.year));
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Text(
              'Latest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: PosterGrid(state: state, titles: ordered),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- search
class SearchTab extends StatefulWidget {
  final AppState state;
  const SearchTab({super.key, required this.state});
  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final results = catalog.where((t) {
      final q = _q.toLowerCase();
      return q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.genres.any((g) => g.toLowerCase().contains(q)) ||
          t.kind.toLowerCase().contains(q);
    }).toList();
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search movies, series, anime…',
                hintStyle: const TextStyle(color: kFaint),
                prefixIcon: const Icon(Icons.search, color: kDim),
                filled: true,
                fillColor: kTile,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(color: kDim),
                    ),
                  )
                : PosterGrid(state: widget.state, titles: results),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- my list
class MyListTab extends StatelessWidget {
  final AppState state;
  const MyListTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final mine = catalog.where((t) => state.inMyList(t.id)).toList();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          const Text(
            'My List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          // local profile card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AvatarWidget(profile: state.profile, size: 52),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'Local profile — on this device only',
                        style: TextStyle(color: kDim, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => _editProfile(context, state.activeProfile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              for (var i = 0; i < state.profiles.length; i++)
                GestureDetector(
                  onTap: () => state.switchProfile(i),
                  onLongPress: () => _editProfile(context, i),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: i == state.activeProfile
                                ? Colors.white
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: AvatarWidget(
                          profile: state.profiles[i],
                          size: 52,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        state.profiles[i].name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              if (state.profiles.length < 5)
                GestureDetector(
                  onTap: () => _editProfile(context, null),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: kTile,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Add',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap to switch • long-press to edit',
            style: TextStyle(color: kFaint, fontSize: 11.5),
          ),
          const SizedBox(height: 22),
          if (mine.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Column(
                children: [
                  Icon(Icons.favorite_border_rounded, color: kFaint, size: 44),
                  SizedBox(height: 10),
                  Text(
                    'Your list is empty',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap the heart on any title to save it here.',
                    style: TextStyle(color: kDim, fontSize: 12.5),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.704,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: mine.length,
              itemBuilder: (context, i) => PosterCard(
                title: mine[i],
                width: double.infinity,
                onTap: () => openTitle(context, state, mine[i]),
              ),
            ),
          const SizedBox(height: 14),
          _row(
            context,
            Icons.download_outlined,
            'Downloads',
            'No downloads yet',
          ),
          _row(
            context,
            Icons.notifications_none_rounded,
            'Notifications',
            'All caught up',
          ),
          _row(context, Icons.settings_outlined, 'App Settings', 'Demo build'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String title, String sub) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(sub, style: const TextStyle(color: kDim)),
      trailing: const Icon(Icons.chevron_right, color: kFaint),
      onTap: () => toast(context, '$title is a demo in this UI'),
    );
  }

  void _editProfile(BuildContext context, int? index) {
    final isNew = index == null;
    final nameCtrl = TextEditingController(
      text: isNew ? '' : state.profiles[index].name,
    );
    var colorIdx = isNew ? 1 : state.profiles[index].colorIndex;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: kSurface,
          title: Text(
            isNew ? 'Add profile' : 'Edit profile',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Profile name',
                  hintStyle: TextStyle(color: kFaint),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: [
                  for (var c = 0; c < kAvatarGradients.length; c++)
                    GestureDetector(
                      onTap: () => setLocal(() => colorIdx = c),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: kAvatarGradients[c]),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorIdx == c
                                ? Colors.white
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: kDim)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                if (isNew) {
                  state.addProfile(name, colorIdx);
                } else {
                  state.updateProfile(index, name, colorIdx);
                }
                Navigator.pop(ctx);
              },
              child: Text(isNew ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
