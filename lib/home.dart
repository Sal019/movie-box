import 'package:flutter/material.dart';
import 'data.dart';
import 'state.dart';
import 'widgets.dart';
import 'title_page.dart';
import 'player_page.dart';

void openTitle(BuildContext context, AppState state, TitleItem t) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TitlePage(state: state, title: t)));
}

void playTitle(BuildContext context, AppState state, TitleItem t,
    {Episode? episode}) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PlayerPage(state: state, title: t, episode: episode)));
}

// ---------------------------------------------------------------- shell
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
          body: IndexedStack(
            index: _tab,
            children: [
              HomeTab(state: state, goMy: () => setState(() => _tab = 3)),
              ClipsTab(state: state),
              SearchTab(state: state),
              MyTab(state: state),
            ],
          ),
          bottomNavigationBar: _NovaNavBar(
            index: _tab,
            profile: state.profile,
            onTap: (i) => setState(() => _tab = i),
          ),
        );
      },
    );
  }
}

class _NovaNavBar extends StatelessWidget {
  final int index;
  final LocalProfile profile;
  final ValueChanged<int> onTap;
  const _NovaNavBar(
      {required this.index, required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('assets/icons/nav-home.webp', 'Home'),
      ('assets/icons/nav-clips.webp', 'Clips'),
      ('assets/icons/nav-search.webp', 'Search'),
      ('assets/icons/nav-profile.webp', 'My Nova'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF00B1122),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = i == index;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 46,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: active ? kAccent : null,
                      color: active ? null : Colors.white.withValues(alpha: 0.06),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(items[i].$1, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(items[i].$2,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? Colors.white : Colors.white54)),
                ]),
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
  final VoidCallback goMy;
  const HomeTab({super.key, required this.state, required this.goMy});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? _filter; // 'Shows' | 'Movies' | genre name

