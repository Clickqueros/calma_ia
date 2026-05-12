import 'package:flutter/material.dart';
import 'models/ejercicio_model.dart';
import 'youtube_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoEjercicio video;
  final Modulo modulo;
  final int videoIndex;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.modulo,
    required this.videoIndex,
  });

  bool get _hasNext => videoIndex < modulo.videos.length - 1;
  VideoEjercicio? get _nextVideo =>
      _hasNext ? modulo.videos[videoIndex + 1] : null;

  bool _small(BuildContext ctx) => MediaQuery.of(ctx).size.width < 700;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A35),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: small
                  ? _buildMobileLayout(context)
                  : _buildDesktopLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
            bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.08), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(modulo.titulo,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13)),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Video counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: modulo.gradiente),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${videoIndex + 1} / ${modulo.videos.length}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop layout ───────────────────────────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main player area
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlayer(),
                const SizedBox(height: 24),
                _buildVideoInfo(),
              ],
            ),
          ),
        ),
        // Sidebar: playlist
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            border: Border(
                left: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: _buildPlaylist(context),
        ),
      ],
    );
  }

  // ── Mobile layout ────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPlayer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVideoInfo(),
                const SizedBox(height: 24),
                if (_hasNext) _buildNextCard(context),
                const SizedBox(height: 16),
                _buildMiniPlaylist(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── YouTube player ───────────────────────────────────────────────────────

  Widget _buildPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: buildYoutubePlayer(video.youtubeId),
      ),
    );
  }

  // ── Video info ───────────────────────────────────────────────────────────

  Widget _buildVideoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: modulo.gradiente),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                modulo.etiqueta,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${video.duracion} min',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          video.titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          video.descripcion,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.6),
        ),
      ],
    );
  }

  // ── Desktop sidebar playlist ─────────────────────────────────────────────

  Widget _buildPlaylist(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            'En este módulo',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: modulo.videos.length,
            itemBuilder: (ctx, i) {
              final v = modulo.videos[i];
              final isCurrent = i == videoIndex;
              return GestureDetector(
                onTap: () => isCurrent
                    ? null
                    : Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (c, a, _) => VideoPlayerScreen(
                            video: v,
                            modulo: modulo,
                            videoIndex: i,
                          ),
                          transitionsBuilder: (c, a, _, child) =>
                              FadeTransition(opacity: a, child: child),
                          transitionDuration:
                              const Duration(milliseconds: 250),
                        ),
                      ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: isCurrent
                              ? LinearGradient(colors: modulo.gradiente)
                              : null,
                          color: isCurrent
                              ? null
                              : Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCurrent
                              ? const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 16)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${v.duracion} min',
                              style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.3),
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Mobile next card ─────────────────────────────────────────────────────

  Widget _buildNextCard(BuildContext context) {
    final next = _nextVideo!;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (c, a, _) => VideoPlayerScreen(
            video: next,
            modulo: modulo,
            videoIndex: videoIndex + 1,
          ),
          transitionsBuilder: (c, a, _, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: modulo.gradiente,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.skip_next_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Siguiente video',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11)),
                  Text(next.titulo,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlaylist(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Más en ${modulo.titulo}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...modulo.videos.asMap().entries.where((e) => e.key != videoIndex).take(3).map(
              (e) => GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (c, a, _) => VideoPlayerScreen(
                      video: e.value,
                      modulo: modulo,
                      videoIndex: e.key,
                    ),
                    transitionsBuilder: (c, a, _, child) =>
                        FadeTransition(opacity: a, child: child),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${e.key + 1}',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(e.value.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12)),
                      ),
                      Text(e.value.duracion,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
