import 'package:flutter/material.dart';

Widget buildYoutubePlayer(String videoId) {
  return Container(
    color: const Color(0xFF0D0A35),
    child: const Center(
      child: Text(
        'Reproductor no disponible en esta plataforma',
        style: TextStyle(color: Colors.white54),
      ),
    ),
  );
}
