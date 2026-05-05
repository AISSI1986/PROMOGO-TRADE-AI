import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'course_detail_viewmodel.dart';

class CourseDetailView extends StackedView<CourseDetailViewModel> {
  final String courseId;

  const CourseDetailView({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CourseDetailViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) {
      return const Scaffold(
        backgroundColor: kcBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: kcPrimaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, viewModel),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModuleSelector(viewModel),
                  const SizedBox(height: 25),
                  _buildModuleContent(viewModel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, CourseDetailViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: kcPrimaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          viewModel.course?.title_fr ?? 'Cours',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kcPrimaryColor, kcPrimaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(Icons.menu_book_rounded, color: kcSecondaryGold.withOpacity(0.2), size: 100),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleSelector(CourseDetailViewModel viewModel) {
    if (viewModel.course?.modules.isEmpty ?? true) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modules du cours',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.course!.modules.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final module = viewModel.course!.modules[index];
              final isSelected = viewModel.currentModuleIndex == index;

              return InkWell(
                onTap: () => viewModel.selectModule(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? kcPrimaryColor : kcLightGrey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Module ${module.order}',
                    style: GoogleFonts.inter(
                      color: isSelected ? kcSecondaryGold : kcMediumGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  Widget _buildModuleContent(CourseDetailViewModel viewModel) {
    if (viewModel.course?.modules.isEmpty ?? true) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Icon(Icons.info_outline, size: 50, color: kcLightGrey),
            const SizedBox(height: 10),
            Text(
              'Aucun contenu pour le moment.',
              style: GoogleFonts.inter(color: kcMediumGrey),
            ),
          ],
        ),
      );
    }

    final module = viewModel.course!.modules[viewModel.currentModuleIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          module.title_fr,
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: kcPrimaryColor),
        ),
        const SizedBox(height: 20),
        MarkdownBody(
          data: module.content_fr ?? 'Le contenu est en cours de préparation...',
          styleSheet: MarkdownStyleSheet(
            p: GoogleFonts.inter(
              fontSize: 16, 
              height: 1.8, 
              color: const Color(0xFF2D3436),
              fontWeight: FontWeight.w400,
            ),
            h1: GoogleFonts.outfit(
              fontSize: 28, 
              fontWeight: FontWeight.w900, 
              height: 2.2, 
              color: kcPrimaryColor,
            ),
            h2: GoogleFonts.outfit(
              fontSize: 22, 
              fontWeight: FontWeight.w800, 
              height: 2, 
              color: kcPrimaryColor.withOpacity(0.85),
            ),
            h3: GoogleFonts.outfit(
              fontSize: 19, 
              fontWeight: FontWeight.w700, 
              height: 1.8, 
              color: kcSecondaryGold,
            ),
            listBullet: GoogleFonts.inter(
              fontSize: 16, 
              color: kcSecondaryGold, 
              fontWeight: FontWeight.w900,
            ),
            strong: const TextStyle(
              fontWeight: FontWeight.w900, 
              color: Colors.black,
            ),
            blockSpacing: 24,
            listIndent: 24,
          ),
        ),
        const SizedBox(height: 50),
        if (viewModel.currentModuleIndex < viewModel.course!.modules.length - 1)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => viewModel.selectModule(viewModel.currentModuleIndex + 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                foregroundColor: kcSecondaryGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Module Suivant', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous avez terminé ce cours ! Vous pouvez maintenant demander votre entretien.',
                    style: GoogleFonts.inter(color: Colors.green[800], fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  CourseDetailViewModel viewModelBuilder(BuildContext context) =>
      CourseDetailViewModel(courseId: courseId);

  @override
  void onViewModelReady(CourseDetailViewModel viewModel) {
    viewModel.init();
  }
}
