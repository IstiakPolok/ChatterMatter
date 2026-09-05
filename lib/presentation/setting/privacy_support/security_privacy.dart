import 'package:flutter/material.dart';

class SecurityPrivacy extends StatelessWidget {
  const SecurityPrivacy({super.key});

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
                    'Security & Privacy',
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
                  // ── PRIVACY POLICY ─────────────────────────────────────
                  _SectionHeader(
                    icon: '🔒',
                    title: 'Privacy Policy',
                    subtitle:
                        'Effective Date: 25 May 2026   •   Last Updated: 25 May 2026',
                  ),
        
                  const SizedBox(height: 10),
        
                  // Intro
                  _InfoCard(
                    child: const Text(
                      'Chatter Matters is owned and operated by Veenu Inspires, LLC, based in North Carolina, USA. This Privacy Policy explains how we collect, use, and protect your personal information when you use the Chatter Matters mobile application.',
                      style: _bodyStyle,
                    ),
                  ),
        
                  const SizedBox(height: 12),
        
                  // Information We Collect
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(icon: '📋', text: 'Information We Collect'),
                        SizedBox(height: 10),
                        Text(
                          'When you create an account, we collect:',
                          style: _bodyStyle,
                        ),
                        SizedBox(height: 8),
                        _BulletDot(text: 'Your name'),
                        _BulletDot(text: 'Your email address'),
                        SizedBox(height: 8),
                        Text(
                          'We do not collect payment information. All purchases are processed entirely through the Apple App Store or Google Play Store.',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),
        
                  const SizedBox(height: 12),
        
                  // How We Use
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(
                            icon: '⚙️', text: 'How We Use Your Information'),
                        SizedBox(height: 10),
                        Text(
                          'We use your name and email address only to:',
                          style: _bodyStyle,
                        ),
                        SizedBox(height: 8),
                        _BulletDot(text: 'Create and manage your account'),
                        _BulletDot(text: 'Send important app updates'),
                        _BulletDot(
                            text: 'Respond to your support requests'),
                      ],
                    ),
                  ),
        
                  const SizedBox(height: 12),
        
                  // How We Protect
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(
                            icon: '🛡️',
                            text: 'How We Protect Your Information'),
                        SizedBox(height: 10),
                        Text(
                          'We do not sell, rent, or share your personal information with any third party for any commercial or marketing purpose. We use trusted service providers solely to operate the app (including Firebase and RevenueCat). These providers are not permitted to use your data for any purpose beyond supporting the operation of Chatter Matters.',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),
        
                  const SizedBox(height: 12),
        
                  // Children's Privacy
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(
                            icon: '👧', text: "Children's Privacy"),
                        SizedBox(height: 10),
                        Text(
                          'Chatter Matters is designed for use by adults, including parents and caregivers. We do not knowingly collect personal information from anyone under the age of 13. If you believe a child has provided us with personal information, please contact us immediately at veenuinspires@gmail.com and we will remove that information promptly.',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),
        
                  const SizedBox(height: 12),
        
                  // Your Rights
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(icon: '✅', text: 'Your Rights'),
                        SizedBox(height: 10),
                        Text('You have the right to:', style: _bodyStyle),
                        SizedBox(height: 8),
                        _BulletDot(
                            text:
                                'Access the personal information we hold about you'),
                        _BulletDot(
                            text:
                                'Request correction of inaccurate information'),
                        _BulletDot(
                            text:
                                'Request deletion of your account and personal data'),
                        SizedBox(height: 8),
                        Text(
                          'To exercise any of these rights, please contact us at veenuinspires@gmail.com.',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),
        
                  const SizedBox(height: 12),
        
                  // Data Retention & Governing Law (combined)
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _CardTitle(icon: '🗓️', text: 'Data Retention'),
                        SizedBox(height: 8),
                        Text(
                          'We retain your name and email address only for as long as your account remains active. Upon request, we will delete your data within a reasonable timeframe.',
                          style: _bodyStyle,
                        ),
                        SizedBox(height: 16),
                        _CardTitle(icon: '⚖️', text: 'Governing Law'),
                        SizedBox(height: 8),
                        Text(
                          'This Privacy Policy is governed by the laws of the State of North Carolina, USA.',
                          style: _bodyStyle,
                        ),
                        SizedBox(height: 16),
                        _CardTitle(icon: '✉️', text: 'Contact Us'),
                        SizedBox(height: 8),
                        Text(
                          'If you have any questions about this Privacy Policy, please contact us at veenuinspires@gmail.com.',
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

/// Big section header that separates Privacy Policy from Terms of Use
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

class _BulletDot extends StatelessWidget {
  final String text;
  const _BulletDot({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 5, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF8B6BBD),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(text, style: _bodyStyle),
          ),
        ],
      ),
    );
  }
}
