import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'mon_academie_viewmodel.dart';
import 'widgets/course_card.dart';

class MonAcademieView extends StackedView<MonAcademieViewModel> {
  const MonAcademieView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MonAcademieViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, viewModel),
          Expanded(
            child: viewModel.selectedTopTabIndex == 0
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilters(context, viewModel),
                        _buildCourseGrid(context, viewModel),
                        verticalSpaceLarge,
                      ],
                    ),
                  )
                : viewModel.selectedTopTabIndex == 1
                    ? _buildVideoSession(context, viewModel)
                    : _buildComingSoon(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MonAcademieViewModel viewModel) {
    final topTabs = [
      {'label': 'academy.formations'.tr(), 'icon': Icons.menu_book_outlined},
      {'label': 'academy.visio'.tr(), 'icon': Icons.videocam_outlined},
      {'label': 'academy.espace'.tr(), 'icon': Icons.grid_view_outlined},
      {'label': 'academy.certifications'.tr(), 'icon': Icons.workspace_premium_outlined},
    ];

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: kcPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // AppBar Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: kcSecondaryGold, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  'academy.title'.tr().toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: kcSecondaryGold,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: kcSecondaryGold),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Title & Subtitle Section
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topTabs[viewModel.selectedTopTabIndex]['label'] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (viewModel.selectedTopTabIndex == 0)
                  Text(
                    'academy.subtitle'.tr(namedArgs: {'count': viewModel.filteredCourses.length.toString()}),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),

          // Tabs Section
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: topTabs.length,
              itemBuilder: (context, index) {
                final isSelected = viewModel.selectedTopTabIndex == index;
                return InkWell(
                  onTap: () => viewModel.setTopTab(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? kcSecondaryGold : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          topTabs[index]['icon'] as IconData,
                          size: 18,
                          color: isSelected ? kcPrimaryColor : Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          topTabs[index]['label'] as String,
                          style: GoogleFonts.inter(
                            color: isSelected ? kcPrimaryColor : Colors.white.withOpacity(0.7),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, MonAcademieViewModel viewModel) {
    final categories = [
      {'id': 'all', 'label': 'academy.filter_all'.tr()},
      {'id': 'E-commerce', 'label': 'E-commerce'},
      {'id': 'Marketing', 'label': 'Marketing'},
      {'id': 'IA', 'label': 'IA'},
      {'id': 'Analytics', 'label': 'Analytics'},
    ];
    final levels = [
      {'id': 'all', 'label': 'academy.level_all'.tr()},
      {'id': 'beginner', 'label': 'academy.level_beginner'.tr()},
      {'id': 'intermediate', 'label': 'academy.level_intermediate'.tr()},
      {'id': 'advanced', 'label': 'academy.level_advanced'.tr()},
    ];

    return Column(
      children: [
        // Category Filters
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.filter_list, color: kcMediumGrey, size: 20),
                );
              }
              final cat = categories[index - 1];
              final isSelected = viewModel.selectedCategory == cat['id'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: InkWell(
                  onTap: () => viewModel.setCategory(cat['id']!),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kcSecondaryGold : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: kcSecondaryGold.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                      border: Border.all(
                        color: isSelected ? kcSecondaryGold : kcLightGrey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      cat['label']!,
                      style: GoogleFonts.inter(
                        color: isSelected ? kcPrimaryColor : kcMediumGrey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Level Filters
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final lvl = levels[index];
              final isSelected = viewModel.selectedLevel == lvl['id'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: InkWell(
                  onTap: () => viewModel.setLevel(lvl['id']!),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kcPrimaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: kcPrimaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                      border: Border.all(
                        color: isSelected ? kcPrimaryColor : kcLightGrey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      lvl['label']!,
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : kcMediumGrey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseGrid(BuildContext context, MonAcademieViewModel viewModel) {
    if (viewModel.filteredCourses.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine cross axis count based on width
        int crossAxisCount = 1;
        if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        if (crossAxisCount == 1) {
          // List view on mobile
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: viewModel.filteredCourses.length,
            itemBuilder: (context, index) => CourseCard(course: viewModel.filteredCourses[index]),
          );
        } else {
          // Grid view on larger screens
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 0,
              childAspectRatio: 0.85,
            ),
            itemCount: viewModel.filteredCourses.length,
            itemBuilder: (context, index) => CourseCard(course: viewModel.filteredCourses[index]),
          );
        }
      },
    );
  }

  Widget _buildVideoSession(BuildContext context, MonAcademieViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kcPrimaryColor,
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1516321318423-f06f85e504b3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SURA LIVE MENTORING',
                  style: GoogleFonts.outfit(
                    color: kcSecondaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                verticalSpaceSmall,
                Text(
                  'Validez vos acquis avec un expert',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                verticalSpaceMedium,
                Text(
                  'Une fois vos modules terminés à 100%, réservez une session vidéo pour votre entretien de certification.',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceLarge,
          Text(
            'Statut de certification',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kcPrimaryColor,
            ),
          ),
          verticalSpaceSmall,
          _buildStatusCard(
            title: 'Marketing Digital Avancé',
            progress: 100,
            status: 'Prêt pour entretien',
            buttonLabel: 'Réserver mon entretien',
            onPressed: () {},
          ),
          verticalSpaceMedium,
          _buildStatusCard(
            title: 'ZLECAF : Marché Unique',
            progress: 45,
            status: 'En cours...',
            buttonLabel: 'Continuer le cours',
            onPressed: () => viewModel.setTopTab(0),
            isLocked: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required double progress,
    required String status,
    required String buttonLabel,
    required VoidCallback onPressed,
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kcLightGrey.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (progress == 100)
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
          verticalSpaceSmall,
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: kcLightGrey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(progress == 100 ? Colors.green : kcSecondaryGold),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              horizontalSpaceSmall,
              Text('${progress.toInt()}%', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          verticalSpaceMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: TextStyle(color: kcMediumGrey, fontSize: 13, fontWeight: FontWeight.w500)),
              ElevatedButton(
                onPressed: isLocked && progress < 100 ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: progress == 100 ? kcPrimaryColor : kcLightGrey.withOpacity(0.2),
                  foregroundColor: progress == 100 ? kcSecondaryGold : kcMediumGrey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(buttonLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Icon(Icons.auto_stories_outlined, size: 80, color: kcLightGrey.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(
            'Aucun cours disponible',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: kcMediumGrey),
          ),
          const SizedBox(height: 8),
          Text(
            'Revenez plus tard pour découvrir nos formations.',
            style: GoogleFonts.inter(color: kcMediumGrey.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: kcSecondaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.construction_rounded, size: 60, color: kcSecondaryGold),
          ),
          const SizedBox(height: 24),
          Text(
            'academy.coming_soon'.tr(),
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kcPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'academy.coming_soon_desc'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: kcMediumGrey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  MonAcademieViewModel viewModelBuilder(BuildContext context) => MonAcademieViewModel();

  @override
  void onViewModelReady(MonAcademieViewModel viewModel) {
    viewModel.init();
  }
}
