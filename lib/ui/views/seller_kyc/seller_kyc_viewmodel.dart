import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';
import 'package:promogoai/ui/common/app_colors.dart';

class SellerKycViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  
  int _currentStep = 0;
  int get currentStep => _currentStep;

  String _firstName = '';
  String _lastName = '';
  String _city = '';
  String _email = '';
  String _selectedDocType = '';
  
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get city => _city;
  String get email => _email;
  String get selectedDocType => _selectedDocType;

  File? _idRecto;
  File? _idVerso;
  File? get idRecto => _idRecto;
  File? get idVerso => _idVerso;

  bool _isCameraInitialized = false;
  bool get isCameraInitialized => _isCameraInitialized;

  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  void setCity(String value) {
    _city = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setDocumentType(String type) {
    _selectedDocType = type;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 6) {
      _currentStep++;
      
      if (_currentStep == 4 || _currentStep == 5) {
        initCamera();
      } else {
        disposeCamera();
      }
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      
      if (_currentStep == 4 || _currentStep == 5) {
        initCamera();
      } else {
        disposeCamera();
      }
      notifyListeners();
    } else {
      _navigationService.back();
    }
  }

  Future<void> initCamera() async {
    setBusy(true);
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController = CameraController(
            cameras.first,
            ResolutionPreset.high,
            enableAudio: false,
          );
          await _cameraController?.initialize();
          _isCameraInitialized = true;
        }
      } catch (e) {
        debugPrint("Camera Error: $e");
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    setBusy(false);
  }

  void disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    _isCameraInitialized = false;
  }

  Future<void> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      setBusy(true);
      final XFile photo = await _cameraController!.takePicture();
      
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: photo.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'seller_kyc.cropper_title'.tr(),
            toolbarColor: kcPrimaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'seller_kyc.cropper_title'.tr(),
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        if (_currentStep == 4) {
          _idRecto = File(croppedFile.path);
        } else if (_currentStep == 5) {
          _idVerso = File(croppedFile.path);
        }
        nextStep();
      }
    } catch (e) {
      debugPrint("Error capturing or cropping image: $e");
    } finally {
      setBusy(false);
    }
  }

  void resetCapture() {
    if (_currentStep == 4) {
      _idRecto = null;
    } else if (_currentStep == 5) {
      _idVerso = null;
    }
    notifyListeners();
  }

  void finish() {
    _navigationService.back();
  }

  @override
  void dispose() {
    disposeCamera();
    super.dispose();
  }
}
