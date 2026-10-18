// Demo catalog for the Nova streaming UI.
// All titles are fictional; artwork is original generated art and the
// playable videos are openly licensed sample films (Blender Foundation
// open movies via archive.org, plus short test clips).

class Episode {
  final int number;
  final String name;
  final String durationLabel;
  final String synopsis;
  final int startOffsetSeconds;
  const Episode({
    required this.number,
    required this.name,
    required this.durationLabel,
    required this.synopsis,
    this.startOffsetSeconds = 0,
  });
}

class Season {
  final int number;
  final List<Episode> episodes;
  const Season({required this.number, required this.episodes});
}

class TitleItem {
  final String id;
  final String name;
  final bool isSeries;
  final String kind; // Series, Movie, Anime, Documentary, Drama
  final List<String> genres;
  final int year;
  final String maturity; // e.g. 16+
  final String durationLabel; // movie runtime or "3 Seasons"
  final int matchPercent;
  final String synopsis;
  final String castLine;
  final String creatorLine;
  final String poster; // asset path (portrait)
  final String backdrop; // asset path (landscape)
  final String videoUrl;
  final List<Season> seasons;
  final int? top10Rank;
  final double continueProgress; // 0..1 seed for Continue Watching

  const TitleItem({
    required this.id,
    required this.name,
    required this.isSeries,
    required this.kind,
    required this.genres,
    required this.year,
    required this.maturity,
    required this.durationLabel,
    required this.matchPercent,
    required this.synopsis,
    required this.castLine,
    required this.creatorLine,
    required this.poster,
    required this.backdrop,
    required this.videoUrl,
    this.seasons = const [],
    this.top10Rank,
    this.continueProgress = 0,
  });
}

const String kSintelVideo =
    'https://archive.org/download/Sintel/sintel-2048-stereo_512kb.mp4';
const String kBunnyVideo =
    'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4';
const String kDreamVideo =
    'https://archive.org/download/ElephantsDream/ed_1024_512kb.mp4';
const String kSintelClip =
    'https://test-videos.co.uk/vids/sintel/mp4/h264/720/Sintel_720_10s_1MB.mp4';
const String kJellyfishClip =
    'https://test-videos.co.uk/vids/jellyfish/mp4/h264/1080/Jellyfish_1080_10s_1MB.mp4';
const String kBunnyClip =
    'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4';

const String img = 'assets/images';

