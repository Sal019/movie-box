import 'package:flutter/material.dart';
import 'data.dart';
import 'state.dart';

// ---- Nova palette: deep navy + violet-to-cyan gradient (own identity) ----
const Color kBg = Color(0xFF070B1A);
const Color kSurface = Color(0xFF101731);
const Color kSurface2 = Color(0xFF1A2347);
const Color kViolet = Color(0xFF7C4DFF);
const Color kCyan = Color(0xFF00E5FF);
const LinearGradient kAccent = LinearGradient(
  colors: [kViolet, kCyan],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const GradientText(this.text, {super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (r) => kAccent.createShader(r),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class NovaLogo extends StatelessWidget {
  final double size;
  const NovaLogo({super.key, this.size = 26});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: kAccent,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        child: Icon(Icons.play_arrow_rounded,
            color: Colors.white, size: size * 0.72),
      ),
      const SizedBox(width: 8),
      GradientText('NOVA',
          style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5)),
    ]);
  }
}

class AvatarWidget extends StatelessWidget {
  final LocalProfile profile;
  final double size;
  const AvatarWidget({super.key, required this.profile, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final colors = kAvatarGradients[profile.colorIndex % kAvatarGradients.length];
    final initial =
        profile.name.isNotEmpty ? profile.name.characters.first.toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(initial,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.45)),
    );
  }
}

class PosterCard extends StatelessWidget {
  final TitleItem title;
  final double width;
  final VoidCallback onTap;
  const PosterCard(
      {super.key, required this.title, required this.onTap, this.width = 116});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(title.poster,
            width: width, height: width * 1.5, fit: BoxFit.cover),
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
      this.width = 250,
      this.progressRatio,
      this.state});

  @override
  Widget build(BuildContext context) {
    final ratio = progressRatio ?? (state?.progressFor(title) ?? 0);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(children: [
              Image.asset(title.backdrop,
                  width: width, height: width * 0.5625, fit: BoxFit.cover),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black45],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: Center(
                  child: Icon(Icons.play_circle_outline_rounded,
                      color: Colors.white, size: 44),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 8,
                right: 10,
                child: Text(title.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
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
                      child: Container(
                        decoration: const BoxDecoration(gradient: kAccent),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class Top10Card extends StatelessWidget {
  final TitleItem title;
  final VoidCallback onTap;
  const Top10Card({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 168,
        height: 174,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: -6,
            bottom: -14,
            child: ShaderMask(
              shaderCallback: (r) => kAccent.createShader(r),
              child: Text('${title.top10Rank}',
                  style: TextStyle(
                      fontSize: 132,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.9))),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(title.poster,
                  width: 116, height: 174, fit: BoxFit.cover),
            ),
          ),
        ]),
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
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
    );
  }
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: kSurface2,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
}
