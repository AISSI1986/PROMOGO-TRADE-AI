import 'package:flutter_test/flutter_test.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/ui/views/home/home_viewmodel.dart';

import '../helpers/test_helpers.dart';

void main() {
  HomeViewModel getModel() => HomeViewModel();

  group('HomeViewModelTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    group('initialization -', () {
      test('When constructed should have default values', () {
        final model = getModel();
        expect(model.currentIndex, 0);
        expect(model.currentTopTab, 1);
        expect(model.showAiVoiceBar, false);
      });
    });

    group('setIndex -', () {
      test('When called should update currentIndex', () {
        final model = getModel();
        model.setIndex(1);
        expect(model.currentIndex, 1);
      });
    });

    group('setTopTab -', () {
      test('When called should update currentTopTab', () {
        final model = getModel();
        model.setTopTab(2);
        expect(model.currentTopTab, 2);
      });
    });
  });
}
