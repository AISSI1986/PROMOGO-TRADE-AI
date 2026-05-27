import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import '../../../models/course_model.dart';
import 'lesson_viewmodel.dart';

class LessonView extends StackedView<LessonViewModel> {
  final Lesson lesson;
  final List<Lesson> allLessons;
  final String moduleTitle;
  final String courseId;

  const LessonView({
    Key? key, 
    required this.lesson, 
    required this.allLessons,
    required this.moduleTitle,
    required this.courseId,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LessonViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kcPrimaryColor),
          onPressed: viewModel.goBack,
        ),
        title: Text(
          viewModel.moduleTitle,
          style: GoogleFonts.outfit(
            color: kcPrimaryColor, 
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (viewModel.currentLessonIndex + 1) / viewModel.allLessons.length,
            backgroundColor: kcLightGrey.withOpacity(0.2),
            color: kcSecondaryGold,
            minHeight: 4,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.currentLesson.title,
                    style: GoogleFonts.outfit(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold, 
                      color: kcPrimaryColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Contenu de la leçon (Logique conditionnelle TEXT vs VIDEO)
                  MarkdownBody(
                    data: viewModel.currentLesson.type == 'TEXT'
                        ? "${viewModel.currentLesson.description ?? ''}\n\n${viewModel.currentLesson.contenuUrl ?? ''}".trim().isEmpty 
                            ? 'Pas de contenu pour cette leçon.' 
                            : "${viewModel.currentLesson.description ?? ''}\n\n${viewModel.currentLesson.contenuUrl ?? ''}".trim()
                        : viewModel.currentLesson.description ?? 'Pas de description pour ce contenu.',
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.inter(fontSize: 16, height: 1.7, color: const Color(0xFF2D3436)),
                      h1: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: kcPrimaryColor),
                      h2: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: kcPrimaryColor),
                      strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      blockSpacing: 20,
                      tableBorder: TableBorder.all(color: kcLightGrey.withOpacity(0.4), width: 1),
                      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Si c'est une vidéo ou un PDF, afficher un bouton d'action élégant
                  if (viewModel.currentLesson.type != 'TEXT' && viewModel.currentLesson.contenuUrl != null && viewModel.currentLesson.contenuUrl!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kcPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kcPrimaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kcPrimaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              viewModel.currentLesson.type == 'VIDEO' ? Icons.play_arrow_rounded : Icons.picture_as_pdf_rounded,
                              color: kcSecondaryGold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  viewModel.currentLesson.type == 'VIDEO' ? 'Support Vidéo' : 'Document PDF',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: kcPrimaryColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cliquez ci-dessous pour ouvrir le support',
                                  style: GoogleFonts.inter(fontSize: 13, color: kcMediumGrey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Navigation continue en bas
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: viewModel.nextLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  foregroundColor: kcSecondaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: kcPrimaryColor.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.hasNextLesson ? 'Leçon suivante' : 'Terminer le module',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      viewModel.hasNextLesson ? Icons.arrow_forward_rounded : Icons.check_circle_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LessonViewModel viewModelBuilder(BuildContext context) => 
      LessonViewModel(
        initialLesson: lesson, 
        allLessons: allLessons, 
        moduleTitle: moduleTitle,
        courseId: courseId
      );
}
