import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

// ---------------------------------------------------------------------------
// MovieBox — UI/UX demo rebuilt in the style of the iQONE video-blog theme
// (dark #111319 surfaces, signature green #1CC749 accent). Original demo
// content only.
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

class GreenLabel extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const GreenLabel(this.text, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kGreenA, kGreenB]),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class GreyChip extends StatelessWidget {
  final String text;
  const GreyChip(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: const TextStyle(color: kText, fontSize: 11.5)),
  );
}

class SectionHead extends StatelessWidget {
  final String text;
  final VoidCallback? onMore;
  const SectionHead(this.text, {super.key, this.onMore});
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
        const Spacer(),
        if (onMore != null)
          TextButton(
            onPressed: onMore,
            child: const Text(
              'More',
              style: TextStyle(color: kGreen, fontSize: 13),
            ),
          ),
      ],
    ),
  );
}

String metaLine(Title t) =>
    '★ ${t.rating}   ${t.year}   ${t.age}   ${t.isSeries ? '${t.episodes} Episodes' : 'Movie'}   ${t.country}   ${t.genres.join(' ')}   ${t.language}';

// ------------------------------ site header ---------------------------------

class SiteHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  const SiteHeader({super.key, this.showBack = false});
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 760;
    return AppBar(
      backgroundColor: kDeep,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      titleSpacing: showBack ? 0 : 16,
      title: Row(
        children: [
          GestureDetector(
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
          if (wide) ...[
            const SizedBox(width: 34),
            for (final (label, genre) in const [
              ('Anime', 'Anime'),
              ('K-Drama', 'K-Drama'),
              ('Movies', 'Movie'),
              ('Series', 'Series'),
              ('Drama', 'Drama'),
            ])
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LabelPage(label: label, genre: genre),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: kMenuLink, fontSize: 14.5),
                  ),
                ),
              ),
          ],
        ],
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
        const SizedBox(width: 6),
      ],
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
    final top10 = [...catalog]..sort((a, b) => a.rank.compareTo(b.rank));
    return Scaffold(
      appBar: const SiteHeader(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ListView(
            children: [
              const HeroSlider(),
              const SectionHead('Popular Posts'),
              for (final t in popular.take(3)) PopularCard(t: t),
              const SectionHead('Top 10 Today'),
              SizedBox(
                height: 218,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: top10.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => RankCard(t: top10[i]),
                ),
              ),
              const SectionHead('Top Picks for You'),
              PosterRail(items: catalog.reversed.toList()),
              const SectionHead('Original'),
              LandscapeRail(items: catalog),
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

class HeroSlider extends StatefulWidget {
  const HeroSlider({super.key});
  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  final _pc = PageController();
  Timer? _timer;
  int _page = 0;
  final _slides = catalog.take(4).toList();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
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
    final h = MediaQuery.of(context).size.width > 760 ? 430.0 : 470.0;
    return SizedBox(
      height: h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => HeroSlide(t: _slides[i]),
          ),
          Positioned(
            bottom: 14,
            right: 16,
            child: Row(
              children: [
                for (var i = 0; i < _slides.length; i++)
                  Container(
                    width: i == _page ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                      color: i == _page ? kGreen : Colors.white30,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
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
      Image.asset(t.poster, fit: BoxFit.cover),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xE6111319), kBg],
            stops: [0.25, 0.78, 1],
          ),
        ),
      ),
      Positioned(
        left: 16,
        right: 16,
        bottom: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreenLabel('Trending #${t.rank}'),
            const SizedBox(height: 10),
            Text(
              t.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              metaLine(t),
              style: const TextStyle(color: kText, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final g in t.genres) GreyChip(g)],
            ),
            const SizedBox(height: 10),
            Text(
              t.synopsis,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFC9CACD),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => openPlay(context, t),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Watch Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => openDetail(context, t),
                  icon: const Icon(Icons.info_outline, size: 19),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: kBtn.withValues(alpha: 0.85),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

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

class RankCard extends StatelessWidget {
  final Title t;
  const RankCard({super.key, required this.t});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => openDetail(context, t),
    child: SizedBox(
      width: 118,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  t.poster,
                  width: 104,
                  height: 156,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: -7,
                bottom: -8,
                child: Text(
                  '${t.rank}',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2.2
                      ..color = kGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              t.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
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

class LandscapeRail extends StatelessWidget {
  final List<Title> items;
  const LandscapeRail({super.key, required this.items});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 158,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final t = items[i];
        return GestureDetector(
          onTap: () => openDetail(context, t),
          child: SizedBox(
            width: 218,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    t.poster,
                    width: 218,
                    height: 116,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${t.kind} • ${t.year}',
                  style: const TextStyle(color: kGrey, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
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
              SizedBox(
                height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(t.poster, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x55111319), kBg],
                          stops: [0.35, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
                            width: 104,
                            height: 148,
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
                                  fontSize: 24,
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
                                  for (final g in t.genres.take(3)) GreyChip(g),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Popularity Rank #${t.rank}',
                                style: const TextStyle(
                                  color: kGreen,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
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
                    Row(
                      children: [
                        Expanded(
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
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
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
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text(
                            'Episodes',
                            style: TextStyle(
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
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: epsThisSeason,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final e = i + 1;
                            final active = e == _ep;
                            return InkWell(
                              onTap: () => setState(() => _ep = e),
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                width: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: active ? kGreen : kBtn,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '$e',
                                  style: TextStyle(
                                    color: active ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
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
                      ],
                    ),
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
