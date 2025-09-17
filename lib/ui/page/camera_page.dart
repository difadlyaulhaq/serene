// lib/ui/page/camera_page.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:serene/services/camera_service.dart';
import 'package:serene/shared/theme.dart';

enum CameraState { loading, ready, permissionDenied, error }

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> 
    with WidgetsBindingObserver {
  
  CameraState _cameraState = CameraState.loading;
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initialize() async {
    final hasPermission = await CameraService.requestCameraPermission();
    if (hasPermission) {
      final isInitialized = await CameraService.initialize();
      if (isInitialized) {
        await _initializeCamera();
      } else {
        if (mounted) setState(() => _cameraState = CameraState.error);
      }
    } else {
      if (mounted) setState(() => _cameraState = CameraState.permissionDenied);
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = CameraService.cameras;
    if (cameras.isEmpty) {
      if (mounted) setState(() => _cameraState = CameraState.error);
      return;
    }

    await _controller?.dispose();
    final cameraDescription = cameras[_selectedCameraIndex];
    
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _cameraState = CameraState.ready);
    } catch (e) {
      if (mounted) setState(() => _cameraState = CameraState.error);
    }
  }

  void _toggleFlash() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() => _isFlashOn = !_isFlashOn);
    _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  Future<void> _toggleCamera() async {
    final cameras = CameraService.cameras;
    if (cameras.length > 1) {
      setState(() {
        _cameraState = CameraState.loading;
        _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
      });
      await _initializeCamera();
    }
  }

  Future<void> _takePicture() async {
    if (_isActionInProgress || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() => _isActionInProgress = true);
    
    try {
      final image = await _controller!.takePicture();
      if (!mounted) return;

      // Kembali ke chat page dengan path gambar
      Navigator.pop(context, File(image.path));
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isActionInProgress) return;
    setState(() => _isActionInProgress = true);

    try {
      final image = await CameraService.pickImageFromGallery();
      if (image != null && mounted) {
        Navigator.pop(context, image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        title: const Text('Ambil Foto'),
        backgroundColor: Colors.transparent,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_cameraState == CameraState.ready) ...[
            IconButton(
              icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
              onPressed: _toggleFlash,
              tooltip: 'Flash',
            ),
            if (CameraService.cameras.length > 1)
              IconButton(
                icon: const Icon(Icons.flip_camera_ios_outlined),
                onPressed: _toggleCamera,
                tooltip: 'Ganti Kamera',
              ),
          ]
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_cameraState) {
      case CameraState.ready:
        return _buildCameraPreview();
      case CameraState.permissionDenied:
        return _buildPermissionDeniedUI();
      case CameraState.error:
        return _buildInfoUI(
          key: const ValueKey('error'),
          icon: Icons.error_outline,
          message: "Kamera tidak dapat diakses.\nCoba mulai ulang aplikasi.",
        );
      case CameraState.loading:
        return _buildLoadingUI();
    }
  }

  Widget _buildCameraPreview() {
    return Stack(
      key: const ValueKey('ready'),
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildControlUI(),
        ),
      ],
    );
  }

  Widget _buildControlUI() {
    final Color disabledColor = white;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      decoration: BoxDecoration(
        color: black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _isActionInProgress ? null : _pickImageFromGallery,
            icon: Icon(
              Icons.photo_library_outlined, 
              color: _isActionInProgress ? disabledColor : white,
            ),
            iconSize: 32,
            tooltip: 'Pilih dari Galeri',
          ),
          _buildCaptureButton(),
          const SizedBox(width: 48, height: 48), // Spacer untuk balance
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isActionInProgress ? null : _takePicture,
      child: Opacity(
        opacity: _isActionInProgress ? 0.6 : 1.0,
        child: Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: white, width: 4),
          ),
          child: Center(
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedUI() {
    return _buildInfoUI(
      key: const ValueKey('permission_denied'),
      icon: Icons.camera_alt_outlined,
      message: "Izin kamera dibutuhkan untuk fitur ini.",
      action: ElevatedButton.icon(
        icon: const Icon(Icons.settings),
        label: const Text('Buka Pengaturan'),
        onPressed: () async {
          await openAppSettings();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: white,
        ),
      ),
    );
  }

  Widget _buildInfoUI({
    required String message, 
    required IconData icon, 
    Key? key, 
    Widget? action
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: white, size: 80),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(color: white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action,
          ]
        ],
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Center(
      key: const ValueKey('loading'),
      child: CircularProgressIndicator(color: blue),
    );
  }
}