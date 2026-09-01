import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B24),
        title: const Text('About TraceCraft', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header Card
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.draw_rounded, size: 54, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TraceCraft',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.0.0 (Build 1)',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Concept section
            _buildSectionHeader('What is Camera Lucida?'),
            const SizedBox(height: 8),
            _buildTextCard(
              'The Camera Lucida is an optical instrument invented in 1807 by William Hyde Wollaston that allows artists to see both their subject and their drawing surface simultaneously.\n\n'
              'TraceCraft brings this time-tested traditional art technique to the digital era. By overlaying reference sketches directly onto your live camera feed, you can develop muscle memory, master proportions, and create stunning physical drawings on real paper.',
            ),
            const SizedBox(height: 20),

            // Core Features
            _buildSectionHeader('Key Features'),
            const SizedBox(height: 8),
            _buildFeatureTile(
              icon: Icons.videocam_rounded,
              iconColor: const Color(0xFF00CEC9),
              title: 'Live Camera Lucida Canvas',
              desc: 'Fixed real-time camera preview of your paper with smooth gesture zoom, pan, and rotation.',
            ),
            _buildFeatureTile(
              icon: Icons.auto_fix_high_rounded,
              iconColor: const Color(0xFFA29BFE),
              title: 'Sobel Line-Art Filter',
              desc: 'Convert complex photos into clean, high-contrast pencil outline sketches on the fly.',
            ),
            _buildFeatureTile(
              icon: Icons.grid_4x4_rounded,
              iconColor: const Color(0xFFFF7675),
              title: 'Proportion Grid Overlay',
              desc: 'Rule-of-thirds and NxN grid guides for learning accurate perspective and scaling.',
            ),
            _buildFeatureTile(
              icon: Icons.groups_rounded,
              iconColor: const Color(0xFFFFB300),
              title: 'Community Showcase',
              desc: 'Share your finished drawings, discover techniques, and rate artworks worldwide.',
            ),
            const SizedBox(height: 20),

            // Open Source & Privacy
            _buildSectionHeader('Privacy & Open Source'),
            const SizedBox(height: 8),
            _buildTextCard(
              'TraceCraft respects your privacy. Tracing sessions, opacity settings, and streaks are stored locally on your device using Hive. All royalty-free search photos are provided by Pexels.',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00CEC9)),
    );
  }

  Widget _buildTextCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181B24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181B24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
