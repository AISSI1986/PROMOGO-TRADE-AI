import 'package:flutter/material.dart';
import 'package:promogoai/ui/common/app_colors.dart';
import '../../../../models/course_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final double progress;
  final VoidCallback onTap;

  const CourseCard({
    Key? key, 
    required this.course,
    required this.progress,
    required this.onTap,
  }) : super(key: key);

  List<Color> _getFallbackGradient() {
    final idInt = int.tryParse(course.id) ?? 0;
    final gradients = [
      [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
      [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
      [const Color(0xFFB1F4CF), const Color(0xFF9890E3)],
      [const Color(0xFFF6D365), const Color(0xFFFDA085)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
    ];
    return gradients[idInt % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image with Cache & Shimmer
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: course.imageCouverture != null
                      ? CachedNetworkImage(
                          imageUrl: course.imageCouverture!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getFallbackGradient(),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.broken_image, color: Colors.white),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getFallbackGradient(),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                ),
                // Level Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
                      ],
                    ),
                    child: Text(
                      course.levelLabel.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: kcPrimaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Text Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags Row
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          children: course.tags.take(3).map((t) => _buildMiniBadge(t.title)).toList(),
                        ),
                      ),
                      _buildMetaItem(Icons.language_rounded, course.language.toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    course.title,
                    style: GoogleFonts.outfit(
                      color: kcPrimaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    course.subtitle,
                    style: GoogleFonts.inter(
                      color: kcPrimaryColor.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    course.description,
                    style: GoogleFonts.inter(
                      color: kcMediumGrey,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  
                  // Metadata Icons Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: kcLightGrey.withOpacity(0.3)),
                        bottom: BorderSide(color: kcLightGrey.withOpacity(0.3)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetaItem(Icons.access_time_rounded, course.duration),
                        _buildMetaItem(
                          Icons.menu_book_outlined, 
                          course.modulesCount > 1 
                            ? '${course.modulesCount} modules' 
                            : '1 module'
                        ),
                      ],
                    ),
                  ),
                  if (progress > 0) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: kcLightGrey.withOpacity(0.3),
                            color: progress >= 100 ? kcSuccessColor : kcSecondaryGold,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${progress.toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: progress >= 100 ? kcSuccessColor : kcPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Premium Button
                  InkWell(
                    onTap: onTap,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: kcPrimaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: kcPrimaryColor.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'academy.see_course'.tr(),
                            style: GoogleFonts.inter(
                              color: kcSecondaryGold,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_ios_rounded, color: kcSecondaryGold, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: kcSecondaryGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          color: const Color(0xFF996515),
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: kcMediumGrey.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: kcMediumGrey,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
