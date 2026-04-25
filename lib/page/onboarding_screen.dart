import 'package:cubebook/page/settings_page/appearance.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/neo/neo_background.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:provider/provider.dart';

/// Onboarding screen for first-time users
/// Shows introduction pages covering key features and settings
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final GlobalKey<IntroductionScreenState> _introKey =
      GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NeoBackground(
      pattern: NeoBackgroundPattern.halftone,
      opacity: 0.03,
      child: IntroductionScreen(
        key: _introKey,
        globalBackgroundColor: Colors.transparent,
        allowImplicitScrolling: true,
        infiniteAutoScroll: false,
        globalHeader: Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: _buildSkipButton(),
            ),
          ),
        ),
        pages: [
          _buildWelcomePage(isDark),
          _buildAppearancePage(isDark),
          _buildSyncPage(isDark),
          _buildAIPage(isDark),
          _buildCompletePage(isDark),
        ],
        onDone: _onIntroEnd,
        onSkip: _onIntroEnd,
        showSkipButton: false,
        showBackButton: true,
        showNextButton: true,
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBottomPart: true,
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(8),
        controlsPadding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        dotsDecorator: DotsDecorator(
          size: const Size(12.0, 12.0),
          color: isDark ? NeoBrutalColors.lightText.withAlpha(80) : NeoBrutalColors.ink.withAlpha(80),
          activeSize: const Size(28.0, 12.0),
          activeColor: NeoBrutalColors.red,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: isDark ? NeoBrutalColors.lightText : NeoBrutalColors.ink, width: 2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: isDark ? NeoBrutalColors.lightText : NeoBrutalColors.ink, width: 2),
          ),
        ),
        next: _buildNeoNextButton(),
        back: _buildNeoBackButton(),
        done: _buildNeoDoneButton(),
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: _onIntroEnd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: NeoBrutalColors.white,
          border: Border.all(width: 3, color: NeoBrutalColors.ink),
          boxShadow: NeoBrutalColors.hardShadowSmall(),
        ),
        child: Text(
          L10n.of(context).onboardingSkip.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: NeoBrutalColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildNeoNextButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: NeoBrutalColors.red,
        border: Border.all(width: 3, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowSmall(),
      ),
      child: IconButton(
        onPressed: () => _introKey.currentState?.next(),
        icon: const Icon(
          Icons.arrow_forward,
          color: NeoBrutalColors.white,
          size: 22,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildNeoBackButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: NeoBrutalColors.white,
        border: Border.all(width: 3, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowSmall(),
      ),
      child: IconButton(
        onPressed: () => _introKey.currentState?.previous(),
        icon: const Icon(
          Icons.arrow_back,
          color: NeoBrutalColors.ink,
          size: 22,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildNeoDoneButton() {
    return GestureDetector(
      onTap: _onIntroEnd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: NeoBrutalColors.yellow,
          border: Border.all(width: 3, color: NeoBrutalColors.ink),
          boxShadow: NeoBrutalColors.hardShadowSmall(),
        ),
        child: Text(
          L10n.of(context).onboardingDone.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: NeoBrutalColors.ink,
          ),
        ),
      ),
    );
  }

  PageViewModel _buildWelcomePage(bool isDark) {
    return PageViewModel(
      title: L10n.of(context).onboardingWelcomeTitle,
      body: L10n.of(context).onboardingWelcomeBody,
      image: _buildIconPage(Icons.book_outlined),
      decoration: _getPageDecoration(isDark),
    );
  }

  PageViewModel _buildAppearancePage(bool isDark) {
    return PageViewModel(
      title: '',
      bodyWidget: _buildAppearanceSettings(isDark),
      decoration: _getPageDecoration(isDark),
    );
  }

  PageViewModel _buildSyncPage(bool isDark) {
    return PageViewModel(
      title: L10n.of(context).onboardingSyncTitle,
      bodyWidget: _buildPageWithTip(isDark, L10n.of(context).onboardingSyncBody, L10n.of(context).onboardingSyncTip),
      image: _buildIconPage(Icons.sync_outlined),
      decoration: _getPageDecoration(isDark),
    );
  }

  PageViewModel _buildAIPage(bool isDark) {
    return PageViewModel(
      title: L10n.of(context).onboardingAiTitle,
      bodyWidget: _buildPageWithTip(isDark, L10n.of(context).onboardingAiBody, L10n.of(context).onboardingAiTip),
      image: _buildIconPage(Icons.auto_awesome_outlined),
      decoration: _getPageDecoration(isDark),
    );
  }

  PageViewModel _buildCompletePage(bool isDark) {
    return PageViewModel(
      title: L10n.of(context).onboardingCompleteTitle,
      body: L10n.of(context).onboardingCompleteBody,
      image: _buildIconPage(Icons.check_circle_outline),
      decoration: _getPageDecoration(isDark),
    );
  }

  Widget _buildIconPage(IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? NeoBrutalColors.lightText : NeoBrutalColors.ink;
    return Container(
      decoration: BoxDecoration(
        color: NeoBrutalColors.yellow,
        border: Border.all(width: 4, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowMedium(),
      ),
      padding: const EdgeInsets.all(40),
      child: Icon(
        icon,
        size: 100,
        color: iconColor,
      ),
    );
  }

  PageDecoration _getPageDecoration(bool isDark) {
    final textColor = isDark ? NeoBrutalColors.lightText : NeoBrutalColors.ink;
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'Space Grotesk',
        color: textColor,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 18.0,
        fontFamily: 'SourceHanSerif',
        color: textColor,
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.transparent,
      imagePadding: const EdgeInsets.symmetric(vertical: 40.0),
    );
  }

  Widget _buildAppearanceSettings(bool isDark) {
    final textColor = isDark ? NeoBrutalColors.lightText : NeoBrutalColors.ink;

    Widget buildLanguageSelector() {
      final currentLocale = Prefs().locale;
      final currentLanguageCode = currentLocale?.languageCode ?? 'System';
      final currentCountryCode = currentLocale?.countryCode ?? '';
      final currentLanguageTag = currentLanguageCode +
          (currentCountryCode.isNotEmpty ? '-$currentCountryCode' : '');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: NeoBrutalColors.white,
                  border: Border.all(width: 2, color: NeoBrutalColors.ink),
                ),
                child: Icon(
                  Icons.language,
                  color: NeoBrutalColors.ink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                L10n.of(context).settingsAppearanceLanguage,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Space Grotesk',
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: NeoBrutalColors.white,
              border: Border.all(
                color: NeoBrutalColors.ink,
                width: 3,
              ),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: languageOptions.any(
                      (option) => option.values.first == currentLanguageTag)
                  ? currentLanguageTag
                  : 'system',
              style: TextStyle(
                color: isDark ? NeoBrutalColors.ink : Colors.black87,
                fontWeight: FontWeight.w600,
                fontFamily: 'Space Grotesk',
                fontSize: 14,
              ),
              dropdownColor: NeoBrutalColors.white,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    Prefs().saveLocaleToPrefs(newValue);
                  });
                }
              },
              items: languageOptions
                  .map<DropdownMenuItem<String>>((Map<String, String> option) {
                final displayName = option.keys.first;
                final languageCode = option.values.first;
                return DropdownMenuItem<String>(
                  value: languageCode,
                  child: Text(
                    displayName,
                    style: TextStyle(
                      color: isDark ? NeoBrutalColors.ink : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    Widget buildThemeColorSelector() {
      final List<Color> themeColors = [
        Colors.purple,
        Colors.indigo,
        Colors.blue,
        Colors.cyan,
        Colors.teal,
        Colors.green,
        Colors.lime,
        Colors.amber,
        Colors.orange,
        Colors.deepOrange,
        Colors.pink,
        Colors.red,
      ]..reversed.toList();

      final currentThemeColor = Prefs().themeColor;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: NeoBrutalColors.white,
                  border: Border.all(width: 2, color: NeoBrutalColors.ink),
                ),
                child: Icon(
                  Icons.palette,
                  color: NeoBrutalColors.ink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                L10n.of(context).settingsAppearanceThemeColor,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Space Grotesk',
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: themeColors.length,
            itemBuilder: (context, index) {
              final color = themeColors[index];
              final isSelected =
                  color.toARGB32() == currentThemeColor.toARGB32();

              return GestureDetector(
                onTap: () {
                  setState(() {
                    Prefs().saveThemeToPrefs(color.toARGB32());
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 0,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      );
    }

    return Consumer<Prefs>(
      builder: (context, prefs, child) {
        final currentIsDark = Theme.of(context).brightness == Brightness.dark;
        final currentTextColor = currentIsDark ? NeoBrutalColors.lightText : NeoBrutalColors.ink;
        return SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: NeoBrutalColors.yellow,
                      border: Border.all(width: 4, color: NeoBrutalColors.ink),
                      boxShadow: NeoBrutalColors.hardShadowMedium(),
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      size: 48,
                      color: NeoBrutalColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    L10n.of(context).settingsAppearance,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Space Grotesk',
                      color: currentTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    L10n.of(context).customizeYourExperience,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SourceHanSerif',
                      color: currentTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              buildLanguageSelector(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: NeoBrutalColors.white,
                      border: Border.all(width: 2, color: NeoBrutalColors.ink),
                    ),
                    child: Icon(
                      Icons.contrast,
                      color: NeoBrutalColors.ink,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.of(context).eInkMode,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Space Grotesk',
                            color: currentTextColor,
                          ),
                        ),
                        Text(
                          L10n.of(context).optimizedForEInkDisplays,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'SourceHanSerif',
                            color: currentTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: prefs.eInkMode,
                    onChanged: (value) {
                      setState(() {
                        if (value) {
                          prefs.saveThemeModeToPrefs('light');
                        }
                        prefs.eInkMode = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              buildThemeColorSelector(),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NeoBrutalColors.white,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    color: NeoBrutalColors.ink,
                    width: 3,
                  ),
                  boxShadow: NeoBrutalColors.hardShadowSmall(),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: NeoBrutalColors.yellow,
                        border: Border.all(width: 2, color: NeoBrutalColors.ink),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: NeoBrutalColors.ink,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        L10n.of(context).moreDisplayOptionsTip,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Space Grotesk',
                          color: NeoBrutalColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageWithTip(bool isDark, String bodyText, String tipText) {
    final textColor = isDark ? NeoBrutalColors.lightText : NeoBrutalColors.ink;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          bodyText,
          style: TextStyle(
            fontSize: 18.0,
            fontFamily: 'SourceHanSerif',
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NeoBrutalColors.white,
            borderRadius: BorderRadius.zero,
            border: Border.all(
              color: NeoBrutalColors.ink,
              width: 3,
            ),
            boxShadow: NeoBrutalColors.hardShadowSmall(),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: NeoBrutalColors.yellow,
                  border: Border.all(width: 2, color: NeoBrutalColors.ink),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: NeoBrutalColors.ink,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tipText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Space Grotesk',
                    color: NeoBrutalColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onIntroEnd() async {
    widget.onComplete();
  }
}
