import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

// ---------------------------------------------------------------------------
// MovieBox — UI/UX demo recreating the iQONE video-blog theme's mobile
// layout block-for-block: black header with green-gradient logo tile, pale
// visitor-stat cards, 16:9 hero slider (green tag, TONTON / TRAILER),
// marquee strip, "Sedang Trending" landscape cards, poster grids with green
// badges, rich footer; detail page with green-label meta rows, server +
// episode pickers; intl-style play page. Original demo content only.
// ---------------------------------------------------------------------------

const kBg = Color(0xFF111319);
const kPanel = Color(0xFF1A1C22);
const kDeep = Color(0xFF0A0C0F);
const kCard = Color(0xFF1E2129);
const kBtn = Color(0xFF2D2F34);
const kGreen = Color(0xFF1CC749);
const kGreenA = Color(0xFF00D639);
const kGreenB = Color(0xFF00C234);
const kProgress = Color(0xFF1ECA95);
const kText = Color(0xFFECECEC);
const kGrey = Color(0xFF9A9CA3);
const kFooterText = Color(0xFF999999);

void main() => runApp(const MovieBoxApp());

// ------------------------------- data --------------------------------------

class Title {
  final String id, name, kind, year, age, country, language, synopsis, poster;
  final double rating;
  final int episodes, rank;
  final List<String> genres;
  final String stream;
  final String duration, status, studio, director, views, airing;
  final List<String> cast;
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
    this.duration = '24m',
    this.status = 'Ongoing',
    this.studio = 'Nova Works',
    this.director = 'A. Rahman',
    this.views = '1.2M',
    this.airing = '2026',
    this.cast = const ['Rafi', 'Nusrat', 'Tanvir', 'Mim', 'Arif'],
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
    duration: '45m',
    status: 'Ongoing',
    studio: 'Dhaka Pictures',
    director: 'S. Chowdhury',
    views: '4.8M',
    airing: 'Jan 2026',
    cast: ['Rafiul', 'Nusrat', 'Tanvir', 'Mim', 'Arifin'],
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
    duration: '1j 58m',
    status: 'Selesai',
    studio: 'Sky Clan Films',
    director: 'L. Wei',
    views: '2.1M',
    airing: 'Mar 2025',
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
    duration: '52m',
    status: 'Selesai',
    studio: 'Seoul Noir Co.',
    director: 'K. Ji-woo',
    views: '3.4M',
    airing: 'Jun 2025',
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
    duration: '24m',
    status: 'Ongoing',
    studio: 'Studio Kaze',
    director: 'H. Mori',
    views: '5.6M',
    airing: 'Apr 2026',
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
    duration: '38m',
    status: 'Selesai',
    studio: 'Blue Reef',
    director: 'J. Marlin',
    views: '1.7M',
    airing: 'Sep 2024',
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
    duration: '11m',
    status: 'Selesai',
    studio: 'Mori Animation',
    director: 'Y. Hana',
    views: '980K',
    airing: 'Jan 2024',
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
    duration: '1j 24m',
    status: 'Selesai',
    studio: 'Fabriek Films',
    director: 'P. Vos',
    views: '640K',
    airing: 'Nov 2023',
  ),
];

