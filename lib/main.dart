import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

// ---------------------------------------------------------------------------
// MovieBox — UI/UX demo recreating the iQONE video-blog theme's layout:
// dark #111319 surfaces, green #1CC749 accent, top header + chip nav row,
// 16:9 hero slider with a numbered playlist, square poster grid, detail and
// intl-style player pages. Original demo content only.
// ---------------------------------------------------------------------------

const kBg = Color(0xFF111319);
const kPanel = Color(0xFF1A1C22);
const kDeep = Color(0xFF0A0C0F);
const kBtn = Color(0xFF2D2F34);
const kGreen = Color(0xFF1CC749);
const kGreenA = Color(0xFF00D639);
const kGreenB = Color(0xFF00C234);
const kProgress = Color(0xFF1ECA95);
const kText = Color(0xFFECECEC);
const kGrey = Color(0xFF828387);
const kMenuLink = Color(0xFFA9A9AC);
const kFooterText = Color(0xFF999999);

void main() => runApp(const MovieBoxApp());

// ------------------------------- data --------------------------------------

class Title {
  final String id, name, kind, year, age, country, language, synopsis, poster;
  final double rating;
  final int episodes, rank;
  final List<String> genres;
  final String stream;
  const Title({
    required this.id,
    required this.name,
    required this.kind,
    required this.year,
    required this.rating,
    required this.age,
    required this.episodes,
    required this.country,
    required this.language,
    required this.genres,
    required this.synopsis,
    required this.poster,
    required this.rank,
    required this.stream,
  });
  bool get isSeries => kind != 'Movie';
  String get backdrop =>
      id == 'dhaka2077' ? 'assets/images/hero-dhaka.webp' : poster;
}

const _sintel = 'https://archive.org/download/Sintel/sintel-2048-surround.mp4';
const _bbb =
    'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4';
const _ed = 'https://archive.org/download/ElephantsDream/ed_1024_512kb.mp4';
const _clip =
    'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4';

