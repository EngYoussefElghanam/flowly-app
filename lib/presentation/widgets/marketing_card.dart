import 'package:flutter/material.dart';
import 'package:flowly/data/models/marketing_opportunity.dart';

class MarketingCard extends StatelessWidget {
  final MarketingOpportunity opportunity;

  const MarketingCard({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    // 🎨 VIPs get Gold, Others get Blue
    final isVip = opportunity.type == 'VIP_REWARD';

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    // Theme-driven palette
    final accent = cs.secondary; // Your AppTheme blue in both modes

    // VIP "gold" that adapts to brightness (still VIP without looking cheap)
    final vipA = isLight ? const Color(0xFFD6A84A) : const Color(0xFFB9862F);
    final vipB = isLight ? const Color(0xFFFFE082) : const Color(0xFFFFD18A);

    // Gradient colors now based on theme
    final gradientColors = isVip
        ? [vipA, vipB]
        : [
            accent.withOpacity(isLight ? 0.95 : 0.90),
            accent.withOpacity(isLight ? 0.70 : 0.55),
          ];

    // On-gradient text color (always readable)
    final onGradient = Colors.white;

    // Footer should match your theme card surface
    final footerBg = cs.surface;
    final footerText = cs.onSurface;

    // Soft borders that work on both modes
    final glassBorder = Border.all(
      color: Colors.white.withOpacity(isLight ? 0.18 : 0.12),
      width: 1,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isVip ? vipA : accent).withOpacity(isLight ? 0.22 : 0.14),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isLight ? 0.06 : 0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle highlight overlay (adapts)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(isLight ? 0.16 : 0.10),
                        Colors.transparent,
                        Colors.black.withOpacity(isLight ? 0.10 : 0.20),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Soft corner sheen
            Positioned(
              top: -60,
              left: -60,
              child: IgnorePointer(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(isLight ? 0.18 : 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🏷️ Header (Badge)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            isLight ? 0.16 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              isLight ? 0.22 : 0.14,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVip
                                  ? Icons.star_rounded
                                  : Icons.history_rounded,
                              color: onGradient.withOpacity(0.95),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isVip ? "VIP REWARD" : "WIN BACK",
                              style: TextStyle(
                                color: onGradient.withOpacity(0.95),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: onGradient.withOpacity(isLight ? 0.60 : 0.45),
                        size: 22,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 💬 The AI Message (Center Stage)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isLight ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: glassBorder,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "“",
                            style: TextStyle(
                              color: onGradient.withOpacity(
                                isLight ? 0.65 : 0.55,
                              ),
                              fontSize: 42,
                              height: 0.9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          opportunity.aiMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: onGradient,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.22,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // 👤 Customer Info Footer (NOW THEME SURFACE)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: footerBg,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: (isLight ? Colors.black : Colors.white)
                            .withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isLight ? 0.08 : 0.35,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: isVip
                              ? (isLight
                                    ? vipB.withOpacity(0.35)
                                    : vipB.withOpacity(0.22))
                              : accent.withOpacity(isLight ? 0.18 : 0.14),
                          child: Text(
                            opportunity.customer.name[0].toUpperCase(),
                            style: TextStyle(
                              color: isVip ? vipA : accent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              opportunity.customer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: footerText,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Loves: ${opportunity.customer.favoriteItem ?? 'Everything'}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: footerText.withOpacity(0.65),
                                fontSize: 12.5,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: (isVip ? vipA : accent).withOpacity(
                            isLight ? 0.12 : 0.18,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          size: 18,
                          color: isVip ? vipA : accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