  bool _keep(TitleItem t) {
    if (_filter == null) return true;
    if (_filter == 'Shows') return t.isSeries;
    if (_filter == 'Movies') return !t.isSeries;
    return t.genres.contains(_filter);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final hero = byId('dhaka2077');
    final cw = catalog.where((t) => state.progressFor(t) > 0 && _keep(t)).toList();
    final trending = catalog.where(_keep).toList();
    final top10 = catalog.where((t) => t.top10Rank != null && _keep(t)).toList()
      ..sort((a, b) => a.top10Rank!.compareTo(b.top10Rank!));
    final anime =
        catalog.where((t) => t.kind == 'Anime' || t.id == 'dream' || t.id == 'noir').where(_keep).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(children: [
              const NovaLogo(),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white),
                onPressed: () => toast(context, 'No new notifications'),
              ),
              GestureDetector(
                onTap: () => _profileSheet(context),
                child: AvatarWidget(profile: state.profile, size: 36),
              ),
            ]),
          ),
          // nav chips (2026 style top nav)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
            child: Row(children: [
              _chip('Shows', _filter == 'Shows',
                  () => setState(() => _filter = _filter == 'Shows' ? null : 'Shows')),
              const SizedBox(width: 8),
              _chip('Movies', _filter == 'Movies',
                  () => setState(() => _filter = _filter == 'Movies' ? null : 'Movies')),
              const SizedBox(width: 8),
              _chip('Categories', false, _categoriesSheet),
              if (_filter != null && _filter != 'Shows' && _filter != 'Movies') ...[
                const SizedBox(width: 8),
                _chip('$_filter ✕', true, () => setState(() => _filter = null)),
              ],
            ]),
          ),
          // hero card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _HeroCard(title: hero, state: state),
          ),
          if (cw.isNotEmpty) ...[
            const SectionHeader('Continue Watching'),
            _rail(
              height: 141,
              children: cw
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: LandscapeCard(
                            title: t,
                            state: state,
                            onTap: () => openTitle(context, state, t)),
                      ))
                  .toList(),
            ),
          ],
          const SectionHeader('Trending Now'),
          _rail(
            height: 174,
            children: trending
                .map((t) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: PosterCard(
                          title: t, onTap: () => openTitle(context, state, t)),
                    ))
                .toList(),
          ),
          if (top10.isNotEmpty) ...[
            const SectionHeader('Top 10 in Bangladesh Today'),
            _rail(
              height: 178,
              children: top10
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Top10Card(
                            title: t,
                            onTap: () => openTitle(context, state, t)),
                      ))
                  .toList(),
            ),
          ],
          SectionHeader('Because You Watched "Dragon\'s Promise"'),
          _rail(
            height: 174,
            children: [byId('dream'), byId('ronin'), byId('dhaka2077'), byId('noir')]
                .where(_keep)
                .map((t) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: PosterCard(
                          title: t, onTap: () => openTitle(context, state, t)),
                    ))
                .toList(),
          ),
          if (anime.isNotEmpty) ...[
            const SectionHeader('Anime & Beyond'),
            _rail(
              height: 174,
              children: anime
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: PosterCard(
                            title: t,
                            onTap: () => openTitle(context, state, t)),
                      ))
                  .toList(),
            ),
          ],
          const SectionHeader('New Releases'),
          _rail(
            height: 141,
            children: catalog
                .where(_keep)
                .map((t) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: LandscapeCard(
                          title: t,
                          progressRatio: 0,
                          onTap: () => openTitle(context, state, t)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 26),
          const Center(
            child: Text('Demo UI — fictional titles, open sample videos',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _rail({required double height, required List<Widget> children}) {
    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: children,
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: active ? kAccent : null,
          color: active ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _categoriesSheet() {
    final genres = <String>{
      for (final t in catalog) ...t.genres
    }.toList()
      ..sort();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('Categories',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ),
            for (final g in genres)
              ListTile(
                title: Text(g, style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _filter = g);
                },
              ),
            const SizedBox(height: 10),
          ],
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Who\'s watching?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Profiles live only on this device (local storage).',
                style: TextStyle(color: Colors.white54, fontSize: 12.5)),
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
                    child: Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: i == state.activeProfile
                                  ? kCyan
                                  : Colors.transparent,
                              width: 2.5),
                        ),
                        child: AvatarWidget(
                            profile: state.profiles[i], size: 58),
                      ),
                      const SizedBox(height: 6),
                      Text(state.profiles[i].name,
                          style: const TextStyle(color: Colors.white)),
                    ]),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                widget.goMy();
              },
              icon: const Icon(Icons.edit_rounded, color: kCyan, size: 18),
              label: const Text('Manage profiles',
                  style: TextStyle(color: Colors.white)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final TitleItem title;
  final AppState state;
  const _HeroCard({required this.title, required this.state});

  @override
  Widget build(BuildContext context) {
    final inList = state.inMyList(title.id);
    return GestureDetector(
      onTap: () => openTitle(context, state, title),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 0.88,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(title.backdrop, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xE6070B1A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 1],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    gradient: kAccent,
                    borderRadius: BorderRadius.circular(14)),
                child: const Text('#1 in TV Shows Today',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Text(title.genres.join('  •  '),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12.5)),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => playTitle(context, state, title),
                          icon: const Icon(Icons.play_arrow_rounded, size: 26),
                          label: const Text('Play',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.22),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => state.toggleMyList(title.id),
                          icon: Icon(inList ? Icons.check : Icons.add, size: 24),
                          label: const Text('My List',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ]),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- clips
class ClipsTab extends StatelessWidget {
  final AppState state;
  const ClipsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final clips = [byId('ronin'), byId('ocean'), byId('bunny'), byId('dhaka2077')];
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: clips.length,
      itemBuilder: (context, i) {
        final t = clips[i];
        return Stack(fit: StackFit.expand, children: [
          Image.asset(t.poster, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black26, Colors.transparent, Color(0xCC070B1A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () => playTitle(context, state, t),
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: kAccent,
                  boxShadow: [
                    BoxShadow(
                        color: kViolet.withValues(alpha: 0.55),
                        blurRadius: 24,
                        spreadRadius: 2)
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 42),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 80,
            bottom: 26,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${t.kind} • ${t.genres.join(' • ')}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ]),
          ),
          Positioned(
            right: 14,
            bottom: 90,
            child: Column(children: [
              _sideAction(Icons.favorite_rounded, 'Like'),
              const SizedBox(height: 18),
              _sideAction(Icons.add_rounded, 'My List',
                  () => state.toggleMyList(t.id)),
              const SizedBox(height: 18),
              _sideAction(Icons.share_rounded, 'Share',
                  () => toast(context, 'Share link copied (demo)')),
            ]),
          ),
        ]);
      },
    );
  }

  Widget _sideAction(IconData icon, String label, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24)),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10.5)),
      ]),
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
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search shows, movies, anime…',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: kSurface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        if (_q.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Popular right now',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: Text('No matches found',
                      style: TextStyle(color: Colors.white54)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.66,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, i) => PosterCard(
                    title: results[i],
                    width: double.infinity,
                    onTap: () => openTitle(context, widget.state, results[i]),
                  ),
                ),
        ),
      ]),
    );
  }
}