const catalog = <Title>[
  Title(
    id: 'dhaka2077',
    name: 'Dhaka 2077',
    kind: 'Series',
    year: '2026',
    rating: 9.7,
    age: '18+',
    episodes: 28,
    country: 'Bangladesh',
    language: 'Bengali',
    genres: ['Drama', 'Crime', 'Romance', 'Mystery'],
    synopsis: 'On the flooded banks of a neon megacity, a young detective and the heir of a transport empire collide over a missing ledger that could drown them both. A sweeping crime-romance about family, debt and the price of one more monsoon season.',
    poster: 'assets/images/poster-dhaka.webp',
    rank: 1,
    stream: _sintel,
  ),
  Title(
    id: 'dragon',
    name: "Dragon's Promise",
    kind: 'Movie',
    year: '2025',
    rating: 8.9,
    age: '13+',
    episodes: 1,
    country: 'China',
    language: 'Mandarin',
    genres: ['Action', 'Fantasy', 'Adventure'],
    synopsis: 'A disgraced sword student inherits a dragon egg and one winter to prove she is worthy of the sky clans. A wuxia fantasy of oaths, storms and second chances.',
    poster: 'assets/images/poster-dragon.webp',
    rank: 2,
    stream: _bbb,
  ),
  Title(
    id: 'noir',
    name: 'Monsoon Noir',
    kind: 'Series',
    year: '2025',
    rating: 9.2,
    age: '16+',
    episodes: 16,
    country: 'South Korea',
    language: 'Korean',
    genres: ['K-Drama', 'Thriller', 'Romance'],
    synopsis: 'Every rainy season the same stranger checks into Room 404 and never checks out. A hotel clerk and a cold-case profiler unravel forty years of vanished guests.',
    poster: 'assets/images/poster-noir.webp',
    rank: 3,
    stream: _ed,
  ),
  Title(
    id: 'ronin',
    name: 'Star Ronin',
    kind: 'Anime',
    year: '2026',
    rating: 9.5,
    age: '13+',
    episodes: 24,
    country: 'Japan',
    language: 'Japanese',
    genres: ['Anime', 'Action', 'Sci-Fi'],
    synopsis: 'A masterless samurai drifts between star systems, hiring out his blade to dying colonies while an empire hunts the sword he refuses to draw.',
    poster: 'assets/images/poster-ronin.webp',
    rank: 4,
    stream: _clip,
  ),
  Title(
    id: 'ocean',
    name: 'Ocean Realm',
    kind: 'Series',
    year: '2024',
    rating: 8.7,
    age: '7+',
    episodes: 20,
    country: 'United States',
    language: 'English',
    genres: ['Adventure', 'Family', 'Fantasy'],
    synopsis: 'Beneath the reef lies a drowned kingdom and a map written in whale song. Two siblings, one submarine, and a tide that waits for no one.',
    poster: 'assets/images/poster-ocean.webp',
    rank: 5,
    stream: _bbb,
  ),
  Title(
    id: 'bunny',
    name: 'Bunny Tales',
    kind: 'Anime',
    year: '2024',
    rating: 8.4,
    age: 'All',
    episodes: 12,
    country: 'Japan',
    language: 'Japanese',
    genres: ['Anime', 'Comedy', 'Family'],
    synopsis: 'A very serious bunny runs a very unserious carrot café at the edge of the forest. Short, warm episodes about friendship and second helpings.',
    poster: 'assets/images/poster-bunny.webp',
    rank: 6,
    stream: _clip,
  ),
  Title(
    id: 'dream',
    name: 'Dream Machine',
    kind: 'Movie',
    year: '2023',
    rating: 8.1,
    age: '13+',
    episodes: 1,
    country: 'Netherlands',
    language: 'English',
    genres: ['Sci-Fi', 'Surreal'],
    synopsis: 'Inside an endless factory, a dream engineer discovers one corridor that is not on any blueprint — and something has been dreaming him back.',
    poster: 'assets/images/poster-dream.webp',
    rank: 7,
    stream: _ed,
  ),
];

// --------------------------- local user store -------------------------------

class UserStore {
  static final favs = ValueNotifier<Set<String>>({});
  static final later = ValueNotifier<Set<String>>({});
  static final history = ValueNotifier<List<String>>([]);
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();
    favs.value = (p.getStringList('mb_favs') ?? []).toSet();
    later.value = (p.getStringList('mb_later') ?? []).toSet();
    history.value = p.getStringList('mb_history') ?? [];
  }

  static Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('mb_favs', favs.value.toList());
    await p.setStringList('mb_later', later.value.toList());
    await p.setStringList('mb_history', history.value);
  }

  static void toggleFav(String id) {
    final s = {...favs.value};
    if (!s.remove(id)) s.add(id);
    favs.value = s;
    _save();
  }

  static void toggleLater(String id) {
    final s = {...later.value};
    if (!s.remove(id)) s.add(id);
    later.value = s;
    _save();
  }

  static void touchHistory(String id) {
    final l = [...history.value]..remove(id);
    l.insert(0, id);
    history.value = l.take(20).toList();
    _save();
  }
}

// --------------------------------- app --------------------------------------

class MovieBoxApp extends StatelessWidget {
  const MovieBoxApp({super.key});
  @override
  Widget build(BuildContext context) {
    UserStore.load();
    return MaterialApp(
      title: 'MovieBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(
          surface: kPanel,
          primary: kGreen,
          onSurface: kText,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: kText),
          bodySmall: TextStyle(color: kGrey),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(kBtn),
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: kPanel),
      ),
      home: const HomePage(),
    );
  }
}

// ------------------------------ shared bits ---------------------------------

void openDetail(BuildContext c, Title t) =>
    Navigator.of(c)
        .push(MaterialPageRoute(builder: (_) => DetailPage(title: t)));

