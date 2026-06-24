import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:promogoai/ui/common/ui_helpers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'mon_academie_viewmodel.dart';
import 'widgets/course_card.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/models/course_model.dart';


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
                    : viewModel.selectedTopTabIndex == 2
                        ? _buildMySpace(context, viewModel)
                        : _buildCertifications(context, viewModel),
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
    // Le filtre "Toutes" est toujours présent, puis on ajoute les tags du backend
    final categories = [
      {'id': 'all', 'label': 'academy.filter_all'.tr()},
      ...viewModel.tags.map((t) => {'id': t.title, 'label': t.title}).toList(),
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
    if (viewModel.isBusy && viewModel.courses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: CircularProgressIndicator(color: kcPrimaryColor),
        ),
      );
    }

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
            itemBuilder: (context, index) {
              final course = viewModel.filteredCourses[index];
              return CourseCard(
                course: course,
                progress: viewModel.getProgressForCourse(course.id),
                onTap: () async {
                  final navigationService = locator<NavigationService>();
                  await navigationService.navigateTo(
                    Routes.courseDetailView,
                    arguments: CourseDetailViewArguments(courseId: course.id),
                  );
                  await viewModel.loadAllProgress();
                  await viewModel.loadCertificates();
                },
              );
            },
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
            itemBuilder: (context, index) {
              final course = viewModel.filteredCourses[index];
              return CourseCard(
                course: course,
                progress: viewModel.getProgressForCourse(course.id),
                onTap: () async {
                  final navigationService = locator<NavigationService>();
                  await navigationService.navigateTo(
                    Routes.courseDetailView,
                    arguments: CourseDetailViewArguments(courseId: course.id),
                  );
                  await viewModel.loadAllProgress();
                  await viewModel.loadCertificates();
                },
              );
            },
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
          if (viewModel.courses.isEmpty)
             const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Aucun cours trouvé"))),
          ...viewModel.courses.map((course) {
            final progress = viewModel.getProgressForCourse(course.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildStatusCard(
                title: course.title,
                progress: progress,
                status: progress >= 100 ? 'Prêt pour entretien' : 'En cours...',
                buttonLabel: progress >= 100 ? 'Réserver mon entretien' : 'Continuer le cours',
                onPressed: () {
                  if (progress < 100) {
                    viewModel.setTopTab(0);
                  } else {
                    _showVisioBookingDialog(context, course, viewModel);
                  }
                },
                isLocked: progress < 100,
              ),
            );
          }).toList(),
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
                  valueColor: AlwaysStoppedAnimation<Color>(progress >= 100 ? kcSuccessColor : kcSecondaryGold),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              horizontalSpaceSmall,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: progress >= 100 ? kcSuccessColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  progress >= 100 ? 'READY' : '${progress.toInt()}%', 
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800, 
                    fontSize: 12,
                    color: progress >= 100 ? kcSuccessColor : kcPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          verticalSpaceMedium,
          Row(
            children: [
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    color: progress >= 100 ? kcSuccessColor : kcMediumGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: progress >= 100 ? kcPrimaryColor : kcSecondaryGold.withOpacity(0.1),
                  foregroundColor: progress >= 100 ? Colors.white : kcPrimaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
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

  Widget _buildMySpace(BuildContext context, MonAcademieViewModel viewModel) {
    final activeCourse = viewModel.activeCourse;
    final progress = activeCourse != null ? viewModel.getProgressForCourse(activeCourse.id) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enrolled/Resume Course Section
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: kcSecondaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'academy.resume_course'.tr().toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kcPrimaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activeCourse != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F1E36), Color(0xFF081326)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: kcSecondaryGold.withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kcPrimaryColor.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: kcSecondaryGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kcSecondaryGold.withOpacity(0.5), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: kcSecondaryGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "FORMATION ACTIVE",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: kcSecondaryGold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kcSecondaryGold,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kcSecondaryGold.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          '${progress.toInt()}%',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: kcPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    activeCourse.title,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeCourse.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(kcSecondaryGold),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: kcSecondaryGold.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final navigationService = locator<NavigationService>();
                              await navigationService.navigateTo(
                                Routes.courseDetailView,
                                arguments: CourseDetailViewArguments(courseId: activeCourse.id),
                              );
                              await viewModel.loadAllProgress();
                              await viewModel.loadCertificates();
                            },
                            icon: const Icon(Icons.play_arrow_rounded, color: kcPrimaryColor, size: 22),
                            label: Text(
                              'academy.resume_btn'.tr(),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kcSecondaryGold,
                              foregroundColor: kcPrimaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kcLightGrey.withOpacity(0.35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kcSecondaryGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school_outlined, size: 36, color: kcSecondaryGold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'academy.no_active_course'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kcPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'academy.no_active_course_desc'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: kcMediumGrey.withOpacity(0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => viewModel.setTopTab(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: Text(
                      'academy.formations'.tr(),
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 35),

          // Statistics Grid Section
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: kcSecondaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'academy.dashboard_title'.tr().toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kcPrimaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'academy.enrolled_courses'.tr(),
                  value: viewModel.startedCoursesCount.toString(),
                  icon: Icons.play_circle_outline,
                  color: kcSecondaryGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'academy.completed_modules'.tr(),
                  value: viewModel.completedCoursesCount.toString(),
                  icon: Icons.verified_outlined,
                  color: kcSuccessColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'academy.study_streak'.tr(),
                  value: '3', // Mock streak
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 35),

          // Badges/Skills section
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: kcSecondaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'MES BADGES DE COMPÉTENCES',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kcPrimaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBadgesSection(viewModel),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kcLightGrey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Left colored accent line
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4.5,
                color: color,
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: kcPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: kcMediumGrey,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(MonAcademieViewModel viewModel) {
    bool isCompleted(String keyword) {
      return viewModel.courses.any((c) =>
          c.title.toLowerCase().contains(keyword.toLowerCase()) &&
          viewModel.getProgressForCourse(c.id) >= 100);
    }

    double getProgressForKeyword(String keyword) {
      try {
        final course = viewModel.courses.firstWhere((c) =>
            c.title.toLowerCase().contains(keyword.toLowerCase()));
        return viewModel.getProgressForCourse(course.id);
      } catch (_) {
        return 0.0;
      }
    }

    final badges = [
      {
        'title': 'Gestion Stock',
        'desc': 'Stock & Logistique',
        'keyword': 'stock',
        'icon': Icons.local_shipping,
      },
      {
        'title': 'Expert PAPS',
        'desc': 'Système de Paiement',
        'keyword': 'paps',
        'icon': Icons.payment,
      },
      {
        'title': 'ZLECAF Expert',
        'desc': 'Commerce Intra-Africain',
        'keyword': 'zlecaf',
        'icon': Icons.public,
      },
      {
        'title': 'Digital Marketer',
        'desc': 'Marketing Digital',
        'keyword': 'marketing',
        'icon': Icons.trending_up,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final unlocked = isCompleted(badge['keyword'] as String);
        final progress = getProgressForKeyword(badge['keyword'] as String);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unlocked ? kcGoldLight : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: unlocked ? kcSecondaryGold : kcLightGrey.withOpacity(0.4),
              width: unlocked ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: unlocked
                    ? kcSecondaryGold.withOpacity(0.08)
                    : Colors.black.withOpacity(0.02),
                blurRadius: unlocked ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Header (Lock / Check Indicator)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: unlocked ? kcSecondaryGold : kcLightGrey.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      badge['icon'] as IconData,
                      color: unlocked ? Colors.white : kcMediumGrey.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  if (unlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kcSuccessColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, color: kcSuccessColor, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            "DÉBLOQUÉ",
                            style: GoogleFonts.inter(
                              color: kcSuccessColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Icon(
                      Icons.lock_outline_rounded,
                      color: kcMediumGrey.withOpacity(0.4),
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Badge Labels
              Column(
                children: [
                  Text(
                    badge['title'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: unlocked ? kcPrimaryColor : kcMediumGrey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    badge['desc'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: kcMediumGrey.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Progress Section for Gamification
              if (!unlocked)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progression",
                          style: GoogleFonts.inter(fontSize: 8, color: kcMediumGrey.withOpacity(0.6), fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${progress.toInt()}%",
                          style: GoogleFonts.inter(fontSize: 8, color: kcPrimaryColor, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: kcLightGrey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(kcSecondaryGold.withOpacity(0.6)),
                        minHeight: 4,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: kcSecondaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Expertise Acquise",
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF996515),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCertifications(BuildContext context, MonAcademieViewModel viewModel) {
    if (viewModel.courses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: kcPrimaryColor),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos Diplômes & Attestations',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kcPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),

          ...viewModel.courses.map((course) {
            final progress = viewModel.getProgressForCourse(course.id);
            final hasCert = viewModel.hasCertificate(course.id);
            final Map<String, dynamic>? certData = viewModel.getCertificateForCourse(course.id);
            final String code = (certData != null ? certData['code_verification'] ?? 'PROMOGO-100' : 'PROMOGO-100').toString();
            final String dateRaw = (certData != null ? certData['date_obtention'] ?? '' : '').toString();
            String formattedDate = '';
            try {
              if (dateRaw.isNotEmpty) {
                final dt = DateTime.parse(dateRaw);
                formattedDate = DateFormat('dd/MM/yyyy').format(dt);
              }
            } catch (_) {
              formattedDate = dateRaw;
            }

            if (progress >= 100) {
              if (hasCert) {
                // GOLD APPROVED CERTIFICATE
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kcSecondaryGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: kcSecondaryGold.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kcSecondaryGold.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.workspace_premium, color: kcSecondaryGold, size: 28),
                          ),
                          Text(
                            code,
                            style: GoogleFonts.outfit(
                              color: kcSecondaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'academy.certificate_title'.tr().toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: kcSecondaryGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'academy.certificate_subtitle'.tr(),
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      if (formattedDate.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Délivré le $formattedDate",
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => _simulateCertificateDownload(context, certData!, course),
                          icon: const Icon(Icons.file_download_outlined, color: kcPrimaryColor),
                          label: Text(
                            'academy.certificate_download'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kcSecondaryGold,
                            foregroundColor: kcPrimaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // SILVER INTERVIEW PENDING CERTIFICATE
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kcPrimaryColor.withOpacity(0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kcPrimaryColor.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.videocam_outlined, color: kcPrimaryColor, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'academy.certificate_pending_interview'.tr(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: kcPrimaryColor,
                                  ),
                                ),
                                Text(
                                  course.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: kcMediumGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'academy.certificate_pending_interview_desc'.tr(),
                        style: GoogleFonts.inter(
                          color: kcMediumGrey,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => viewModel.setTopTab(1),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kcPrimaryColor,
                            side: const BorderSide(color: kcPrimaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Planifier mon entretien',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            } else {
              // LOCKED CERTIFICATE
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kcLightGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kcLightGrey.withOpacity(0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: kcLightGrey),
                      ),
                      child: const Icon(Icons.lock_outline, color: kcMediumGrey, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kcMediumGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'academy.certificate_locked_desc'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: kcMediumGrey.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: kcLightGrey,
                                  color: kcSecondaryGold,
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${progress.toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: kcMediumGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }).toList(),

          const SizedBox(height: 20),

          // Verification Panel
          CertificateVerificationPanel(viewModel: viewModel),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showVisioBookingDialog(
    BuildContext context,
    Course course,
    MonAcademieViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedDateIndex = 0;
        int selectedTimeIndex = 0;

        final dates = [
          'Demain',
          'Dans 2 jours',
          'Dans 3 jours',
        ];

        final times = [
          '10:00 - 10:30',
          '11:00 - 11:30',
          '14:00 - 14:30',
          '16:00 - 16:30',
        ];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'academy.book_visio_title'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kcPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: kcMediumGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choisissez une date :',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: kcPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(dates.length, (index) {
                        final isSelected = selectedDateIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedDateIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? kcPrimaryColor : kcLightGrey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? kcPrimaryColor : kcLightGrey,
                              ),
                            ),
                            child: Text(
                              dates[index],
                              style: GoogleFonts.inter(
                                color: isSelected ? Colors.white : kcPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Choisissez un créneau horaire :',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: kcPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(times.length, (index) {
                        final isSelected = selectedTimeIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedTimeIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? kcSecondaryGold : kcLightGrey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? kcSecondaryGold : kcLightGrey,
                              ),
                            ),
                            child: Text(
                              times[index],
                              style: GoogleFonts.inter(
                                color: isSelected ? kcPrimaryColor : kcPrimaryColor.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Annuler',
                    style: GoogleFonts.inter(
                      color: kcMediumGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Close the booking picker dialog
                    Navigator.of(context).pop();

                    // Show success confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: kcSuccessColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Entretien Réservé !',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kcPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'academy.book_visio_success'.tr(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: kcMediumGrey,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kcPrimaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Super, merci !',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirmer',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _simulateCertificateDownload(
    BuildContext context,
    Map<String, dynamic> certificate,
    Course course,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String loadingText = "Génération du diplôme...";
        double progressVal = 0.1;

        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(milliseconds: 800), () {
              if (context.mounted && progressVal == 0.1) {
                setState(() {
                  loadingText = "Signature numérique par SURA IA...";
                  progressVal = 0.5;
                });
              }
            });

            Future.delayed(const Duration(milliseconds: 1600), () {
              if (context.mounted && progressVal == 0.5) {
                setState(() {
                  loadingText = "Enregistrement du PDF...";
                  progressVal = 0.8;
                });
              }
            });

            Future.delayed(const Duration(milliseconds: 2400), () {
              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading dialog

                // Show Success Dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: kcSuccessColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.file_download_done_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Téléchargement Terminé',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kcPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Votre certificat de réussite pour la formation « ${course.title} » a été enregistré avec succès dans vos documents.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: kcMediumGrey,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kcPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Fermer',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            });

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: kcPrimaryColor),
                    const SizedBox(height: 24),
                    Text(
                      loadingText,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kcPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressVal,
                      backgroundColor: kcLightGrey,
                      color: kcSecondaryGold,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  MonAcademieViewModel viewModelBuilder(BuildContext context) => MonAcademieViewModel();

  @override
  void onViewModelReady(MonAcademieViewModel viewModel) {
    viewModel.init();
  }
}

class CertificateVerificationPanel extends StatefulWidget {
  final MonAcademieViewModel viewModel;
  const CertificateVerificationPanel({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<CertificateVerificationPanel> createState() => _CertificateVerificationPanelState();
}

class _CertificateVerificationPanelState extends State<CertificateVerificationPanel> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kcLightGrey.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: kcSecondaryGold, size: 24),
              const SizedBox(width: 8),
              Text(
                'academy.verify_title'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kcPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'academy.verify_hint'.tr(),
              hintStyle: GoogleFonts.inter(color: kcMediumGrey.withOpacity(0.6), fontSize: 13),
              filled: true,
              fillColor: kcLightGrey.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: GoogleFonts.inter(fontSize: 14, color: kcPrimaryColor),
          ),
          const SizedBox(height: 12),
          if (viewModel.isVerifying)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(color: kcPrimaryColor),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    viewModel.verifyCertificateCode(_controller.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'academy.verify_btn'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          
          if (viewModel.verificationResult != null) ...[
            const SizedBox(height: 16),
            _buildResultWidget(viewModel.verificationResult!, viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildResultWidget(Map<String, dynamic> result, MonAcademieViewModel viewModel) {
    final isValid = result['valid'] as bool? ?? false;

    if (isValid) {
      final student = (result['student_name'] ?? '').toString();
      final course = (result['course_title'] ?? '').toString();
      final dateRaw = (result['date_obtention'] ?? '').toString();
      final code = (result['code_verification'] ?? '').toString();

      String formattedDate = '';
      try {
        if (dateRaw.isNotEmpty) {
          final dt = DateTime.parse(dateRaw);
          formattedDate = DateFormat('dd/MM/yyyy').format(dt);
        }
      } catch (_) {
        formattedDate = dateRaw;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kcSuccessColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kcSuccessColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: kcSuccessColor),
                const SizedBox(width: 8),
                Text(
                  'Certificat Authentique',
                  style: GoogleFonts.outfit(
                    color: kcSuccessColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: kcMediumGrey),
                  onPressed: () {
                    _controller.clear();
                    viewModel.resetVerification();
                  },
                ),
              ],
            ),
            const Divider(color: kcSuccessColor),
            const SizedBox(height: 8),
            _buildInfoRow('Étudiant :', student),
            _buildInfoRow('Formation :', course),
            if (formattedDate.isNotEmpty) _buildInfoRow('Délivré le :', formattedDate),
            _buildInfoRow('Code :', code),
          ],
        ),
      );
    } else {
      final error = (result['error'] ?? 'Certificat invalide ou introuvable.').toString();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: kcMediumGrey),
              onPressed: () {
                viewModel.resetVerification();
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: kcMediumGrey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: kcPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
