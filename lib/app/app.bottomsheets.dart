// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedBottomsheetGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/bottom_sheets/ai_voice/ai_voice_sheet.dart';
import '../ui/bottom_sheets/notice/notice_sheet.dart';
import '../ui/bottom_sheets/otp/otp_sheet.dart';
import '../ui/bottom_sheets/settings/settings_sheet.dart';
import '../ui/bottom_sheets/auth_required/auth_required_sheet.dart';

enum BottomSheetType {
  notice,
  settings,
  otp,
  aiVoice,
  authRequired,
}

void setupBottomSheetUi() {
  final bottomsheetService = locator<BottomSheetService>();

  final Map<BottomSheetType, SheetBuilder> builders = {
    BottomSheetType.notice: (context, request, completer) =>
        NoticeSheet(request: request, completer: completer),
    BottomSheetType.settings: (context, request, completer) =>
        SettingsSheet(request: request, completer: completer),
    BottomSheetType.otp: (context, request, completer) =>
        OtpSheet(request: request, completer: completer),
    BottomSheetType.aiVoice: (context, request, completer) =>
        AiVoiceSheet(request: request, completer: completer),
    BottomSheetType.authRequired: (context, request, completer) =>
        AuthRequiredSheet(request: request, completer: completer),
  };

  bottomsheetService.setCustomSheetBuilders(builders);
}
