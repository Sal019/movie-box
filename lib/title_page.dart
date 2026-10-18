import 'package:flutter/material.dart';
import 'data.dart';
import 'state.dart';
import 'widgets.dart';
import 'home.dart' show openTitle, playTitle;

class TitlePage extends StatefulWidget {
  final AppState state;
  final TitleItem title;
  const TitlePage({super.key, required this.state, required this.title});
  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  int _tab = 0; // 0 episodes/more, 1 more like this, 2 trailers
  int _seasonIdx = 0;

  TitleItem get t => widget.title;
  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _backdrop(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      _metaRow(),
                      const SizedBox(height: 14),
                      _playButtons(context),
                      const SizedBox(height: 14),
                      Text(t.synopsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13.5, height: 1.45)),
                      const SizedBox(height: 10),
                      Text('Cast: ${t.castLine}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12.5)),
                      Text(t.creatorLine,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12.5)),
                      const SizedBox(height: 16),
                      _actionRow(context),
                      const SizedBox(height: 8),
                      _tabsHeader(),
                    ]),
              ),
              _tabBody(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backdrop(BuildContext context) {
    return Stack(children: [
      AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(t.backdrop, fit: BoxFit.cover),
      ),
      Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, kBg],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.55, 1],
            ),
          ),
        ),
      ),
      Positioned(
        right: 12,
        top: 10,
        child: Row(children: [
          _circleBtn(Icons.cast_rounded,
              () => toast(context, 'Cast is a demo in this UI')),
          const SizedBox(width: 8),
          _circleBtn(Icons.close_rounded, () => Navigator.pop(context)),
        ]),
      ),
      Positioned.fill(
        child: Center(
          child: GestureDetector(
            onTap: () => playTitle(context, state, t),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
                border: Border.all(color: Colors.white70, width: 1.5),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 36),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }

  Widget _metaRow() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Text('${t.matchPercent}% Match',
            style: const TextStyle(
                color: Color(0xFF46D369),
                fontWeight: FontWeight.w700,
                fontSize: 13)),
        Text('${t.year}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white38),
              borderRadius: BorderRadius.circular(4)),
          child: Text(t.maturity,
              style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
        ),
        Text(t.durationLabel,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white38),
              borderRadius: BorderRadius.circular(4)),
          child: const Text('HD',
              style: TextStyle(color: Colors.white70, fontSize: 10.5)),
        ),
        if (t.top10Rank != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
                gradient: kAccent, borderRadius: BorderRadius.circular(5)),
            child: Text('#${t.top10Rank} in Bangladesh Today',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _playButtons(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => playTitle(context, state, t,
              episode: t.isSeries ? t.seasons[_seasonIdx].episodes.first : null),
          icon: const Icon(Icons.play_arrow_rounded, size: 26),
          label: Text(t.isSeries ? 'Play S${_seasonIdx + 1}:E1' : 'Play',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: kSurface2,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => toast(context, 'Download started (demo)'),
          icon: const Icon(Icons.download_rounded, size: 22),
          label: Text(
              t.isSeries ? 'Download Season ${_seasonIdx + 1}' : 'Download',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }

  Widget _actionRow(BuildContext context) {
    final inList = state.inMyList(t.id);
    Widget item(IconData icon, String label, VoidCallback onTap,
        {Color color = Colors.white}) {
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 76,
          child: Column(children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 5),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
          ]),
        ),
      );
    }

    return Row(children: [
      item(inList ? Icons.check_rounded : Icons.add_rounded, 'My List',
          () => state.toggleMyList(t.id)),
      item(Icons.thumb_up_alt_outlined, 'Rate',
          () => toast(context, 'Thanks for rating (demo)')),
      item(Icons.share_rounded, 'Share',
          () => toast(context, 'Share link copied (demo)')),
      item(Icons.download_outlined, 'Download',
          () => toast(context, 'Download started (demo)')),
    ]);
  }

  Widget _tabsHeader() {
    final labels = t.isSeries
        ? ['Episodes', 'More Like This', 'Trailers & More']
        : ['More Like This', 'Trailers & More'];
    return Row(
      children: List.generate(labels.length, (i) {
        final idx = t.isSeries ? i : i + 1;
        final active = _tab == idx || (!t.isSeries && _tab == 0 && i == 0);
        return GestureDetector(
          onTap: () => setState(() => _tab = idx),
          child: Container(
            margin: const EdgeInsets.only(right: 18),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: active ? kCyan : Colors.transparent, width: 3),
              ),
            ),
            child: Text(labels[i],
                style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5)),
          ),
        );
      }),
    );
  }

  Widget _tabBody(BuildContext context) {
    if (t.isSeries && _tab == 0) return _episodes(context);
    if (_tab == 2) return _trailers(context);
    return _moreLikeThis(context);
  }

  Widget _episodes(BuildContext context) {
    final season = t.seasons[_seasonIdx];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // season selector
        GestureDetector(
          onTap: () => _seasonMenu(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
                color: kSurface2, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Season ${season.number}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        for (final ep in season.episodes)
          _episodeRow(context, ep),
      ]),
    );
  }

  void _seasonMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('Select Season',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
          for (var i = 0; i < t.seasons.length; i++)
            ListTile(
              title: Text('Season ${t.seasons[i].number}',
                  style: const TextStyle(color: Colors.white)),
              trailing: i == _seasonIdx
                  ? const Icon(Icons.check, color: kCyan)
                  : null,
              onTap: () {
                setState(() => _seasonIdx = i);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }

  Widget _episodeRow(BuildContext context, Episode ep) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: () => playTitle(context, state, t, episode: ep),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(children: [
                Image.asset(t.backdrop,
                    width: 118, height: 66, fit: BoxFit.cover),
                const Positioned.fill(
                  child: Center(
                    child: Icon(Icons.play_circle_outline_rounded,
                        color: Colors.white, size: 30),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${ep.number}. ${ep.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(ep.durationLabel,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ]),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () => toast(context, 'Episode download started (demo)'),
          ),
        ]),
        const SizedBox(height: 6),
        Text(ep.synopsis,
            style: const TextStyle(
                color: Colors.white60, fontSize: 12.5, height: 1.4)),
      ]),
    );
  }

  Widget _moreLikeThis(BuildContext context) {
    final similar =
        catalog.where((x) => x.id != t.id && x.genres.any(t.genres.contains)).toList();
    final list = similar.isEmpty
        ? catalog.where((x) => x.id != t.id).toList()
        : similar;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.66,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: list.length.clamp(0, 6),
        itemBuilder: (context, i) => PosterCard(
          title: list[i],
          width: double.infinity,
          onTap: () => openTitle(context, state, list[i]),
        ),
      ),
    );
  }

  Widget _trailers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(children: [
        LandscapeCard(
          title: t,
          width: MediaQuery.of(context).size.width - 32,
          progressRatio: 0,
          onTap: () => playTitle(context, state, t),
        ),
        const SizedBox(height: 6),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Official Trailer',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ]),
    );
  }
}