void openPlay(BuildContext c, Title t, {int episode = 1, int season = 1}) =>
    Navigator.of(c).push(
      MaterialPageRoute(
        builder: (_) => PlayPage(title: t, episode: episode, season: season),
      ),
    );

void snack(BuildContext c, String msg) => ScaffoldMessenger.of(c).showSnackBar(
  SnackBar(
    content: Text(msg),
    backgroundColor: kPanel,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(milliseconds: 1600),
  ),
);

String metaLine(Title t) =>
    '★ ${t.rating}   ${t.year}   ${t.age}   ${t.isSeries ? '${t.episodes} Episodes' : 'Movie'}   ${t.country}   ${t.genres.join(' ')}   ${t.language}';

class GreenLabel extends StatelessWidget {
  final String text;
  const GreenLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [kGreenA, kGreenB]),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class RatingPill extends StatelessWidget {
  final double rating;
  const RatingPill(this.rating, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    decoration: BoxDecoration(
      color: kGreen,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      '★ $rating',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class AgeChip extends StatelessWidget {
  final String text;
  const AgeChip(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white54),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 11),
    ),
  );
}

class SectionHead extends StatelessWidget {
  final String text;
  const SectionHead(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
    child: Row(
      children: [
        Container(width: 4, height: 20, color: kGreen),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

// ------------------------------ site chrome ---------------------------------

class SiteHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  const SiteHeader({super.key, this.showBack = false});
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kDeep,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
      titleSpacing: 2,
      title: GestureDetector(
        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
        child: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Movie',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 21,
                ),
              ),
              TextSpan(
                text: 'Box',
                style: TextStyle(
                  color: kGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 21,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () =>
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SearchPage())),
        ),
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const StoredPage(kind: 'history'),
            ),
          ),
        ),
        ValueListenableBuilder<Set<String>>(
          valueListenable: UserStore.favs,
          builder: (_, favs, __) => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StoredPage(kind: 'favs'),
                  ),
                ),
              ),
              if (favs.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: kGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${favs.length}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class SiteDrawer extends StatelessWidget {
  const SiteDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    void go(String label, String genre) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LabelPage(label: label, genre: genre),
        ),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: kDeep),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Movie',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                    TextSpan(
                      text: 'Box',
                      style: TextStyle(
                        color: kGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (final (label, genre) in const [
            ('Anime', 'Anime'),
            ('K-Drama', 'K-Drama'),
            ('Movies', 'Movie'),
            ('Series', 'Series'),
            ('Drama', 'Drama'),
            ('Action', 'Action'),
          ])
            ListTile(
              dense: true,
              title: Text(label, style: const TextStyle(color: kText)),
              onTap: () => go(label, genre),
            ),
          const Divider(color: kBtn),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Language',
              style: TextStyle(color: kGrey, fontSize: 12.5),
            ),
          ),
          for (final lang in const [
            'English',
            'Jepang',
            'Bahasa Indonesia',
            'Malaysia',
          ])
            ListTile(
              dense: true,
              title: Text(lang, style: const TextStyle(color: kMenuLink)),
              onTap: () => Navigator.of(context).pop(),
            ),
          const Divider(color: kBtn),
          for (final p in const [
            'About Blog',
            'Media Player',
            'Privacy Policy',
          ])
            ListTile(
              dense: true,
              title: Text(p, style: const TextStyle(color: kMenuLink)),
              onTap: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }
}

