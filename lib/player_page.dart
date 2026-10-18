import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'data.dart';
import 'state.dart';
import 'widgets.dart';

/// AniLab-style player: monochrome floating controls, white seek bar,
/// quality selector top-right, server + SUB/DUB picker (like AniLab's
/// watch flow), episodes sheet, speed, screen lock, Skip Intro, Next Ep.
class PlayerPage extends StatefulWidget {
  final AppState state;
  final TitleItem title;
  final Episode? episode;
  const PlayerPage(
      {super.key, required this.state, required this.title, this.episode});
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _c;
  bool _ready = false;
  bool _error = false;
  bool _show = true;
  bool _locked = false;
  double _speed = 1.0;
  String _quality = '1080p';
  String _server = 'Server A';
  String _track = 'SUB';
  String _audio = 'English';
  String _subs = 'English';
  Timer? _hideTimer;
  int _flashSeek = 0;
  Timer? _flashTimer;
  Episode? _episode;

  TitleItem get t => widget.title;

  @override
  void initState() {
    super.initState();
    _episode = widget.episode ??
        (t.isSeries ? t.seasons.first.episodes.first : null);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _load(_episode, resume: true);
  }

  Future<void> _load(Episode? ep, {bool resume = false}) async {
    final old = _c;
    _c = null;
    if (mounted) setState(() => _ready = false);
    await old?.dispose();
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(t.videoUrl));
    _c = ctrl;
    try {
      await ctrl.initialize();
      if (!mounted) return;
      var start = Duration(seconds: ep?.startOffsetSeconds ?? 0);
      if (resume) {
        final ratio = widget.state.progressFor(t);
        final saved = ctrl.value.duration * ratio;
        if (saved > start && ratio < 0.95) start = saved;
      }
      if (start > Duration.zero &&
          start < ctrl.value.duration - const Duration(seconds: 5)) {
        await ctrl.seekTo(start);
      }
      await ctrl.setPlaybackSpeed(_speed);
      await ctrl.play();
      ctrl.addListener(_onValue);
      if (mounted) {
        setState(() {
          _ready = true;
          _episode = ep;
        });
        _armHideTimer();
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  void _onValue() {
    if (mounted) setState(() {});
  }

  void _armHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && (_c?.value.isPlaying ?? false)) {
        setState(() => _show = false);
      }
    });
  }

  void _toggleControls() {
    if (_locked) return;
    setState(() => _show = !_show);
    if (_show) _armHideTimer();
  }

  void _seekBy(int seconds) {
    final c = _c;
    if (c == null || !_ready) return;
    c.seekTo(c.value.position + Duration(seconds: seconds));
    setState(() => _flashSeek = seconds);
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _flashSeek = 0);
    });
  }

  Episode? get _nextEpisode {
    if (!t.isSeries || _episode == null) return null;
    for (final s in t.seasons) {
      if (!s.episodes.contains(_episode)) continue;
      final idx = s.episodes.indexOf(_episode!);
      if (idx + 1 < s.episodes.length) return s.episodes[idx + 1];
      final sIdx = t.seasons.indexOf(s);
      if (sIdx + 1 < t.seasons.length) {
        return t.seasons[sIdx + 1].episodes.first;
      }
      return null;
    }
    return null;
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _flashTimer?.cancel();
    final c = _c;
    if (c != null && c.value.duration > Duration.zero) {
      final ratio =
          c.value.position.inMilliseconds / c.value.duration.inMilliseconds;
      widget.state.setProgress(t.id, ratio >= 0.98 ? 0 : ratio);
    }
    c?.removeListener(_onValue);
    c?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(fit: StackFit.expand, children: [
          Center(
            child: (_ready && c != null)
                ? AspectRatio(
                    aspectRatio:
                        c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
                    child: VideoPlayer(c),
                  )
                : const SizedBox.shrink(),
          ),
          if (!_ready && !_error)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (_error)
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline,
                    color: Colors.white54, size: 44),
                const SizedBox(height: 10),
                const Text('This demo video could not be loaded.',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  onPressed: () {
                    setState(() => _error = false);
                    _load(_episode);
                  },
                  child: const Text('Retry'),
                ),
              ]),
            ),
          if (_ready && !_locked)
            Row(children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTap: () => _seekBy(-10),
                  child: const SizedBox.expand(),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTap: () => _seekBy(10),
                  child: const SizedBox.expand(),
                ),
              ),
            ]),
          if (_flashSeek != 0)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(24)),
                child: Text('${_flashSeek > 0 ? '+' : ''}$_flashSeek s',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          if (_locked) _lockOverlay(),
          if (_ready && _show && !_locked && c != null) _controls(c),
        ]),
      ),
    );
  }

  Widget _lockOverlay() {
    return Positioned(
      left: 18,
      bottom: 22,
      child: GestureDetector(
        onTap: () => setState(() {
          _locked = false;
          _show = true;
          _armHideTimer();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.lock_rounded, color: Colors.white, size: 17),
            SizedBox(width: 7),
            Text('Screen Locked — tap to unlock',
                style: TextStyle(color: Colors.white, fontSize: 12.5)),
          ]),
        ),
      ),
    );
  }

  Widget _controls(VideoPlayerController c) {
    final pos = c.value.position;
    final dur = c.value.duration;
    final playing = c.value.isPlaying;
    final ended =
        dur > Duration.zero && pos >= dur - const Duration(milliseconds: 400);
    final showSkipIntro = pos.inSeconds >= 5 && pos.inSeconds <= 25 && !ended;
    final next = _nextEpisode;
    final heading = _episode != null
        ? '${t.name} — S${_seasonOf(_episode!)}:E${_episode!.number} "${_episode!.name}"'
        : t.name;

    return Stack(fit: StackFit.expand, children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(heading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600)),
                ),
                // AniLab-style quality selector, top-right
                GestureDetector(
                  onTap: _qualitySheet,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(_quality,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cast_rounded, color: Colors.white),
                  onPressed: () => toast(context, 'Cast is a demo in this UI'),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.subtitles_rounded, color: Colors.white),
                  onPressed: _audioSubsSheet,
                ),
              ]),
            ),
          ),
        ),
      ),
      Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _transportBtn(Icons.replay_10_rounded, () => _seekBy(-10)),
          const SizedBox(width: 34),
          GestureDetector(
            onTap: () {
              if (ended) {
                c.seekTo(Duration.zero);
                c.play();
              } else if (playing) {
                c.pause();
              } else {
                c.play();
                _armHideTimer();
              }
              setState(() {});
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
                border: Border.all(color: Colors.white38),
              ),
              child: Icon(
                  ended
                      ? Icons.replay_rounded
                      : (playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                  color: Colors.white,
                  size: 42),
            ),
          ),
          const SizedBox(width: 34),
          _transportBtn(Icons.forward_10_rounded, () => _seekBy(10)),
        ]),
      ),
      if (showSkipIntro)
        Positioned(
          right: 22,
          bottom: 108,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => c.seekTo(pos + const Duration(seconds: 20)),
            child: const Text('Skip Intro',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      if (next != null &&
          (ended ||
              (dur > Duration.zero &&
                  dur - pos < const Duration(seconds: 30))))
        Positioned(
          right: 22,
          bottom: showSkipIntro ? 162 : 108,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _load(next),
            icon: const Icon(Icons.skip_next_rounded),
            label: Text('Next Ep. ${next.number}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Text(_fmt(pos),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12.5)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3.5,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayShape: SliderComponentShape.noOverlay,
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: dur.inMilliseconds == 0
                            ? 0
                            : pos.inMilliseconds
                                .clamp(0, dur.inMilliseconds)
                                .toDouble(),
                        max: dur.inMilliseconds.toDouble(),
                        onChanged: (v) =>
                            c.seekTo(Duration(milliseconds: v.toInt())),
                      ),
                    ),
                  ),
                  Text(_fmt(dur),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12.5)),
                ]),
                Row(children: [
                  _bottomBtn(Icons.speed_rounded, 'Speed', () => _speedSheet(c)),
                  if (t.isSeries)
                    _bottomBtn(Icons.list_rounded, 'Episodes', _episodesSheet),
                  _bottomBtn(Icons.subtitles_outlined, 'Audio & Subs',
                      _audioSubsSheet),
                  _bottomBtn(Icons.lock_outline_rounded, 'Lock', () {
                    setState(() {
                      _locked = true;
                      _show = false;
                    });
                  }),
                  const Spacer(),
                  if (next != null)
                    _bottomBtn(Icons.skip_next_rounded, 'Next Ep.',
                        () => _load(next)),
                ]),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  int _seasonOf(Episode ep) {
    for (final s in t.seasons) {
      if (s.episodes.contains(ep)) return s.number;
    }
    return 1;
  }

  Widget _transportBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: 44),
    );
  }

  Widget _bottomBtn(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: TextButton.icon(
        style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
        onPressed: onTap,
        icon: Icon(icon, size: 19),
        label: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  void _qualitySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('Quality',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
          ),
          for (final q in ['Auto', '360p', '480p', '720p', '1080p'])
            ListTile(
              title: Text(q, style: const TextStyle(color: Colors.white)),
              trailing: _quality == q
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
              onTap: () {
                setState(() => _quality = q);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _speedSheet(VideoPlayerController c) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('Playback Speed',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
          ),
          for (final s in [0.5, 0.75, 1.0, 1.25, 1.5])
            ListTile(
              title: Text(s == 1.0 ? 'Normal (1.0×)' : '${s}×',
                  style: const TextStyle(color: Colors.white)),
              trailing: _speed == s
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
              onTap: () {
                setState(() => _speed = s);
                c.setPlaybackSpeed(s);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _episodesSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('Episodes',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
          ),
          for (final s in t.seasons) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Text('Season ${s.number}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            for (final ep in s.episodes)
              ListTile(
                title: Text('${ep.number}. ${ep.name}',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(ep.durationLabel,
                    style: const TextStyle(color: kDim)),
                trailing: ep == _episode
                    ? const Icon(Icons.play_circle_fill_rounded,
                        color: Colors.white)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  _load(ep);
                },
              ),
          ],
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _audioSubsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => SafeArea(
          child: ListView(shrinkWrap: true, children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('Watch Options',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 6),
              child: Text('Version',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(children: [
                for (final v in ['SUB', 'DUB'])
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(v),
                      selected: _track == v,
                      selectedColor: Colors.white,
                      backgroundColor: kTile,
                      labelStyle: TextStyle(
                          color: _track == v ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w700),
                      onSelected: (_) => setLocal(() => _track = v),
                    ),
                  ),
              ]),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 4),
              child: Text('Server',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            for (final s in ['Server A', 'Server B'])
              ListTile(
                title: Text(s, style: const TextStyle(color: Colors.white)),
                trailing: _server == s
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
                onTap: () => setLocal(() => _server = s),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Text('Audio',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            for (final a in ['English', 'Bangla', 'Hindi'])
              ListTile(
                title: Text(a, style: const TextStyle(color: Colors.white)),
                trailing: _audio == a
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
                onTap: () => setLocal(() => _audio = a),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Text('Subtitles',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            for (final s in ['Off', 'English', 'Bangla'])
              ListTile(
                title: Text(s, style: const TextStyle(color: Colors.white)),
                trailing:
                    _subs == s ? const Icon(Icons.check, color: Colors.white) : null,
                onTap: () => setLocal(() => _subs = s),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ),
          ]),
        ),
      ),
    ).then((_) => setState(() {}));
  }
}
