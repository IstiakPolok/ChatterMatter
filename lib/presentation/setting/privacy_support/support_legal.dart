import 'package:flutter/material.dart';

class SupportLegal extends StatelessWidget {
  const SupportLegal({super.key});

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
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 6),
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
                    'Support & Legal',
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
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  // ── TERMS OF USE ─────────────────────────────────────
                  _SectionHeader(
                    icon: '📄',
                    title: 'Terms of Use',
                    subtitle:
                        'Effective Date: 25 May 2026   •   Last Updated: 25 May 2026',
                  ),

                  const SizedBox(height: 10),

                  // Intro
                  _InfoCard(
                    child: const Text(
                      'By downloading or using Chatter Matters, you agree to the following terms. Please read them carefully.',
                      style: _bodyStyle,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // About the App
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(icon: '📱', text: 'About the App'),
                        SizedBox(height: 10),
                        Text(
                          'Chatter Matters is a conversation tool designed to help parents and caregivers connect more meaningfully with their children. The app is intended for use by adults aged 18 and older.',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Purchases and Refunds
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(icon: '💳', text: 'Purchases and Refunds'),
                        SizedBox(height: 10),
                        Text(
                          'Chatter Matters is available as a one-time purchase through the Apple App Store or Google Play Store. All billing is handled directly by Apple or Google. For refund requests, please contact Apple or Google support directly, as we do not process payments or refunds.',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Intellectual Property (dark purple card)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B6BBD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(
                          icon: '©️',
                          text: 'Intellectual Property',
                          light: true,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'All content within Chatter Matters, including questions, categories, and design, is the intellectual property of Veenu Inspires, LLC. You may not reproduce, distribute, or use any content from this app without written permission.',
                          style: _bodyStyleLight,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Limitation of Liability
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(icon: '⚠️', text: 'Limitation of Liability'),
                        SizedBox(height: 10),
                        Text(
                          'Chatter Matters is provided for informational and connection purposes only. Veenu Inspires, LLC is not responsible for any outcomes resulting from the use of questions or content within the app. Use of the app is at your own discretion.',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Changes, Governing Law, Contact
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(icon: '🔄', text: 'Changes to These Terms'),
                        SizedBox(height: 8),
                        Text(
                          'We reserve the right to update these terms at any time. Continued use of the app following any changes means you accept the updated terms.',
                          style: _bodyStyle,
                        ),
                        SizedBox(height: 16),
                        _CardTitle(icon: '⚖️', text: 'Governing Law'),
                        SizedBox(height: 8),
                        Text(
                          'These Terms of Use are governed by the laws of the State of North Carolina, USA.',
                          style: _bodyStyle,
                        ),
                        SizedBox(height: 16),
                        _CardTitle(icon: '📬', text: 'Contact and Support'),
                        SizedBox(height: 8),
                        Text(
                          'For questions, concerns, or support, please contact us at:\n\nveenuinspires@gmail.com\n\nWe aim to respond to all inquiries within 3 to 5 business days.',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared text styles ────────────────────────────────────────────────────────

const _bodyStyle = TextStyle(
  fontFamily: 'Nunito Sans',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Color(0xFF4A3A6A),
  height: 1.65,
);

const _bodyStyleLight = TextStyle(
  fontFamily: 'Nunito Sans',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Colors.white,
  height: 1.65,
);

// ── Reusable widgets ──────────────────────────────────────────────────────────

/// Big section header
class _SectionHeader extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D1B4E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7A6A9A),
          ),
        ),
      ],
    );
  }
}

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

class _CardTitle extends StatelessWidget {
  final String icon;
  final String text;
  final bool light;
  const _CardTitle({
    required this.icon,
    required this.text,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: light ? Colors.white : const Color(0xFF2D1B4E),
            ),
          ),
        ),
      ],
    );
  }
}
