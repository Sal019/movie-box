# MovieBox — Streaming UI (Flutter)

A streaming app UI/UX built with Flutter in the AniLab design language (pure black, monochrome, white pill actions, 5-tab outline nav: Home / Genres / Latest / Search / My List), following the 2026
mobile redesign layout — with its own original branding ("Nova"), colour
palette, icons and artwork. Demo only: all titles are fictional and the
playable videos are openly licensed sample films.

## Pages
- **Home** — hero billboard, Continue Watching with progress bars, Trending,
  Top 10 with oversized rank numbers, genre rails, Shows/Movies/Categories
  filters, bottom tabs (Home · Clips · Search · My Nova)
- **Title page** — match %, metadata, Play/Download, My List / Rate / Share,
  Episodes tab with season selector and per-episode rows, More Like This,
  Trailers & More
- **Video player** — custom controls: ±10s skip (buttons + double-tap),
  seek bar, playback speed, Episodes sheet, Audio & Subtitles sheet,
  screen lock, Skip Intro, Next Episode

## Profiles
No sign-in. Profiles are **local only** — name and avatar colour are stored
on the device (local storage), up to 5 profiles, switchable from the Home
header or the My Nova tab.

## Run
```bash
flutter pub get
flutter run            # or: flutter build web --release
```

Live demo (GitHub Pages): https://sal019.github.io/movie-box/
