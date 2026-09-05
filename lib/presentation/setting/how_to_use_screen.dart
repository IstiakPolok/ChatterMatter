import 'package:flutter/material.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.4, 0.7, 1.0],
            colors: [
              Color(0xFFF5E6C8),
              Color(0xFFE8D5F0),
              Color(0xFFD4B8E8),
              Color(0xFFC9A8E0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1A1A1A),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      'How to Use',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                  children: [
                    // Welcome card
                    _InfoCard(
                      child: const Text(
                        'Welcome to Chatter Matters! This app is designed to help you and your child connect through meaningful conversations that go far beyond "how was your day?"',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A3A6A),
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Step 1
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: '⚙️',
                            text: 'Step 1 — Start in Settings',
                          ),
                          const SizedBox(height: 10),
                          _BulletItem(
                            number: '1',
                            text: const TextSpan(
                              children: [
                                TextSpan(text: 'Tap the '),
                                TextSpan(
                                  text: 'Settings wheel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2D1B4E),
                                  ),
                                ),
                                TextSpan(
                                  text: ' at the bottom of your screen.',
                                ),
                              ],
                            ),
                          ),
                          const _Divider(),
                          _BulletItem(
                            number: '2',
                            text: const TextSpan(
                              children: [
                                TextSpan(text: 'Go to '),
                                TextSpan(
                                  text: 'Age Group',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2D1B4E),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' and select the range that fits your child: ',
                                ),
                                TextSpan(
                                  text: 'Ages 4–11',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2D1B4E),
                                  ),
                                ),
                                TextSpan(text: ' or '),
                                TextSpan(
                                  text: 'Ages 11+',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2D1B4E),
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                          const _Divider(),
                          _BulletItem(
                            number: '3',
                            text: const TextSpan(
                              text:
                                  'You can update your age group anytime as your child grows.',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Step 2
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: '💬',
                            text: 'Step 2 — How Many Questions You Get',
                          ),
                          const SizedBox(height: 10),
                          _TierRow(
                            label: 'Free',
                            labelBg: const Color(0xFFE8D5F0),
                            labelColor: const Color(0xFF5A3E8A),
                            text: '1 question per category per day.',
                          ),
                          const _Divider(),
                          _TierRow(
                            label: 'Standard',
                            labelBg: const Color(0xFFA0B4D8),
                            labelColor: const Color(0xFF1A2E50),
                            text:
                                '3 questions per category per age group per day.',
                          ),
                          const _Divider(),
                          _TierRow(
                            label: 'VIP',
                            labelBg: const Color(0xFFF5C842),
                            labelColor: const Color(0xFF5A3E00),
                            text:
                                'All questions available in every category for every age group.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Step 3
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: '🗂️',
                            text: 'Step 3 — Explore the Categories',
                          ),
                          const SizedBox(height: 10),
                          _BulletItem(
                            number: '1',
                            text: const TextSpan(
                              children: [
                                TextSpan(text: 'Head back to the '),
                                TextSpan(
                                  text: 'Home screen',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2D1B4E),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' and browse your 10 question categories.',
                                ),
                              ],
                            ),
                          ),
                          const _Divider(),
                          _BulletItem(
                            number: '2',
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Each category is designed to spark a ',
                                ),
                                TextSpan(
                                  text: 'different kind of connection',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2D1B4E),
                                  ),
                                ),
                                TextSpan(text: ' with your child.'),
                              ],
                            ),
                          ),
                          const _Divider(),
                          _BulletItem(
                            number: '3',
                            text: const TextSpan(
                              text:
                                  'Pick the one that feels right for the moment and tap to see your question.',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Step 4 - Journal (purple card)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B6BBD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: '📓',
                            text: 'Step 4 — Use the Journal',
                            light: true,
                          ),
                          const SizedBox(height: 10),
                          _BulletItem(
                            number: '1',
                            light: true,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'When you open a question, you\'ll see a ',
                                ),
                                TextSpan(
                                  text: 'Journal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' at the bottom. Tap it to write your thoughts.',
                                ),
                              ],
                            ),
                          ),
                          const _Divider(light: true),
                          _BulletItem(
                            number: '2',
                            light: true,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Write each family member\'s answer separately — for example: ',
                                ),
                                TextSpan(
                                  text: 'Mom:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(text: ' my answer, '),
                                TextSpan(
                                  text: 'Child\'s name:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(text: ' their answer.'),
                              ],
                            ),
                          ),
                          const _Divider(light: true),
                          _BulletItem(
                            number: '3',
                            light: true,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Save your entry. Come back a month later to see if you have ',
                                ),
                                TextSpan(
                                  text: 'implemented the answers',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' in your lives — because many of these questions reveal things you can actually do to bring your family closer.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tip card
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _SectionTitle(icon: '💡', text: 'A Little Tip'),
                          SizedBox(height: 8),
                          Text(
                            'You don\'t have to use the categories in order. Follow your child\'s mood and energy — sometimes the most unexpected question opens the best conversation.',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A3A6A),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Take a Tour Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B6BBD),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.play_circle_fill_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Start Interactive Tour 🚀",
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String icon;
  final String text;
  final bool light;
  const _SectionTitle({
    required this.icon,
    required this.text,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: light ? Colors.white : const Color(0xFF2D1B4E),
            ),
          ),
        ),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String number;
  final TextSpan text;
  final bool light;
  const _BulletItem({
    required this.number,
    required this.text,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: light
                ? Colors.white.withOpacity(0.3)
                : const Color(0xFF8B6BBD),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: light
                    ? Colors.white.withOpacity(0.9)
                    : const Color(0xFF4A3A6A),
                height: 1.55,
              ),
              children: [text],
            ),
          ),
        ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  final String label;
  final Color labelBg;
  final Color labelColor;
  final String text;

  const _TierRow({
    required this.label,
    required this.labelBg,
    required this.labelColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: labelBg,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: labelColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A3A6A),
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool light;
  const _Divider({this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: light
          ? Colors.white.withOpacity(0.2)
          : const Color(0xFF8B6BBD).withOpacity(0.2),
    );
  }
}
