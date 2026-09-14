import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreBar extends StatelessWidget {
  final int score;

  const ScoreBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SCORE: $score pts',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu,
              color: Colors.white70,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
