import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/widgets/settings_action_card.dart';

class SupportScreen extends StatelessWidget {
  static const List<FaqItem> _defaultFaqItems = [
    FaqItem(
      question: 'How can I edit my personal profile?',
      answer:
          'Go to Settings, open Profile, tap Edit profile, then save your changes.',
    ),
    FaqItem(
      question: 'How do I save or unsave mates and trips?',
      answer:
          'Open any mate detail or trip schedule and tap the bookmark button to toggle saved state.',
    ),
    FaqItem(
      question: 'Are my profile and privacy settings persistent?',
      answer:
          'Yes. Your profile and privacy toggles are stored locally and restored when the app restarts.',
    ),
  ];

  final List<FaqItem> faqItems;

  const SupportScreen({super.key, this.faqItems = _defaultFaqItems});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.settingsSupportTitle,
          style: AppTextStyles.titleLg(sizes).copyWith(color: AppColors.yellow),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            sizes.padL,
            sizes.padL,
            sizes.padL,
            sizes.padL * 1.4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SupportExpandableCard(
                title: AppStrings.supportFaqTitle,
                icon: Icons.quiz_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: faqItems
                      .map((item) => _FaqItemView(item: item))
                      .toList(growable: false),
                ),
              ),
              SizedBox(height: sizes.padS),
              _SupportExpandableCard(
                title: AppStrings.supportContactTitle,
                icon: Icons.support_agent_rounded,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(AppStrings.supportContactedMessage),
                        ),
                      );
                    },
                    child: const Text(AppStrings.supportContactTitle),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportExpandableCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SupportExpandableCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return SettingsActionCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: sizes.padM,
            vertical: sizes.padXs * 0.5,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            sizes.padM,
            0,
            sizes.padM,
            sizes.padM,
          ),
          collapsedIconColor: AppColors.black,
          iconColor: AppColors.black,
          title: Row(
            children: [
              Icon(icon, color: AppColors.black, size: sizes.iconM * 0.7),
              SizedBox(width: sizes.padS),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleLg(
                    sizes,
                  ).copyWith(fontSize: sizes.textMd),
                ),
              ),
            ],
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _FaqItemView extends StatelessWidget {
  final FaqItem item;

  const _FaqItemView({required this.item});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: sizes.padS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: AppTextStyles.bodyMd(
              sizes,
            ).copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: sizes.padXs * 0.7),
          Text(
            item.answer,
            style: AppTextStyles.bodyMd(
              sizes,
            ).copyWith(color: AppColors.blackAlpha60),
          ),
        ],
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}