/// The chip nav row that sits under the header on the reference site.
class ChipNavRow extends StatelessWidget {
  const ChipNavRow({super.key});
  @override
  Widget build(BuildContext context) {
    const chips = [
      ('Rekomendasi', null),
      ('Anime', 'Anime'),
      ('K-Drama', 'K-Drama'),
      ('Movies', 'Movie'),
      ('Series', 'Series'),
      ('Drama', 'Drama'),
      ('Action', 'Action'),
      ('Romance', 'Romance'),
    ];
    return Container(
      color: kDeep,
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, genre) = chips[i];
          final first = i == 0;
          return InkWell(
            onTap: genre == null
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LabelPage(label: label, genre: genre),
                    ),
                  ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: first ? kGreen : kPanel,
                borderRadius: BorderRadius.circular(16),
                border: first ? null : Border.all(color: Colors.white12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: first ? Colors.black : kText,
                  fontSize: 12.5,
                  fontWeight: first ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: kDeep,
    margin: const EdgeInsets.only(top: 34),
    padding: const EdgeInsets.fromLTRB(18, 26, 18, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Movie',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
              TextSpan(
                text: 'Box',
                style: TextStyle(
                  color: kGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'MovieBox is a UI/UX demo. Browse movies, series, anime and drama in a fast, dark, green-accented theme — the same demo catalogue plays everywhere, on web and in the app.',
          style: TextStyle(color: kFooterText, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in const [
              'About',
              'Media Player',
              'Privacy Policy',
              'Terms of Service',
              'Contact',
              'FAQ',
            ])
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF23252B),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    color: Color(0xFFDDDDDD),
                    fontSize: 12.5,
                  ),
                ),
              ),
          ],
        ),
        const Divider(color: Color(0xFF2D2F34), height: 32),
        const Text(
          '© 2026 MovieBox — UI/UX Demo. All titles are fictional.',
          style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 12),
        ),
      ],
    ),
  );
}

// -------------------------------- home --------------------------------------

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final popular = [...catalog]..sort((a, b) => b.rating.compareTo(a.rating));
    return Scaffold(
      appBar: const SiteHeader(),
      drawer: const SiteDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ListView(
            children: [
              const ChipNavRow(),
              const HeroSlider(),
              const SectionHead('Latest Posts'),
              const SquareGrid(),
              const SectionHead('Popular Posts'),
              for (final t in popular.take(3)) PopularCard(t: t),
              const SectionHead('Top Picks for You'),
              PicksList(items: popular),
              const SectionHead('Browse Labels'),
              const LabelCloud(),
              const SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------ hero slider ---------------------------------

class HeroSlider extends StatefulWidget {
  const HeroSlider({super.key});
  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  final _pc = PageController();
  Timer? _timer;
  int _page = 0;
  final _slides = catalog;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!_pc.hasClients) return;
      final next = (_page + 1) % _slides.length;
      _pc.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => HeroSlide(t: _slides[i]),
          ),
          // numbered playlist overlay, right edge (like the reference slider)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 118,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Color(0xCC0A0C0F)],
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _slides.length,
                itemBuilder: (_, i) {
                  final active = i == _page;
                  final t = _slides[i];
                  return InkWell(
                    onTap: () => _pc.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4.5,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: active ? kGreen : Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              t.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: active ? Colors.white : Colors.white60,
                                fontSize: 10.5,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeroSlide extends StatelessWidget {
  final Title t;
  const HeroSlide({super.key, required this.t});
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(t.backdrop, fit: BoxFit.cover),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xD9111319)],
            stops: [0.45, 1],
          ),
        ),
      ),
      Positioned(
        left: 14,
        right: 128,
        bottom: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GreenLabel(t.kind),
                const SizedBox(width: 6),
                const Text(
                  'Popular Posts',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              t.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                RatingPill(t.rating),
                const SizedBox(width: 8),
                Text(
                  t.year,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 8),
                AgeChip(t.age),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.genres.take(2).join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => openPlay(context, t),
                  icon: const Icon(Icons.play_arrow, size: 19),
                  label: const Text('Play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _CircleBtn(
                  icon: Icons.bookmark_border,
                  onTap: () {
                    UserStore.toggleLater(t.id);
                    snack(context, 'Saved to Watch Later');
                  },
                ),
                const SizedBox(width: 8),
                _CircleBtn(
                  icon: Icons.share_outlined,
                  onTap: () => snack(context, 'Share (demo)'),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    customBorder: const CircleBorder(),
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70, width: 1.2),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}

// --------------------------- square poster grid -----------------------------

class SquareGrid extends StatelessWidget {
  const SquareGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisSpacing: 14,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: catalog.length,
      itemBuilder: (_, i) => SquareCard(t: catalog[i]),
    );
  }
}

