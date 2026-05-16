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
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: kcPrimaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, viewModel),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModuleSelector(viewModel),
                  const SizedBox(height: 30),
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
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: kcPrimaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          viewModel.course?.title ?? 'Formation',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image de couverture avec overlay sombre
            if (viewModel.course?.imageCouverture != null)
              Image.network(
                viewModel.course!.imageCouverture!,
                fit: BoxFit.cover,
              )
            else
              Container(color: kcPrimaryColor),
            
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    kcPrimaryColor.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            
            // Icon flottante pour le style
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kcSecondaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: kcSecondaryGold.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.school_rounded, color: kcSecondaryGold, size: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleSelector(CourseDetailViewModel viewModel) {
    if (viewModel.course?.modules.isEmpty ?? true) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Parcours de formation',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: kcPrimaryColor),
            ),
            Text(
              '${viewModel.course!.modules.length} Modules',
              style: GoogleFonts.inter(fontSize: 14, color: kcMediumGrey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.course!.modules.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final module = viewModel.course!.modules[index];
              final isSelected = viewModel.currentModuleIndex == index;
              final isLocked = viewModel.isModuleLocked(index);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: InkWell(
                  onTap: () {
                    if (isLocked) {
                      _showLockedModuleModal(context, index);
                    } else {
                      viewModel.selectModule(index);
                    }
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isSelected ? kcPrimaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: kcPrimaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                      border: Border.all(
                        color: isSelected ? kcPrimaryColor : (isLocked ? Colors.grey[200]! : kcLightGrey.withOpacity(0.5)),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLocked) ...[
                          Icon(Icons.lock_rounded, size: 14, color: kcMediumGrey.withOpacity(0.5)),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          'Module ${module.ordreAffichage}',
                          style: GoogleFonts.inter(
                            color: isSelected ? kcSecondaryGold : (isLocked ? kcMediumGrey.withOpacity(0.5) : kcPrimaryColor.withOpacity(0.7)),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
      return const Center(child: Text('Aucun contenu disponible.'));
    }

    final module = viewModel.course!.modules[viewModel.currentModuleIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du module avec icône
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kcSecondaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: kcSecondaryGold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                module.title,
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: kcPrimaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        
        // Description avec style Markdown amélioré
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: MarkdownBody(
            data: module.description,
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.inter(fontSize: 15, height: 1.6, color: const Color(0xFF4A4A4A)),
              blockSpacing: 15,
            ),
          ),
        ),
        
        const SizedBox(height: 35),
        
        Text(
          'Contenu du module',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: kcPrimaryColor),
        ),
        const SizedBox(height: 15),
        
        // Liste des leçons avec design "Elite"
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: module.lecons.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final lecon = module.lecons[index];
            final bool isLocked = viewModel.isLessonLocked(lecon); 

            return InkWell(
              onTap: isLocked ? null : () => viewModel.navigateToLesson(lecon),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[100] : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isLocked ? Colors.transparent : kcLightGrey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Numéro ou Icône de statut
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey[300] : kcPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isLocked 
                          ? const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey)
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold, 
                                color: kcPrimaryColor,
                                fontSize: 16,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lecon.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, 
                              fontSize: 15,
                              color: isLocked ? Colors.grey : kcPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                lecon.type == 'VIDEO' ? Icons.play_circle_outline : Icons.article_outlined,
                                size: 14,
                                color: kcMediumGrey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lecon.duree,
                                style: GoogleFonts.inter(color: kcMediumGrey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isLocked)
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: kcLightGrey),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 40),
        
        if (viewModel.currentModuleIndex < viewModel.course!.modules.length - 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: Builder(
                builder: (context) {
                  final nextIndex = viewModel.currentModuleIndex + 1;
                  final isLocked = viewModel.isModuleLocked(nextIndex);
                  
                  return ElevatedButton(
                    onPressed: () {
                      if (isLocked) {
                        _showLockedModuleModal(context, nextIndex);
                      } else {
                        viewModel.selectModule(nextIndex);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLocked ? Colors.grey[300] : kcPrimaryColor,
                      foregroundColor: isLocked ? Colors.grey : kcSecondaryGold,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Module Suivant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 10),
                        Icon(
                          isLocked ? Icons.lock_outline_rounded : Icons.arrow_forward_rounded, 
                          size: 20
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
      ],
    );
  }

  void _showLockedModuleModal(BuildContext context, int moduleIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_clock_rounded, color: kcSecondaryGold),
            const SizedBox(width: 12),
            Text(
              'Module Verrouillé',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: kcPrimaryColor),
            ),
          ],
        ),
        content: Text(
          'Vous devez terminer toutes les leçons du module précédent avant de pouvoir accéder au Module ${moduleIndex + 1}.',
          style: GoogleFonts.inter(color: kcMediumGrey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'COMPRIS',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: kcSecondaryGold),
            ),
          ),
        ],
      ),
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
