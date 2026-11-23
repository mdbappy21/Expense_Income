import 'package:expense_income/presentation/ui/screen/main_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionOnboardingScreen extends StatefulWidget {
  const IntroductionOnboardingScreen({super.key});

  @override
  State<IntroductionOnboardingScreen> createState() =>
      _IntroductionOnboardingScreenState();
}

class _IntroductionOnboardingScreenState
    extends State<IntroductionOnboardingScreen> {
  static const Color _green = Color(0xFF176B50);
  static const Color _darkGreen = Color(0xFF123F32);
  static const Color _muted = Color(0xFF64746D);
  static const Color _paleGreen = Color(0xFFEAF4EF);
  static const Color _pageBackground = Color(0xFFF8FBF9);

  static const int _pageCount = 4;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;

    setState(() => _isFinishing = true);

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('has_seen_introduction', true);

      if (!mounted) return;
      Get.offAll(() => MainBottomNavBar());
    } catch (error) {
      if (!mounted) return;
      setState(() => _isFinishing = false);

      Get.snackbar(
        'Something went wrong',
        'Unable to save your onboarding preference. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _goToNextPage() {
    if (_currentPage == _pageCount - 1) {
      _finishOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousPage() {
    if (_currentPage == 0) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(),
                  _buildTrackingPage(),
                  _buildPaymentPage(),
                  _buildPrivacyPage(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: _green,
                  size: 21,
                ),
                const SizedBox(width: 8),
                const Text(
                  'SPENDORA',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _isFinishing ? null : _finishOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: _green,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _buildPage(
      title: 'Your money, in one clear view',
      subtitle:
      'Welcome to Spendora. Bring your everyday money records together and understand your financial activity at a glance.',
      visual: _buildOverviewCard(),
      features: [
        _FeatureData(
          icon: Icons.add_circle_outline_rounded,
          title: 'Record transactions',
          description:
          'Add income and expenses with dates, categories, and notes.',
        ),
        _FeatureData(
          icon: Icons.insights_rounded,
          title: 'See the bigger picture',
          description:
          'Review your balance and understand how your money moves.',
        ),
      ],
    );
  }

  Widget _buildTrackingPage() {
    return _buildPage(
      title: 'Know where your money goes',
      subtitle:
      'Record everyday spending and income, then use your dashboard and statistics to review your financial activity.',
      visual: _buildVisualCard(
        icon: Icons.query_stats_rounded,
        eyebrow: 'TRACK YOUR ACTIVITY',
        headline: 'Income & expenses',
        metrics: const [
          _MetricData(Icons.payments_rounded, 'Income records'),
          _MetricData(Icons.shopping_bag_rounded, 'Expense categories'),
          _MetricData(Icons.picture_as_pdf_rounded, 'PDF reports'),
        ],
      ),
      features: [
        _FeatureData(
          icon: Icons.category_rounded,
          title: 'Keep records organized',
          description:
          'Use descriptions and dates to find transactions more easily.',
        ),
        _FeatureData(
          icon: Icons.picture_as_pdf_rounded,
          title: 'Review and share reports',
          description: 'Create PDF summaries of your financial records.',
        ),
      ],
    );
  }

  Widget _buildPaymentPage() {
    return _buildPage(
      title: 'Stay on top of money owed',
      subtitle:
      'Keep track of money you lend and borrow, including partial payments and what remains outstanding.',
      visual: _buildVisualCard(
        icon: Icons.handshake_rounded,
        eyebrow: 'PAYMENT MANAGEMENT',
        headline: 'Know what is pending',
        metrics: const [
          _MetricData(Icons.call_made_rounded, 'Money you lent'),
          _MetricData(Icons.call_received_rounded, 'Money you borrowed'),
          _MetricData(Icons.history_rounded, 'Payment history'),
        ],
      ),
      features: [
        _FeatureData(
          icon: Icons.history_rounded,
          title: 'Record partial payments',
          description: 'See payment dates, amounts, and remaining balances.',
        ),
        _FeatureData(
          icon: Icons.notifications_active_rounded,
          title: 'Remember due dates',
          description:
          'Set reminders for upcoming payable and receivable dates.',
        ),
      ],
    );
  }

  Widget _buildPrivacyPage() {
    return _buildPage(
      title: 'Your records stay on your device',
      subtitle:
      'Spendora is designed for local record keeping. Your financial entries are stored on this device, so you can manage them without creating an online account.',
      visual: _buildVisualCard(
        icon: Icons.phonelink_lock_rounded,
        eyebrow: 'PERSONAL RECORDS',
        headline: 'Local-first by design',
        metrics: const [
          _MetricData(Icons.storage_rounded, 'On-device database'),
          _MetricData(Icons.offline_bolt_rounded, 'No account required'),
          _MetricData(Icons.tune_rounded, 'Your own preferences'),
        ],
      ),
      features: [
        _FeatureData(
          icon: Icons.settings_rounded,
          title: 'Make Spendora yours',
          description: 'Choose your theme and notification preferences.',
        ),
        _FeatureData(
          icon: Icons.rocket_launch_rounded,
          title: 'Ready to get organized?',
          description:
          'Start adding your income, expenses, and payment records.',
        ),
      ],
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required Widget visual,
    required List<_FeatureData> features,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 27,
                    height: 1.16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                visual,
                const SizedBox(height: 24),
                ...features.map(
                      (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildFeatureRow(feature),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkGreen, _green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.20),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'SPENDORA OVERVIEW',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              const Icon(
                Icons.more_horiz_rounded,
                color: Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Your balance',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 5),
          const Text(
            'A clearer money picture',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _OverviewMetric(
                  icon: Icons.trending_up_rounded,
                  label: 'INCOME',
                  value: 'Track it',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _OverviewMetric(
                  icon: Icons.trending_down_rounded,
                  label: 'EXPENSE',
                  value: 'Manage it',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Available balance at a glance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white70,
                  size: 17,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualCard({
    required IconData icon,
    required String eyebrow,
    required String headline,
    required List<_MetricData> metrics,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE5EEE9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160F3D2E),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: _paleGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 29, color: _green),
          ),
          const SizedBox(height: 13),
          Text(
            eyebrow,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _darkGreen,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          ...metrics.map(
                (metric) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(metric.icon, size: 17, color: _green),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      metric.label,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: _green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(_FeatureData feature) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _paleGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(feature.icon, color: _green, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: const TextStyle(
                  color: _darkGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                feature.description,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    final isLastPage = _currentPage == _pageCount - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pageCount,
                  (index) {
                final isActive = index == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 7,
                  width: isActive ? 23 : 7,
                  decoration: BoxDecoration(
                    color: isActive ? _green : const Color(0xFFD7E5DD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: _isFinishing ? null : _goToPreviousPage,
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      color: _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                const SizedBox(width: 60),
              const Spacer(),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _isFinishing ? null : _goToNextPage,
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _isFinishing
                      ? const SizedBox(
                    height: 19,
                    width: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Icon(
                        isLastPage
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _MetricData {
  final IconData icon;
  final String label;

  const _MetricData(this.icon, this.label);
}

class _OverviewMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
