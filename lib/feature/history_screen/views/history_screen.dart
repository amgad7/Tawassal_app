import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      size: 22,
                      color: Color(0xFF212121),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your recent activities',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  buildHistoryCard(
                    title: 'Speech Practice',
                    subtitle: 'Practiced 12 words',
                    time: '2 hours ago',
                    icon: Icons.mic_rounded,
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 12),
                  buildHistoryCard(
                    title: 'Listening Session',
                    subtitle: 'Heard 8 words correctly',
                    time: '5 hours ago',
                    icon: Icons.volume_up_rounded,
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 12),
                  buildHistoryCard(
                    title: 'Speech Practice',
                    subtitle: 'Practiced 15 words',
                    time: 'Yesterday',
                    icon: Icons.mic_rounded,
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 12),
                  buildHistoryCard(
                    title: 'AI Assistant Chat',
                    subtitle: 'Conversation completed',
                    time: '2 days ago',
                    icon: Icons.smart_toy_rounded,
                    color: const Color(0xFF9C27B0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistoryCard({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