class SquareCard extends StatelessWidget {
  final Title t;
  const SquareCard({super.key, required this.t});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => openDetail(context, t),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(t.poster, fit: BoxFit.cover),
              ),
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    t.country,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: UserStore.later,
                  builder: (_, later, __) => IconButton(
                    iconSize: 19,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      later.contains(t.id)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: later.contains(t.id) ? kGreen : Colors.white,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 6),
                      ],
                    ),
                    onPressed: () => UserStore.toggleLater(t.id),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${t.year} • ★ ${t.rating}',
          style: const TextStyle(color: kGrey, fontSize: 11),
        ),
      ],
    ),
  );
}

// ------------------------------ popular card --------------------------------

class PopularCard extends StatelessWidget {
  final Title t;
  const PopularCard({super.key, required this.t});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => openDetail(context, t),
    child: Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
            ),
            child: Image.asset(
              t.poster,
              width: 128,
              height: 148,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 11, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    metaLine(t),
                    style: const TextStyle(
                      color: kGrey,
                      fontSize: 11.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.synopsis,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB9BABE),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ------------------------------- picks list ---------------------------------

class PicksList extends StatelessWidget {
  final List<Title> items;
  const PicksList({super.key, required this.items});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        for (var i = 0; i < items.length; i++)
          InkWell(
            onTap: () => openDetail(context, items[i]),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: kGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      items[i].poster,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '★ ${items[i].rating} • ${items[i].year} • ${items[i].kind}',
                          style: const TextStyle(color: kGrey, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: kGrey, size: 20),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class LabelCloud extends StatelessWidget {
  const LabelCloud({super.key});
  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final t in catalog) {
      for (final g in t.genres) {
        counts[g] = (counts[g] ?? 0) + 1;
      }
      counts[t.kind] = (counts[t.kind] ?? 0) + 1;
    }
    final labels = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in labels)
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LabelPage(label: e.key, genre: e.key),
                ),
              ),
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kBtn,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${e.key} (${e.value})',
                  style: const TextStyle(color: kText, fontSize: 12.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------- detail -------------------------------------

class DetailPage extends StatefulWidget {
  final Title title;
  const DetailPage({super.key, required this.title});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _expanded = false;
  int _season = 1;

  @override
  Widget build(BuildContext context) {
    final t = widget.title;
    final seasons = t.isSeries ? (t.episodes > 20 ? 2 : 1) : 0;
    final epsThisSeason = seasons == 2
        ? (_season == 1 ? 14 : t.episodes - 14)
        : t.episodes;
    final related = catalog
        .where((x) => x.id != t.id && x.genres.any(t.genres.contains))
        .toList();
    final recs = related.isEmpty
        ? catalog.where((x) => x.id != t.id).toList()
        : related;
    return Scaffold(
      appBar: const SiteHeader(showBack: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ListView(
            children: [
              const ChipNavRow(),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(t.backdrop, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, kBg],
                          stops: [0.55, 1],
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () => openPlay(context, t),
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: kGreen.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.asset(
                            t.poster,
                            width: 96,
                            height: 136,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  GreenLabel(t.kind),
                                  for (final g in t.genres.take(3))
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        g,
                                        style: const TextStyle(
                                          color: kText,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Popularity Rank #${t.rank} • 0 Comments • Last updated Oct 18, 2026',
                                style: const TextStyle(
                                  color: kGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                metaLine(t),
                                style: const TextStyle(
                                  color: kGrey,
                                  fontSize: 12,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => openPlay(context, t),
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: Text(t.isSeries ? 'Play Episode 1' : 'Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ValueListenableBuilder<Set<String>>(
                          valueListenable: UserStore.later,
                          builder: (_, later, __) => ActionBtn(
                            icon: later.contains(t.id)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            label: 'Watch Later',
                            active: later.contains(t.id),
                            onTap: () {
                              final was = later.contains(t.id);
                              UserStore.toggleLater(t.id);
                              snack(
                                context,
                                was
                                    ? 'Removed from Watch Later'
                                    : 'Saved to Watch Later',
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 9),
                        ValueListenableBuilder<Set<String>>(
                          valueListenable: UserStore.favs,
                          builder: (_, favs, __) => ActionBtn(
                            icon: favs.contains(t.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label: 'Favorite',
                            active: favs.contains(t.id),
                            onTap: () => UserStore.toggleFav(t.id),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Deskripsi :',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.synopsis,
                      maxLines: _expanded ? null : 3,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFC9CACD),
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        child: Text(
                          _expanded ? 'Show less' : 'Show all',
                          style: const TextStyle(color: kGreen),
                        ),
                      ),
                    ),
                    const ShareRow(),
                    if (t.isSeries) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Episodes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          if (seasons == 2)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: kBtn,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton<int>(
                                value: _season,
                                underline: const SizedBox(),
                                dropdownColor: kPanel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('Season 1'),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text('Season 2'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _season = v ?? 1),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var e = 1; e <= epsThisSeason; e++)
                            InkWell(
                              onTap: () => openPlay(
                                context,
                                t,
                                episode: e,
                                season: _season,
                              ),
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                width: 52,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: kBtn,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '$e',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SectionHead('Recommendation for you'),
              PosterRail(items: recs),
              const SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const ActionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: kBtn,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, color: active ? kGreen : Colors.white, size: 20),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: kText, fontSize: 10.5)),
        ],
      ),
    ),
  );
}

class ShareRow extends StatelessWidget {
  const ShareRow({super.key});
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.facebook, 'Facebook'),
      (Icons.share, 'Twitter'),
      (Icons.chat, 'WhatsApp'),
      (Icons.send, 'Telegram'),
      (Icons.mail_outline, 'Email'),
      (Icons.link, 'Copy'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (icon, label) in items)
              InkWell(
                onTap: () => snack(
                  context,
                  label == 'Copy' ? 'Link copied' : 'Share via $label (demo)',
                ),
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kBtn,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: const TextStyle(color: kText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class PosterRail extends StatelessWidget {
  final List<Title> items;
  const PosterRail({super.key, required this.items});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 216,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 11),
      itemBuilder: (_, i) => PosterCard(t: items[i]),
    ),
  );
}

class PosterCard extends StatelessWidget {
  final Title t;
  final double w;
  const PosterCard({super.key, required this.t, this.w = 112});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => openDetail(context, t),
    child: SizedBox(
      width: w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.asset(
              t.poster,
              width: w,
              height: w * 1.42,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${t.year} • ★ ${t.rating}',
            style: const TextStyle(color: kGrey, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

// -------------------------------- play --------------------------------------

class PlayPage extends StatefulWidget {
  final Title title;
  final int episode, season;
  const PlayPage({
    super.key,
    required this.title,
    this.episode = 1,
    this.season = 1,
  });
  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  late int _ep = widget.episode;
  late int _season = widget.season;
  int _server = 1;
  bool _expanded = false;
  VideoPlayerController? _ctrl;
  bool _ready = false, _playing = false, _showUi = true;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    UserStore.touchHistory(widget.title.id);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.title.stream));
    _ctrl = c;
    await c.initialize();
    if (!mounted) return;
    setState(() => _ready = true);
    c.addListener(() {
      if (mounted) setState(() => _playing = c.value.isPlaying);
    });
    c.play();
    _armHide();
  }

  void _armHide() {
    _hide?.cancel();
    _hide = Timer(const Duration(seconds: 3), () {
      if (mounted && (_ctrl?.value.isPlaying ?? false)) {
        setState(() => _showUi = false);
      }
    });
  }

  @override
  void dispose() {
    _hide?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.title;
    final recs = catalog.where((x) => x.id != t.id).toList();
    final seasons = t.isSeries ? (t.episodes > 20 ? 2 : 1) : 0;
    final epsThisSeason = seasons == 2
        ? (_season == 1 ? 14 : t.episodes - 14)
        : t.episodes;
    return Scaffold(
      appBar: const SiteHeader(showBack: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: !_ready
                      ? const Center(
                          child: CircularProgressIndicator(color: kGreen),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() => _showUi = !_showUi);
                            _armHide();
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Center(
                                child: AspectRatio(
                                  aspectRatio: _ctrl!.value.aspectRatio,
                                  child: VideoPlayer(_ctrl!),
                                ),
                              ),
                              if (_showUi) ...[
                                Container(color: Colors.black26),
                                Center(
                                  child: IconButton(
                                    iconSize: 66,
                                    icon: Icon(
                                      _playing
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (_playing) {
                                        _ctrl!.pause();
                                      } else {
                                        _ctrl!.play();
                                      }
                                      _armHide();
                                    },
                                  ),
                                ),
                                Positioned(
                                  left: 6,
                                  right: 6,
                                  bottom: 2,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          _playing
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          if (_playing) {
                                            _ctrl!.pause();
                                          } else {
                                            _ctrl!.play();
                                          }
                                          _armHide();
                                        },
                                      ),
                                      Text(
                                        '${_fmt(_ctrl!.value.position)} / ${_fmt(_ctrl!.value.duration)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                      Expanded(
                                        child: VideoProgressIndicator(
                                          _ctrl!,
                                          allowScrubbing: true,
                                          colors: const VideoProgressColors(
                                            playedColor: kProgress,
                                            bufferedColor: Colors.white24,
                                            backgroundColor: Colors.white12,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.fullscreen,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (_) => FullPlayerPage(
                                                  ctrl: _ctrl!,
                                                  title:
                                                      '${t.name} — Episode $_ep',
                                                ),
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ValueListenableBuilder<Set<String>>(
                          valueListenable: UserStore.later,
                          builder: (_, later, __) => ActionBtn(
                            icon: later.contains(t.id)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            label: 'Watch Later',
                            active: later.contains(t.id),
                            onTap: () => UserStore.toggleLater(t.id),
                          ),
                        ),
                        const SizedBox(width: 9),
                        ValueListenableBuilder<Set<String>>(
                          valueListenable: UserStore.favs,
                          builder: (_, favs, __) => ActionBtn(
                            icon: favs.contains(t.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label: 'Favorite',
                            active: favs.contains(t.id),
                            onTap: () => UserStore.toggleFav(t.id),
                          ),
                        ),
                        const SizedBox(width: 9),
                        ActionBtn(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          active: false,
                          onTap: () => snack(context, 'Share (demo)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      t.isSeries
                          ? '${t.name} — Season $_season Episode $_ep'
                          : t.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      metaLine(t),
                      style: const TextStyle(color: kGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Server:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        for (var s = 1; s <= 2; s++) ...[
                          InkWell(
                            onTap: () => setState(() => _server = s),
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _server == s ? kGreen : kBtn,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Server $s',
                                style: TextStyle(
                                  color: _server == s
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    if (t.isSeries) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '${t.name} Episodes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          if (seasons == 2)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: kBtn,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton<int>(
                                value: _season,
                                underline: const SizedBox(),
                                dropdownColor: kPanel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('Season 1'),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text('Season 2'),
                                  ),
                                ],
                                onChanged: (v) => setState(() {
                                  _season = v ?? 1;
                                  _ep = 1;
                                }),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var e = 1; e <= epsThisSeason; e++)
                            InkWell(
                              onTap: () => setState(() => _ep = e),
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                width: 48,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: kBtn,
                                  border: Border.all(
                                    color: e == _ep
                                        ? kGreen
                                        : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '$e',
                                  style: TextStyle(
                                    color: e == _ep ? kGreen : Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Deskripsi :',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.synopsis,
                      maxLines: _expanded ? null : 3,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFC9CACD),
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        child: Text(
                          _expanded ? 'Show less' : 'Show all',
                          style: const TextStyle(color: kGreen),
                        ),
                      ),
                    ),
                    const ShareRow(),
                  ],
                ),
              ),
              const SectionHead('Recommendation for you'),
              PosterRail(items: recs),
              const SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class FullPlayerPage extends StatelessWidget {
  final VideoPlayerController ctrl;
  final String title;
  const FullPlayerPage({super.key, required this.ctrl, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text(title, style: const TextStyle(fontSize: 15)),
    ),
    body: Center(
      child: AspectRatio(
        aspectRatio: ctrl.value.aspectRatio,
        child: VideoPlayer(ctrl),
      ),
    ),
  );
}

// ------------------------- search / label / stored --------------------------

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final res = _q.isEmpty
        ? catalog
        : catalog
              .where(
                (t) =>
                    t.name.toLowerCase().contains(_q.toLowerCase()) ||
                    t.genres.any(
                      (g) => g.toLowerCase().contains(_q.toLowerCase()),
                    ),
              )
              .toList();
    return Scaffold(
      appBar: const SiteHeader(showBack: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _q = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search movies, series, anime, drama…',
                    hintStyle: const TextStyle(color: kGrey),
                    prefixIcon: const Icon(Icons.search, color: kGrey),
                    filled: true,
                    fillColor: kPanel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(child: PosterGrid(items: res)),
            ],
          ),
        ),
      ),
    );
  }
}

class PosterGrid extends StatelessWidget {
  final List<Title> items;
  const PosterGrid({super.key, required this.items});
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Nothing here yet.',
          style: TextStyle(color: kGrey, fontSize: 15),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        mainAxisSpacing: 14,
        crossAxisSpacing: 11,
        childAspectRatio: 0.56,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => PosterCard(t: items[i], w: 150),
    );
  }
}

class LabelPage extends StatelessWidget {
  final String label, genre;
  const LabelPage({super.key, required this.label, required this.genre});
  @override
  Widget build(BuildContext context) {
    final items = catalog
        .where((t) => t.genres.contains(genre) || t.kind == genre)
        .toList();
    return Scaffold(
      appBar: const SiteHeader(showBack: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHead(label),
              Expanded(child: PosterGrid(items: items)),
            ],
          ),
        ),
      ),
    );
  }
}

class StoredPage extends StatelessWidget {
  final String kind; // favs | history
  const StoredPage({super.key, required this.kind});
  @override
  Widget build(BuildContext context) {
    final heading = kind == 'favs' ? 'Favorite' : 'History';
    return Scaffold(
      appBar: const SiteHeader(showBack: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHead(heading),
              Expanded(
                child: kind == 'favs'
                    ? ValueListenableBuilder<Set<String>>(
                        valueListenable: UserStore.favs,
                        builder: (_, favs, __) => PosterGrid(
                          items: catalog
                              .where((t) => favs.contains(t.id))
                              .toList(),
                        ),
                      )
                    : ValueListenableBuilder<List<String>>(
                        valueListenable: UserStore.history,
                        builder: (_, hist, __) => PosterGrid(
                          items: hist
                              .map(
                                (id) => catalog
                                    .where((t) => t.id == id)
                                    .firstOrNull,
                              )
                              .whereType<Title>()
                              .toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
