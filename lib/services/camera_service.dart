// lib/services/camera_service.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static List<CameraDescription> _cameras = [];
  static bool _isInitialized = false;

  /// Initialize cameras list
  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _cameras = await availableCameras();
      _isInitialized = true;
      return _cameras.isNotEmpty;
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      return false;
    }
  }

  /// Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Get available cameras
  static List<CameraDescription> get cameras => _cameras;

  /// Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}