// -------------------------------------------------------------------- my
class MyTab extends StatelessWidget {
  final AppState state;
  const MyTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final mine = catalog.where((t) => state.inMyList(t.id)).toList();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          const Text('My Nova',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          // active profile card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: kSurface, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              AvatarWidget(profile: state.profile, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.profile.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const Text('Local profile — on this device only',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12.5)),
                    ]),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: kCyan),
                onPressed: () =>
                    _editProfile(context, state.activeProfile),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Profiles',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(spacing: 14, runSpacing: 12, children: [
            for (var i = 0; i < state.profiles.length; i++)
              GestureDetector(
                onTap: () => state.switchProfile(i),
                onLongPress: () => _editProfile(context, i),
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: i == state.activeProfile
                              ? kCyan
                              : Colors.transparent,
                          width: 2.5),
                    ),
                    child: AvatarWidget(profile: state.profiles[i], size: 54),
                  ),
                  const SizedBox(height: 5),
                  Text(state.profiles[i].name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12.5)),
                ]),
              ),
            if (state.profiles.length < 5)
              GestureDetector(
                onTap: () => _editProfile(context, null),
                child: Column(children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  const Text('Add',
                      style:
                          TextStyle(color: Colors.white, fontSize: 12.5)),
                ]),
              ),
          ]),
          const SizedBox(height: 8),
          const Text('Tap to switch • long-press to edit',
              style: TextStyle(color: Colors.white38, fontSize: 11.5)),
          const SizedBox(height: 24),
          const Text('My List',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (mine.isEmpty)
            const Text('Nothing saved yet — tap + My List on any title.',
                style: TextStyle(color: Colors.white54))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.66,
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
          const SizedBox(height: 24),
          _row(Icons.download_rounded, 'Downloads', 'No downloads yet',
              () => toast(context, 'Downloads are a demo in this UI')),
          _row(Icons.notifications_rounded, 'Notifications', 'All caught up',
              () => toast(context, 'No new notifications')),
          _row(Icons.settings_rounded, 'App Settings', 'Quality: Auto (demo)',
              () => toast(context, 'Settings are a demo in this UI')),
          _row(Icons.help_outline_rounded, 'Help', 'Nova demo build',
              () => toast(context, 'Demo UI built with Flutter')),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
            color: kSurface, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }

  void _editProfile(BuildContext context, int? index) {
    final isNew = index == null;
    final nameCtrl = TextEditingController(
        text: isNew ? '' : state.profiles[index].name);
    var colorIdx = isNew ? 1 : state.profiles[index].colorIndex;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: kSurface,
          title: Text(isNew ? 'Add profile' : 'Edit profile',
              style: const TextStyle(color: Colors.white)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Profile name',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(spacing: 10, children: [
              for (var c = 0; c < kAvatarGradients.length; c++)
                GestureDetector(
                  onTap: () => setLocal(() => colorIdx = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: kAvatarGradients[c]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colorIdx == c ? Colors.white : Colors.transparent,
                          width: 2.5),
                    ),
                  ),
                ),
            ]),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
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