final List<TitleItem> catalog = [
  TitleItem(
    id: 'dhaka2077',
    name: 'Dhaka 2077',
    isSeries: true,
    kind: 'Series',
    genres: ['Sci-Fi', 'Thriller', 'Drama'],
    year: 2026,
    maturity: '16+',
    durationLabel: '2 Seasons',
    matchPercent: 98,
    synopsis:
        'In a neon-drowned Dhaka of 2077, a rickshaw driver turned data courier discovers a memory chip that could rewrite the city. Hunted by the Sky Wardens, he has one monsoon night to deliver it.',
    castLine: 'Arif Chowdhury, Nusrat Jahan, Tanvir Hasan',
    creatorLine: 'Created by R. Karim',
    poster: '$img/poster-dhaka.webp',
    backdrop: '$img/hero-dhaka.webp',
    videoUrl: kSintelVideo,
    top10Rank: 1,
    continueProgress: 0.42,
    seasons: [
      Season(number: 1, episodes: [
        Episode(
            number: 1,
            name: 'Monsoon Protocol',
            durationLabel: '48m',
            synopsis:
                'Courier Rafi takes a midnight job across the flooded neon districts and finds more than data in the package.'),
        Episode(
            number: 2,
            name: 'Sky Wardens',
            durationLabel: '45m',
            synopsis:
                'The Wardens close in. Rafi hides in the old town as an unlikely ally offers a route through the drone grid.',
            startOffsetSeconds: 240),
        Episode(
            number: 3,
            name: 'The Buriganga Run',
            durationLabel: '51m',
            synopsis:
                'A river chase at dawn. Rafi must choose between the payout and the truth the chip carries.',
            startOffsetSeconds: 480),
      ]),
      Season(number: 2, episodes: [
        Episode(
            number: 1,
            name: 'New Dhaka',
            durationLabel: '49m',
            synopsis:
                'One year later, the city has changed — and so has the price on Rafi\'s head.'),
        Episode(
            number: 2,
            name: 'Ghost Signal',
            durationLabel: '47m',
            synopsis:
                'A broadcast from a dead channel pulls Rafi back into the grid he swore to leave.',
            startOffsetSeconds: 300),
      ]),
    ],
  ),
  TitleItem(
    id: 'dragon',
    name: 'Dragon\'s Promise',
    isSeries: false,
    kind: 'Movie',
    genres: ['Fantasy', 'Adventure'],
    year: 2025,
    maturity: '13+',
    durationLabel: '1h 54m',
    matchPercent: 97,
    synopsis:
        'A young sword-bearer crosses a misty mountain kingdom to find the last dragon — and learns the beast has been searching for her, too.',
    castLine: 'Elena Mar, Jonas Feld',
    creatorLine: 'Directed by C. Durand',
    poster: '$img/poster-dragon.webp',
    backdrop: '$img/poster-dragon.webp',
    videoUrl: kSintelVideo,
    top10Rank: 2,
    continueProgress: 0.68,
  ),
  TitleItem(
    id: 'bunny',
    name: 'Bunny Tales',
    isSeries: false,
    kind: 'Movie',
    genres: ['Animation', 'Family', 'Comedy'],
    year: 2024,
    maturity: '7+',
    durationLabel: '1h 32m',
    matchPercent: 95,
    synopsis:
        'A gentle giant bunny defends his sunny forest clearing from three mischievous rodents in this beloved family comedy.',
    castLine: 'Studio Bloom Voices',
    creatorLine: 'Directed by S. Bakker',
    poster: '$img/poster-bunny.webp',
    backdrop: '$img/poster-bunny.webp',
    videoUrl: kBunnyVideo,
    top10Rank: 4,
    continueProgress: 0.15,
  ),
  TitleItem(
    id: 'dream',
    name: 'Dream Machine',
    isSeries: false,
    kind: 'Movie',
    genres: ['Sci-Fi', 'Surreal'],
    year: 2023,
    maturity: '13+',
    durationLabel: '1h 41m',
    matchPercent: 91,
    synopsis:
        'Two travellers wander an infinite machine that dreams worlds into being — and something inside the machine starts dreaming back.',
    castLine: 'Proog, Emo (voices)',
    creatorLine: 'Directed by B. Smit',
    poster: '$img/poster-dream.webp',
    backdrop: '$img/poster-dream.webp',
    videoUrl: kDreamVideo,
    continueProgress: 0.81,
  ),
  TitleItem(
    id: 'noir',
    name: 'Monsoon Noir',
    isSeries: true,
    kind: 'Drama',
    genres: ['Crime', 'Drama', 'Mystery'],
    year: 2026,
    maturity: '18+',
    durationLabel: '1 Season',
    matchPercent: 93,
    synopsis:
        'A weary inspector, a string of rainy-season cases, and a city that never dries. Every alley in the old town keeps a secret.',
    castLine: 'Imran Syed, Farhana Rahman',
    creatorLine: 'Created by D. Osei',
    poster: '$img/poster-noir.webp',
    backdrop: '$img/poster-noir.webp',
    videoUrl: kDreamVideo,
    top10Rank: 3,
    continueProgress: 0.57,
    seasons: [
      Season(number: 1, episodes: [
        Episode(
            number: 1,
            name: 'First Rain',
            durationLabel: '52m',
            synopsis:
                'A body under the bridge on the first night of monsoon. Inspector Reza takes the case nobody wants.'),
        Episode(
            number: 2,
            name: 'The Umbrella Man',
            durationLabel: '50m',
            synopsis:
                'A witness who only appears when it rains leads Reza to the docks.',
            startOffsetSeconds: 260),
        Episode(
            number: 3,
            name: 'Low Water',
            durationLabel: '55m',
            synopsis:
                'The river drops, and what it was hiding surfaces. Reza closes in on the killer.',
            startOffsetSeconds: 520),
      ]),
    ],
  ),
  TitleItem(
    id: 'ocean',
    name: 'Ocean Realm',
    isSeries: false,
    kind: 'Documentary',
    genres: ['Documentary', 'Nature'],
    year: 2025,
    maturity: 'All',
    durationLabel: '58m',
    matchPercent: 89,
    synopsis:
        'Drift with the jellyfish — a slow, glowing journey through the deep ocean\'s most alien neighbourhood.',
    castLine: 'Narrated by A. Whitmore',
    creatorLine: 'A Blue Planet Studio film',
    poster: '$img/poster-ocean.webp',
    backdrop: '$img/poster-ocean.webp',
    videoUrl: kJellyfishClip,
    top10Rank: 5,
  ),
  TitleItem(
    id: 'ronin',
    name: 'Star Ronin',
    isSeries: true,
    kind: 'Anime',
    genres: ['Anime', 'Action', 'Drama'],
    year: 2026,
    maturity: '16+',
    durationLabel: '1 Season',
    matchPercent: 96,
    synopsis:
        'A masterless swordsman wanders a star-faring empire under a violet moon, taking one impossible duel at a time.',
    castLine: 'K. Watanabe, Y. Mori',
    creatorLine: 'Studio Kaze',
    poster: '$img/poster-ronin.webp',
    backdrop: '$img/poster-ronin.webp',
    videoUrl: kSintelClip,
    top10Rank: 6,
    continueProgress: 0.33,
    seasons: [
      Season(number: 1, episodes: [
        Episode(
            number: 1,
            name: 'Petal and Blade',
            durationLabel: '24m',
            synopsis:
                'The ronin arrives at a blossom port and is challenged before he can even dock.'),
        Episode(
            number: 2,
            name: 'Moon Duel',
            durationLabel: '24m',
            synopsis:
                'A duel at moonrise against the empire\'s youngest champion.'),
        Episode(
            number: 3,
            name: 'The Empty Scabbard',
            durationLabel: '26m',
            synopsis:
                'The ronin gives up his sword — and finds a harder weapon.'),
      ]),
    ],
  ),
];

TitleItem byId(String id) => catalog.firstWhere((t) => t.id == id);
