import 'package:flutter/material.dart';
import 'data.dart';
import 'state.dart';

// ---- AniLab-style design system: pure black, monochrome white/gray ----
// Recreated from publicly posted screenshots of the AniLab app family:
// black background, white pill buttons, outline-icon bottom nav, bold
// section headers, charcoal genre tiles. All artwork/branding is our own.
const Color kBg = Color(0xFF000000);
const Color kSurface = Color(0xFF141416);
const Color kTile = Color(0xFF1E1E20);
const Color kDim = Color(0xFF9C9CA3);
const Color kFaint = Color(0xFF636368);

class MovieBoxLogo extends StatelessWidget {
  final double size;
  const MovieBoxLogo({super.key, this.size = 30});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.26),
        ),
        child: Icon(Icons.play_arrow_rounded,
            color: Colors.black, size: size * 0.74),
      ),
      const SizedBox(width: 8),
      Text('MovieBox',
          style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.62,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2)),
    ]);
  }
}

class AvatarWidget extends StatelessWidget {
  final LocalProfile profile;
  final double size;
  const AvatarWidget({super.key, required this.profile, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final colors =
        kAvatarGradients[profile.colorIndex % kAvatarGradients.length];
    final initial = profile.name.isNotEmpty
        ? profile.name.characters.first.toUpperCase()
        : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(initial,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.44)),
    );
  }
}

/// Small gray metadata chip, e.g. "TV", "PG 13" (AniLab detail style).
class MetaChip extends StatelessWidget {
  final String text;
  const MetaChip(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(5)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class PosterCard extends StatelessWidget {
  final TitleItem title;
  final double width;
  final VoidCallback onTap;
  const PosterCard(
      {super.key, required this.title, required this.onTap, this.width = 124});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(title.poster,
            width: width, height: width * 1.42, fit: BoxFit.cover),
      ),
    );
  }
}

class LandscapeCard extends StatelessWidget {
  final TitleItem title;
  final double width;
  final double? progressRatio;
  final AppState? state;
  final VoidCallback onTap;
  const LandscapeCard(
      {super.key,
      required this.title,
      required this.onTap,
      this.width = 268,
      this.progressRatio,
      this.state});

  @override
  Widget build(BuildContext context) {
    final ratio = progressRatio ?? (state?.progressFor(title) ?? 0);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(children: [
            Image.asset(title.backdrop,
                width: width, height: width * 0.5625, fit: BoxFit.cover),
            if (ratio > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 3.5,
                  color: Colors.white24,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio.clamp(0.02, 1),
                    child: Container(color: Colors.white),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 10),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
    );
  }
}

/// Icon-over-label action used in hero/detail (Share, My List) — AniLab style.
class SideAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const SideAction(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
    );
  }
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: kTile,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
}
