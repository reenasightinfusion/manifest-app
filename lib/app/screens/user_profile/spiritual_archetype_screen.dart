import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/common/core.dart';
import '../../services/user_provider.dart';
import '../../widgets/primary_button.dart';

class SpiritualArchetypeScreen extends StatelessWidget {
  const SpiritualArchetypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final archetype = _calculateArchetype(userProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.h,
            pinned: true,
            backgroundColor: AppColors.purple,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Base Ambient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          archetype.gradientColors[0].withValues(alpha: 0.8),
                          archetype.gradientColors[1].withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Dynamic Aura Layers
                  Positioned(
                    top: -100.h,
                    left: -100.w,
                    child: Container(
                      width: 400.r,
                      height: 400.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.white.withValues(alpha: 0.15),
                            AppColors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: -150.w,
                    child: Container(
                      width: 500.r,
                      height: 500.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            archetype.gradientColors[0].withValues(alpha: 0.3),
                            archetype.gradientColors[0].withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Subtle Large Icon Overlay
                  Positioned(
                    bottom: -30.h,
                    right: -20.w,
                    child: Icon(
                      archetype.icon,
                      size: 260.sp,
                      color: AppColors.white.withValues(alpha: 0.08),
                    ),
                  ),

                  // Header Content with subtle protection
                  Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'COSMIC FOOTPRINT',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.white,
                              letterSpacing: 2.0,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        16.verticalSpace,
                        Text(
                          archetype.name,
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.white,
                            fontSize: 38.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: AppColors.black.withValues(alpha: 0.1),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'The Essence',
                    icon: Icons.auto_awesome,
                  ),
                  16.verticalSpace,
                  Text(
                    archetype.description,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textGrey,
                      height: 1.6,
                    ),
                  ),
                  32.verticalSpace,
                  _SectionHeader(title: 'Core Strengths', icon: Icons.bolt),
                  16.verticalSpace,
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: archetype.strengths
                        .map(
                          (s) => _StrengthChip(
                            label: s,
                            color: archetype.gradientColors[0],
                          ),
                        )
                        .toList(),
                  ),
                  32.verticalSpace,
                  _SectionHeader(
                    title: 'Spiritual Vision',
                    icon: Icons.remove_red_eye,
                  ),
                  16.verticalSpace,
                  _VisionCard(
                    text: archetype.vision,
                    color: archetype.gradientColors[0],
                  ),
                  40.verticalSpace,
                  PrimaryButton(
                    label: 'Continue My Journey',
                    onPressed: () => Navigator.pop(context),
                  ),
                  40.verticalSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ArchetypeData _calculateArchetype(UserProvider user) {
    // Mock logic based on keywords in answers
    final allAnswers =
        (user.personalAnswers + user.familyAnswers + user.professionalAnswers)
            .join(' ')
            .toLowerCase();

    if (allAnswers.contains('art') ||
        allAnswers.contains('creative') ||
        allAnswers.contains('build')) {
      return _ArchetypeData(
        name: 'The Creative Catalyst',
        description:
            'You possess a rare ability to transform abstract ideas into tangible reality. Your spirit thrives on expression and the constant desire to innovate and inspire.',
        strengths: ['Imagination', 'Authenticity', 'Fluidity'],
        vision:
            'Your path involves using your unique voice to bridge the gap between the mundane and the magical.',
        icon: Icons.palette_rounded,
        gradientColors: [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      );
    } else if (allAnswers.contains('business') ||
        allAnswers.contains('money') ||
        allAnswers.contains('system')) {
      return _ArchetypeData(
        name: 'The Abundance Architect',
        description:
            'You see the world as a series of structures waiting to be optimized. You understand that true wealth is built on a foundation of integrity and strategic vision.',
        strengths: ['Strategy', 'Efficiency', 'Stability'],
        vision:
            'You are destined to build systems that generate lasting impact for yourself and those around you.',
        icon: Icons.architecture_rounded,
        gradientColors: [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      );
    } else if (allAnswers.contains('help') ||
        allAnswers.contains('serve') ||
        allAnswers.contains('people')) {
      return _ArchetypeData(
        name: 'The Purposeful Pathfinder',
        description:
            'Your heart is tuned to the needs of the collective. You find your greatest fulfillment in guiding others toward their own light and clarity.',
        strengths: ['Empathy', 'Guidance', 'Resilience'],
        vision:
            'Your journey is one of service, finding meaning in the connections you forge and the lives you touch.',
        icon: Icons.explore_rounded,
        gradientColors: [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      );
    } else {
      return _ArchetypeData(
        name: 'The Manifesting Mystic',
        description:
            'You are deeply attuned to the rhythms of the universe. You understand that the outer world is a reflection of your inner state, and you prioritize spiritual alignment above all.',
        strengths: ['Intuition', 'Presence', 'Alignment'],
        vision:
            'Your primary task is to maintain your vibrance, allowing your dreams to manifest with effortless grace.',
        icon: Icons.auto_awesome_rounded,
        gradientColors: [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.purple, size: 24.sp),
        12.horizontalSpace,
        Text(
          title.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: AppColors.textDark,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _StrengthChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StrengthChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _VisionCard extends StatelessWidget {
  final String text;
  final Color color;

  const _VisionCard({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, color: color, size: 24.sp),
          ),
          16.horizontalSpace,
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchetypeData {
  final String name;
  final String description;
  final List<String> strengths;
  final String vision;
  final IconData icon;
  final List<Color> gradientColors;

  _ArchetypeData({
    required this.name,
    required this.description,
    required this.strengths,
    required this.vision,
    required this.icon,
    required this.gradientColors,
  });
}
