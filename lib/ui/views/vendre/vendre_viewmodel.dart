import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';

class VendreViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _imagePicker = ImagePicker();

  // Form Fields
  String _title = '';
  String get title => _title;
  
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedSubCategory;
  String? get selectedSubCategory => _selectedSubCategory;

  List<File> _images = [];
  List<File> get images => _images;

  String _videoLink = '';
  String get videoLink => _videoLink;

  String? _selectedRegion;
  String? get selectedRegion => _selectedRegion;

  // Dynamic Fields
  String _brand = '';
  String _type = '';
  String _condition = '';
  String _description = '';
  String _price = '';
  String get price => _price;
  
  // Computer specific
  String _slots = '';
  String _power = '';
  String _dockingInterface = '';


  // Bulk Price
  bool _showBulkPriceForm = false;
  bool get showBulkPriceForm => _showBulkPriceForm;
  
  String? _selectedBulkSize;
  String? get selectedBulkSize => _selectedBulkSize;
  
  List<Map<String, String>> _bulkPrices = [];
  List<Map<String, String>> get bulkPrices => _bulkPrices;

  String? _negotiation;
  String? get negotiation => _negotiation;

  String? _selectedSubscription = 'Free';
  String? get selectedSubscription => _selectedSubscription;

  // Validation
  bool get isTitleValid => _title.length >= 10;
  String get titleError => _title.isEmpty ? '' : 'post_ad.error_title';

  // Mock Data
  final List<String> categories = ['Electronics', 'Informatique', 'Fashion', 'Home'];
  final Map<String, List<String>> subCategories = {
    'Electronics': ['Phone', 'TV', 'Camera'],
    'Informatique': ['Computer', 'Accessories', 'Software'],
  };
  final List<String> regions = ['Ghana', 'Benin', 'Togo', 'Ivory Coast'];
  final List<String> bulkSizes = ['2', '5', '10', '20', '50'];
  final List<String> negotiationOptions = ['Yes', 'No', 'Not sure'];

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _selectedCategory = value;
    _selectedSubCategory = null;
    notifyListeners();
  }

  void setSubCategory(String? value) {
    _selectedSubCategory = value;
    notifyListeners();
  }

  void setRegion(String? value) {
    _selectedRegion = value;
    notifyListeners();
  }

  void setVideoLink(String value) {
    _videoLink = value;
    notifyListeners();
  }

  void setNegotiation(String? value) {
    _negotiation = value;
    notifyListeners();
  }

  void setSubscription(String? value) {
    _selectedSubscription = value;
    notifyListeners();
  }

  void setPrice(String value) {
    _price = value;
    notifyListeners();
  }


  // Image Picking
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        _images.add(File(image.path));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final File item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    notifyListeners();
  }

  // Bulk Price Actions
  void toggleBulkPriceForm() {
    _showBulkPriceForm = !_showBulkPriceForm;
    notifyListeners();
  }

  void setBulkSize(String? value) {
    _selectedBulkSize = value;
    notifyListeners();
  }

  void addBulkPrice(String size, String price) {
    _bulkPrices.add({'size': size, 'price': price});
    _selectedBulkSize = null;
    notifyListeners();
  }

  void removeBulkPrice(int index) {
    _bulkPrices.removeAt(index);
    notifyListeners();
  }

  // Submit
  void submitAd() {
    // Logic to submit the ad
  }

  void navigateToKyc() {
    // Legacy mapping if needed
  }
}