const epTitles = [
  'Awal Perjalanan',
  'Bayangan Masa Lalu',
  'Pertemuan Tak Terduga',
  'Rahasia Terungkap',
  'Badai Datang',
  'Jejak yang Hilang',
  'Keputusan Sulit',
  'Cahaya di Ujung Jalan',
  'Pengkhianatan',
  'Kembali Pulang',
  'Babak Baru',
  'Akhir dan Awal',
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

void openPlay(BuildContext c, Title t, {int episode = 1}) => Navigator.of(c)
    .push(
      MaterialPageRoute(
        builder: (_) => PlayPage(title: t, episode: episode),
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

/// Section heading: white bold text + short green underline bar.
class SectionHead extends StatelessWidget {
  final String text;
  final String? moreLabel;
  final VoidCallback? onMore;
  const SectionHead(this.text, {super.key, this.moreLabel, this.onMore});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 64,
              height: 3,
              decoration: BoxDecoration(
                color: kGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const Spacer(),
        if (moreLabel != null)
          GestureDetector(
            onTap: onMore,
            child: Text(
              moreLabel!,
              style: const TextStyle(color: kGreen, fontSize: 12.5),
            ),
          ),
      ],
    ),
  );
}

class StarPill extends StatelessWidget {
  final double rating;
  const StarPill(this.rating, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: kGreen,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 11, color: Colors.black),
        const SizedBox(width: 3),
        Text(
          '$rating',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class GreenTag extends StatelessWidget {
  final String text;
  const GreenTag(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: kGreen,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class GreenOutlinePill extends StatelessWidget {
  final String text;
  const GreenOutlinePill(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      border: Border.all(color: kGreen),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: kGreen,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class Breadcrumb extends StatelessWidget {
  final List<String> items;
  const Breadcrumb(this.items, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
    child: Text(
      items.join('  /  '),
      style: const TextStyle(color: kGrey, fontSize: 12.5),
    ),
  );
}

// ------------------------------ site chrome ---------------------------------

class LogoLockup extends StatelessWidget {
  final double tile;
  const LogoLockup({super.key, this.tile = 30});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: tile,
        height: tile,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kGreenA, kGreenB],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          'MB',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: tile * 0.42,
          ),
        ),
      ),
      const SizedBox(width: 8),
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
    ],
  );
}

class SiteHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  const SiteHeader({super.key, this.showBack = false});
  @override
  Size get preferredSize => const Size.fromHeight(54);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      titleSpacing: showBack ? 0 : 14,
      title: GestureDetector(
        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
        child: const LogoLockup(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () =>
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SearchPage())),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});
  @override
  Widget build(BuildContext context) {
    void go(String label, String genre) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LabelPage(label: label, genre: genre),
      ),
    );
    Widget link(String s, VoidCallback? onTap) => GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          s,
          style: const TextStyle(color: kFooterText, fontSize: 13),
        ),
      ),
    );
    Widget footHead(String s) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Container(width: 44, height: 3, color: kGreen),
        const SizedBox(height: 10),
      ],
    );
    return Column(
      children: [
        Container(
          color: Colors.black,
          margin: const EdgeInsets.only(top: 36),
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoLockup(tile: 34),
              const SizedBox(height: 12),
              const Text(
                'Tempat nonton film dan series terbaru dengan subtitle Indonesia. Update setiap hari dengan kualitas HD dan server tercepat. (Demo UI/UX — semua judul fiktif.)',
                style: TextStyle(
                  color: kFooterText,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final ic in const [
                    Icons.facebook,
                    Icons.camera_alt_outlined,
                    Icons.send,
                    Icons.play_circle_outline,
                    Icons.alternate_email,
                  ])
                    Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(right: 9),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C1C1E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(ic, size: 16, color: Colors.white70),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        footHead('Jelajahi'),
                        link(
                          'Home',
                          () =>
                              Navigator.of(context).popUntil((r) => r.isFirst),
                        ),
                        link('Sedang Trending', null),
                        link('Film Terbaru', () => go('Movies', 'Movie')),
                        link('Series Terbaru', () => go('Series', 'Series')),
                        link('Segera Tayang', null),
                        link(
                          'History',
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StoredPage(kind: 'history'),
                            ),
                          ),
                        ),
                        link(
                          'Favorite',
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StoredPage(kind: 'favs'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        footHead('Bantuan'),
                        link('FAQ', null),
                        link('DMCA', null),
                        link('Kebijakan Privasi', null),
                        link('Syarat & Ketentuan', null),
                        link('Hubungi Kami', null),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              footHead('Kategori Populer'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in const [
                    'Action',
                    'Anime',
                    'Drama',
                    'Romance',
                    'K-Drama',
                    'Sci-Fi',
                    'Adventure',
                    'Comedy',
                  ])
                    InkWell(
                      onTap: () => go(g, g),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          g,
                          style: const TextStyle(
                            color: Color(0xFFDDDDDD),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Pembayaran:',
                style: TextStyle(color: kGrey, fontSize: 12),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final p in const [
                    'BCA',
                    'Mandiri',
                    'Qris',
                    'OVO',
                    'DANA',
                  ])
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Container(
          color: const Color(0xFF050607),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: const Column(
            children: [
              Text(
                '© 2026 MovieBox — UI/UX Demo. All titles are fictional.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
              ),
              SizedBox(height: 5),
              Text(
                'Privacy • Terms • Sitemap',
                style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------------------- home --------------------------------------

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final byRating = [...catalog]..sort((a, b) => b.rating.compareTo(a.rating));
    return Scaffold(
      appBar: const SiteHeader(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ListView(
            children: [
              const StatStrip(),
              const HeroSlider(),
              const MarqueeStrip(),
              SectionHead(
                'Sedang Trending',
                moreLabel: 'Lihat Semua >>',
                onMore: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const LabelPage(label: 'Trending', genre: ''),
                  ),
                ),
              ),
              TrendingRow(items: byRating),
              SectionHead(
                'Film & Series Terbaru',
                moreLabel: 'Lihat Semua >>',
                onMore: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const LabelPage(label: 'Terbaru', genre: ''),
                  ),
                ),
              ),
              PosterGridV5(items: catalog),
              SectionHead(
                'Segera Tayang',
                moreLabel: 'Lihat Semua >>',
                onMore: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const LabelPage(label: 'Segera Tayang', genre: ''),
                  ),
                ),
              ),
              const ComingSoonGrid(),
              const SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class StatStrip extends StatelessWidget {
  const StatStrip({super.key});
  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Online', '512', 'Pengguna aktif sekarang', Color(0xFFE53935)),
      ('Pengunjung Hari ini', '126', 'Kunjungan hari ini', Color(0xFF2E9E4F)),
      ('Kemarin', '1.247', 'Kunjungan kemarin', Color(0xFF1565C0)),
      (
        'Total Pengunjung',
        '35.626',
        'Total semua kunjungan',
        Color(0xFFEF6C00),
      ),
    ];
    return Container(
      color: const Color(0xFF0D0F13),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 9,
          crossAxisSpacing: 9,
          childAspectRatio: 2.35,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) {
          final (label, value, sub, color) = stats[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9AA0A6),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MarqueeStrip extends StatefulWidget {
  const MarqueeStrip({super.key});
  @override
  State<MarqueeStrip> createState() => _MarqueeStripState();
}

class _MarqueeStripState extends State<MarqueeStrip> {
  final _sc = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!_sc.hasClients) return;
      final max = _sc.position.maxScrollExtent;
      if (max <= 0) return;
      final next = _sc.offset + 1.1;
      _sc.jumpTo(next >= max ? 0 : next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black,
    height: 38,
    child: Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: Text(
            'Text Berjalan:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            controller: _sc,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              Center(
                child: Text(
                  'Selamat datang di MovieBox — nonton film & series terbaru subtitle Indonesia, update setiap hari. Gunakan Server HD untuk kualitas terbaik. Gabung grup Telegram kami untuk request film favoritmu!',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Text(
            'NEW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
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
  final _slides = catalog.take(4).toList();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!_pc.hasClients) return;
      _pc.animateToPage(
        (_page + 1) % _slides.length,
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
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page ? Colors.white : Colors.white38,
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
      Image.asset(t.backdrop, fit: BoxFit.cover),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xE60B0D10)],
            stops: [0.35, 1],
          ),
        ),
      ),
      Positioned(
        left: 14,
        right: 14,
        bottom: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GreenTag(t.year),
            const SizedBox(height: 6),
            Text(
              t.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: kGreen),
                const SizedBox(width: 3),
                Text(
                  '${t.rating}',
                  style: const TextStyle(
                    color: kGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  t.year,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
                const SizedBox(width: 9),
                if (t.isSeries) ...[
                  GreenOutlinePill('${t.episodes} EPISODE'),
                  const SizedBox(width: 7),
                  GreenOutlinePill(
                    t.status == 'Ongoing' ? 'ONGOING' : 'SELESAI',
                  ),
                ] else
                  const GreenOutlinePill('MOVIE'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => openPlay(context, t),
                  icon: const Icon(Icons.download, size: 17),
                  label: const Text('TONTON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                OutlinedButton.icon(
                  onPressed: () => openDetail(context, t),
                  icon: const Icon(Icons.play_arrow, size: 17),
                  label: const Text('TRAILER'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGreen,
                    side: const BorderSide(color: kGreen, width: 1.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
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

// ----------------------------- trending row ---------------------------------

class TrendingRow extends StatelessWidget {
  final List<Title> items;
  const TrendingRow({super.key, required this.items});
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
            width: 168,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SizedBox(
                    width: 168,
                    height: 104,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(t.backdrop, fit: BoxFit.cover),
                        Positioned(left: 6, top: 6, child: StarPill(t.rating)),
                        if (t.isSeries)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'EPS ${t.episodes}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                              stops: [0.55, 1],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 5,
                          child: Text(
                            (i + 1).toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 42,
                          right: 6,
                          bottom: 8,
                          child: Text(
                            t.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${t.country} • ${t.year}',
                  style: const TextStyle(color: kGrey, fontSize: 11.5),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ----------------------------- poster grids ---------------------------------

class PosterGridV5 extends StatelessWidget {
  final List<Title> items;
  final bool shrink;
  const PosterGridV5({super.key, required this.items, this.shrink = true});
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: shrink,
    physics: shrink ? const NeverScrollableScrollPhysics() : null,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 14,
      crossAxisSpacing: 10,
      childAspectRatio: 0.52,
    ),
    itemCount: items.length,
    itemBuilder: (_, i) => PosterBadgeCard(t: items[i]),
  );
}

class PosterBadgeCard extends StatelessWidget {
  final Title t;
  final String? rightBadge;
  final String? bottomLine;
  const PosterBadgeCard({
    super.key,
    required this.t,
    this.rightBadge,
    this.bottomLine,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => openDetail(context, t),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(t.poster, fit: BoxFit.cover),
              ),
              Positioned(left: 5, top: 5, child: StarPill(t.rating)),
              Positioned(
                right: 5,
                top: 5,
                child: GreenTag(rightBadge ?? t.kind.toUpperCase()),
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
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          bottomLine ?? '${t.year} • ${t.kind} • ${t.duration}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kGrey, fontSize: 10.5),
        ),
      ],
    ),
  );
}

class ComingSoonGrid extends StatelessWidget {
  const ComingSoonGrid({super.key});
  @override
  Widget build(BuildContext context) {
    const dates = {
      'ronin': 'Tayang: 15 Jan 2027',
      'dhaka2077': 'Tayang: 02 Feb 2027',
      'ocean': 'Tayang: 21 Feb 2027',
    };
    final items = catalog.where((t) => dates.containsKey(t.id)).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 10,
        childAspectRatio: 0.52,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => PosterBadgeCard(
        t: items[i],
        rightBadge: 'SEGERA',
        bottomLine: dates[items[i].id],
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
  int _server = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.title;
    final wide = MediaQuery.of(context).size.width > 760;
    final recs = catalog.where((x) => x.id != t.id).take(4).toList();
    final posterBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            t.poster,
            width: wide ? 220 : double.infinity,
            height: wide ? 320 : 300,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'SHARE:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            for (final ic in const [
              Icons.facebook,
              Icons.share,
              Icons.chat,
              Icons.send,
              Icons.link,
            ])
              GestureDetector(
                onTap: () => snack(context, 'Share (demo)'),
                child: Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(right: 7),
                  decoration: BoxDecoration(
                    color: kBtn,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(ic, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ],
    );
    final infoBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, size: 17, color: kGreen),
            const SizedBox(width: 4),
            Text(
              '${t.rating}/10',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '(1.234 penilaian)',
              style: TextStyle(color: kGrey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final (k, v) in [
          ('Status', t.status),
          ('Tipe', t.kind),
          ('Studio', t.studio),
          ('Sutradara', t.director),
          ('Tayang', t.airing),
          ('Durasi', t.isSeries ? '${t.duration} / episode' : t.duration),
          ('Negara', t.country),
          ('Bahasa', t.language),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 86,
                  child: Text(
                    k,
                    style: const TextStyle(
                      color: kGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    v,
                    style: const TextStyle(color: kText, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 86,
                child: Text(
                  'Genre',
                  style: TextStyle(
                    color: kGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  t.genres.join(', '),
                  style: const TextStyle(color: kGreen, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 86,
                child: Text(
                  'Pengisi Suara',
                  style: TextStyle(
                    color: kGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  t.cast.join(', '),
                  style: const TextStyle(color: kText, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'SINOPSIS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Container(width: 52, height: 3, color: kGreen),
        const SizedBox(height: 9),
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
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              _expanded ? 'Tutup' : 'Baca Selengkapnya',
              style: const TextStyle(color: kGreen, fontSize: 12.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: () => openPlay(context, t),
              icon: const Icon(Icons.play_arrow, size: 19),
              label: const Text('TONTON SEKARANG'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ),
            ValueListenableBuilder<Set<String>>(
              valueListenable: UserStore.later,
              builder: (_, later, __) => OutlinedButton.icon(
                onPressed: () => UserStore.toggleLater(t.id),
                icon: Icon(
                  later.contains(t.id) ? Icons.check : Icons.add,
                  size: 18,
                ),
                label: Text(
                  later.contains(t.id) ? 'DI DAFTAR SAYA' : 'DAFTAR SAYA',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGreen,
                  side: const BorderSide(color: kGreen, width: 1.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
    return Scaffold(
      appBar: const SiteHeader(showBack: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ListView(
            children: [
              Breadcrumb(['Home', t.kind, t.name]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kPanel,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 220, child: posterBlock),
                            const SizedBox(width: 18),
                            Expanded(child: infoBlock),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            posterBlock,
                            const SizedBox(height: 16),
                            infoBlock,
                          ],
                        ),
                ),
              ),
              if (t.isSeries) ...[
                const SectionHead('EPISODE'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PILIH SERVER:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var s = 0; s < 4; s++)
                            InkWell(
                              onTap: () => setState(() => _server = s),
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: _server == s
                                      ? kGreen
                                      : Colors.transparent,
                                  border: Border.all(color: kGreen, width: 1.2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  s == 0 ? 'Server HD' : 'Server ${s + 1}',
                                  style: TextStyle(
                                    color: _server == s ? Colors.black : kGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 74,
                              mainAxisSpacing: 9,
                              crossAxisSpacing: 9,
                              childAspectRatio: 0.92,
                            ),
                        itemCount: t.episodes > 12 ? 12 : t.episodes,
                        itemBuilder: (_, i) {
                          final e = i + 1;
                          final first = e == 1;
                          return InkWell(
                            onTap: () => openPlay(context, t, episode: e),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              decoration: BoxDecoration(
                                color: first ? kGreen : kCard,
                                border: Border.all(
                                  color: first ? kGreen : Colors.white12,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$e',
                                    style: TextStyle(
                                      color: first
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'Unduh',
                                    style: TextStyle(
                                      color: first ? Colors.black54 : kGreen,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => openPlay(context, t),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kGreen,
                            side: const BorderSide(color: kGreen),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'LIHAT SEMUA EPISODE (${t.episodes})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SectionHead('KOMENTAR'),
              const CommentSection(),
              const SectionHead('REKOMENDASI UNTUK ANDA'),
              RecommendationList(items: recs),
              const SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentSection extends StatelessWidget {
  const CommentSection({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
          decoration: BoxDecoration(
            color: kPanel,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    hintStyle: TextStyle(color: kGrey, fontSize: 13),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              ElevatedButton(
                onPressed: () => snack(context, 'Komentar terkirim (demo)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
                child: const Text('KIRIM'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 17,
              backgroundColor: kBtn,
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'MovieFan88',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '2 jam lalu',
                        style: TextStyle(color: kGrey, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Ceritanya seru banget, kualitas HD dan subtitlenya rapi. Ditunggu episode berikutnya!',
                    style: TextStyle(
                      color: Color(0xFFC9CACD),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Suka • Balas',
                    style: TextStyle(color: kGreen, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class RecommendationList extends StatelessWidget {
  final List<Title> items;
  const RecommendationList({super.key, required this.items});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        for (final t in items)
          InkWell(
            onTap: () => openDetail(context, t),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 112,
                      height: 72,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(t.backdrop, fit: BoxFit.cover),
                          Positioned(
                            left: 5,
                            top: 5,
                            child: StarPill(t.rating),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${t.year} • ${t.kind}${t.isSeries ? ' • ${t.episodes} Episode' : ''}',
                          style: const TextStyle(color: kGrey, fontSize: 11.5),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t.genres.join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kGreen, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: UserStore.later,
                    builder: (_, later, __) => IconButton(
                      icon: Icon(
                        later.contains(t.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: later.contains(t.id) ? kGreen : kGrey,
                        size: 20,
                      ),
                      onPressed: () => UserStore.toggleLater(t.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

// -------------------------------- play --------------------------------------

class PlayPage extends StatefulWidget {
  final Title title;
  final int episode;
  const PlayPage({super.key, required this.title, this.episode = 1});
  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  late int _ep = widget.episode;
  int _server = 0; // 0 = Alpha (aktif), 1 = Beta
  int _backup = 0;
  bool _expanded = false;
  VideoPlayerController? _ctrl;
  bool _ready = false, _playing = false;

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
  }

  @override
  void dispose() {
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
    final recs = catalog.where((x) => x.id != t.id).take(4).toList();
    final shownEps = t.episodes > 8 ? 8 : t.episodes;
    return Scaffold(
      appBar: const SiteHeader(showBack: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ListView(
            children: [
              Breadcrumb(['Home', t.kind, t.name]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.isSeries
                          ? '${t.name} Episode $_ep Subtitle Indonesia'
                          : '${t.name} Subtitle Indonesia',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          size: 15,
                          color: kGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${t.views} x ditonton',
                          style: const TextStyle(color: kGrey, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 15, color: kGrey),
                        const SizedBox(width: 4),
                        Text(
                          t.duration,
                          style: const TextStyle(color: kGrey, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: kGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          t.year,
                          style: const TextStyle(color: kGrey, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          t.kind,
                          style: const TextStyle(
                            color: kGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // player
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: !_ready
                      ? const Center(
                          child: CircularProgressIndicator(color: kGreen),
                        )
                      : GestureDetector(
                          onTap: () =>
                              _playing ? _ctrl!.pause() : _ctrl!.play(),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Center(
                                child: AspectRatio(
                                  aspectRatio: _ctrl!.value.aspectRatio,
                                  child: VideoPlayer(_ctrl!),
                                ),
                              ),
                              if (!_playing)
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 66,
                                        height: 66,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: kGreen,
                                            width: 2.5,
                                          ),
                                          color: Colors.black45,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: kGreen,
                                          size: 34,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Tonton Trailer',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
              // green progress bar + controls row (intl style)
              if (_ready)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _ctrl!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: kProgress,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _playing ? _ctrl!.pause() : _ctrl!.play(),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: kGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                _playing ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                                size: 19,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.volume_up,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${_fmt(_ctrl!.value.position)} / ${_fmt(_ctrl!.value.duration)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.settings_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.picture_in_picture_alt_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FullPlayerPage(
                                  ctrl: _ctrl!,
                                  title: '${t.name} — Episode $_ep',
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              // servers
              const SectionHead('PILIH SERVER'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih server di bawah ini untuk mulai menonton. Jika server bermasalah, coba server cadangan.',
                      style: TextStyle(color: kGrey, fontSize: 12.5),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        for (var s = 0; s < 2; s++) ...[
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _server = s),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: kCard,
                                  border: Border.all(
                                    color: _server == s
                                        ? kGreen
                                        : Colors.white10,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.dns_outlined,
                                      color: kGreen,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s == 0
                                                ? 'Server Alpha'
                                                : 'Server Beta',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            s == 0
                                                ? 'Kualitas HD • 1080p'
                                                : 'Kualitas SD • 480p',
                                            style: const TextStyle(
                                              color: kGrey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _server == s
                                            ? kGreen
                                            : Colors.white12,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _server == s ? 'AKTIF' : 'PILIH',
                                        style: TextStyle(
                                          color: _server == s
                                              ? Colors.black
                                              : Colors.white60,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (s == 0) const SizedBox(width: 11),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SERVER CADANGAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var b = 0; b < 3; b++)
                      InkWell(
                        onTap: () => setState(() => _backup = b),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                _backup == b
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _backup == b ? kGreen : kGrey,
                                size: 19,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                [
                                  'Server Gamma',
                                  'Server Delta',
                                  'Server Epsilon',
                                ][b],
                                style: const TextStyle(
                                  color: kText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Text(
                      'Ganti jika server utama bermasalah.',
                      style: TextStyle(color: kGrey, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              // episodes
              if (t.isSeries) ...[
                SectionHead(
                  'DAFTAR EPISODE',
                  moreLabel: 'Lihat Semua (${t.episodes})',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (var e = 1; e <= shownEps; e++)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: e == _ep ? kPanel : kCard,
                            border: Border(
                              left: BorderSide(
                                color: e == _ep ? kGreen : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: ListTile(
                            dense: true,
                            onTap: () => setState(() => _ep = e),
                            leading: Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF14301B),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                e.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  color: kGreen,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            title: Text(
                              'Episode $e: ${epTitles[(e - 1) % epTitles.length]}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              e == _ep
                                  ? 'SEDANG DIPUTAR • ${t.duration}'
                                  : t.duration,
                              style: TextStyle(
                                color: e == _ep ? kGreen : kGrey,
                                fontSize: 11,
                              ),
                            ),
                            trailing: e == _ep
                                ? const Icon(
                                    Icons.play_circle_fill,
                                    color: kGreen,
                                    size: 24,
                                  )
                                : const Icon(
                                    Icons.download_outlined,
                                    color: kGrey,
                                    size: 20,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              // sinopsis
              const SectionHead('SINOPSIS'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          _expanded ? 'Tutup' : 'Baca Selengkapnya',
                          style: const TextStyle(color: kGreen, fontSize: 12.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // cast
              const SectionHead('PEMERAN'),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: t.cast.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, i) => Column(
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: i.isEven ? kGreen : kBtn,
                        child: Text(
                          t.cast[i][0],
                          style: TextStyle(
                            color: i.isEven ? Colors.black : Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.cast[i],
                        style: const TextStyle(color: kText, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SectionHead('REKOMENDASI UNTUK ANDA'),
              RecommendationList(items: recs),
              const SectionHead('KOMENTAR'),
              const CommentSection(),
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
                    hintText: 'Cari film, series, anime, drama…',
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
              Expanded(child: PosterGridV5(items: res, shrink: false)),
            ],
          ),
        ),
      ),
    );
  }
}

class LabelPage extends StatelessWidget {
  final String label, genre;
  const LabelPage({super.key, required this.label, required this.genre});
  @override
  Widget build(BuildContext context) {
    final items = genre.isEmpty
        ? catalog
        : catalog
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
              Breadcrumb(['Home', label]),
              SectionHead(label),
              Expanded(child: PosterGridV5(items: items, shrink: false)),
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
                        builder: (_, favs, __) => PosterGridV5(
                          items: catalog
                              .where((t) => favs.contains(t.id))
                              .toList(),
                          shrink: false,
                        ),
                      )
                    : ValueListenableBuilder<List<String>>(
                        valueListenable: UserStore.history,
                        builder: (_, hist, __) => PosterGridV5(
                          items: hist
                              .map(
                                (id) => catalog
                                    .where((t) => t.id == id)
                                    .firstOrNull,
                              )
                              .whereType<Title>()
                              .toList(),
                          shrink: false,
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
