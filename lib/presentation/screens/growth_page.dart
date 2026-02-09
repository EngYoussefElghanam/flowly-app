import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

// Logic
import '../../logic/cubits/auth_cubit.dart';
import '../../logic/cubits/marketing_cubit.dart';
import '../../logic/cubits/dashboard_cubit.dart';

// Widgets
import '../widgets/business_state_card.dart';
import '../widgets/operational_highlights.dart';
import '../widgets/marketing_card.dart';

class GrowthPage extends StatefulWidget {
  const GrowthPage({super.key});

  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> {
  final AppinioSwiperController swiperController = AppinioSwiperController();

  Future<void> _launchWhatsApp(String phone, String message) async {
    // 1. Clean the number (remove spaces, dashes, parentheses)
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // 2. WhatsApp API requires an international code
    // If your cleanPhone starts with '01', it's likely a local Egyptian number.
    // We strip the '0' and add '20'. Adjust this logic if you serve other countries.
    if (cleanPhone.startsWith('01')) {
      cleanPhone = '20${cleanPhone.substring(1)}';
    }

    // 3. Encode the message properly
    final encodedMessage = Uri.encodeComponent(message);

    // 4. Try the Universal Link first (wa.me)
    final webUrl = Uri.parse("https://wa.me/$cleanPhone?text=$encodedMessage");

    // 5. Try the Native Deep Link as fallback (whatsapp://)
    final nativeUrl = Uri.parse(
      "whatsapp://send?phone=$cleanPhone&text=$encodedMessage",
    );

    try {
      // First try opening the app directly
      if (await canLaunchUrl(nativeUrl)) {
        await launchUrl(nativeUrl);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Could not launch WhatsApp. Check if it's installed.",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("WhatsApp Launch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. 🔐 AUTH GUARD
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return const SizedBox.shrink();

    final token = authState.user.token;
    final user = authState.user; // We use this for Role Check
    final theme = Theme.of(context);
    final String titleName = user.role == 'OWNER' ? user.name : "The Business";
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Growth Engine",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Text(
              "Opportunities for $titleName",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      // 🔄 3. WRAP EVERYTHING IN DASHBOARD CUBIT
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, dashboardState) {
          if (dashboardState is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardState is DashboardError) {
            return Center(
              child: Text("Error loading dashboard: ${dashboardState.message}"),
            );
          }

          if (dashboardState is DashboardSuccess) {
            final stats = dashboardState.stats;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔒 ROLE CHECK: Only OWNER sees the Financial Stats
                  if (user.role == 'OWNER') ...[
                    BusinessStatsCard(stats: stats),
                    const SizedBox(height: 10),
                  ] else ...[
                    // Small spacing for Employee instead of the big card
                    const SizedBox(height: 20),
                  ],

                  // ... (Marketing Title Section) ...
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text(
                          "AI Revenue Generator",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "BETA",
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🎠 Middle Section: Swiper (Visible to BOTH)
                  SizedBox(
                    height: 420,
                    child: BlocBuilder<MarketingCubit, MarketingState>(
                      builder: (context, marketingState) {
                        if (marketingState is MarketingLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          );
                        }
                        if (marketingState is MarketingEmpty) {
                          return _buildEmptyState(theme);
                        }
                        if (marketingState is MarketingLoaded) {
                          return AppinioSwiper(
                            controller: swiperController,
                            cardCount: marketingState.opportunities.length,
                            backgroundCardCount: 0,
                            onEnd: () {
                              context.read<MarketingCubit>().forceEmpty();
                            },
                            onSwipeEnd: (previousIndex, targetIndex, activity) {
                              if (activity is Swipe) {
                                final direction = activity.direction;
                                if (previousIndex >=
                                    marketingState.opportunities.length) {
                                  return;
                                }
                                final opp =
                                    marketingState.opportunities[previousIndex];
                                final dirString = direction
                                    .toString()
                                    .toLowerCase();

                                if (dirString.contains('right')) {
                                  _launchWhatsApp(
                                    opp.customer.phone ?? "",
                                    opp.aiMessage,
                                  );
                                  context.read<MarketingCubit>().handleAction(
                                    token,
                                    "SENT",
                                    opp.id,
                                  );
                                } else if (dirString.contains('left')) {
                                  context.read<MarketingCubit>().handleAction(
                                    token,
                                    "SNOOZED",
                                    opp.id,
                                  );
                                } else {
                                  context.read<MarketingCubit>().handleAction(
                                    token,
                                    "DISMISSED",
                                    opp.id,
                                  );
                                }
                              }
                            },
                            cardBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: MarketingCard(
                                  opportunity:
                                      marketingState.opportunities[index],
                                ),
                              );
                            },
                          );
                        } else if (marketingState is MarketingError) {
                          return Center(
                            child: Text("Error: ${marketingState.message}"),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Operational Highlights",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📉 Bottom Section: Highlights (Visible to BOTH)
                  OperationalHighlights(stats: stats),

                  const SizedBox(height: 40),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white10
              : Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 60, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              "All caught up!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              "Great job clearing your leads.",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
