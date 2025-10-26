import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PhotoAttachmentWidget extends StatefulWidget {
  final Function(List<XFile>) onPhotosSelected;
  final List<XFile>? initialPhotos;

  const PhotoAttachmentWidget({
    Key? key,
    required this.onPhotosSelected,
    this.initialPhotos,
  }) : super(key: key);

  @override
  State<PhotoAttachmentWidget> createState() => _PhotoAttachmentWidgetState();
}

class _PhotoAttachmentWidgetState extends State<PhotoAttachmentWidget> {
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  List<XFile> _selectedPhotos = [];
  bool _showCamera = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedPhotos = widget.initialPhotos ?? [];
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first,
              )
            : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first,
              );

        _cameraController = CameraController(
          camera,
          kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        );

        await _cameraController!.initialize();
        await _applySettings();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus mode error: $e');
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        debugPrint('Flash mode error: $e');
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _selectedPhotos.add(photo);
        _showCamera = false;
      });
      widget.onPhotosSelected(_selectedPhotos);
    } catch (e) {
      _showErrorMessage('Failed to capture photo');
    }
  }
  // i want to use pickfromgallery method here
  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(images);
        });
        widget.onPhotosSelected(_selectedPhotos);
      }
    } catch (e) {
      _showErrorMessage('Failed to pick images from gallery');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
    widget.onPhotosSelected(_selectedPhotos);
  }

  void _showCameraView() async {
    if (!await _requestCameraPermission()) {
      _showPermissionDeniedMessage();
      return;
    }

    setState(() {
      _showCamera = true;
    });
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera permission is required to take photos'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Add Photo',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: 'camera_alt',
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _showCameraView();
                  },
                ),
                _buildPhotoOption(
                  icon: 'photo_library',
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3.w),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showCamera && _isCameraInitialized && _cameraController != null) {
      return Container(
        width: double.infinity,
        height: 60.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.w),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3.w),
          child: Stack(
            children: [
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              ),
              Positioned(
                top: 2.h,
                left: 4.w,
                child: GestureDetector(
                  onTap: () => setState(() => _showCamera = false),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4.h,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _capturePhoto,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(1.w),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Photo Button
          GestureDetector(
            onTap: _showPhotoOptions,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'add_a_photo',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Add Photo',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected Photos
          if (_selectedPhotos.isNotEmpty) ...[
            SizedBox(height: 2.h),
            SizedBox(
              height: 25.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedPhotos.length,
                itemBuilder: (context, index) {
                  final photo = _selectedPhotos[index];
                  return Container(
                    width: 40.w,
                    margin: EdgeInsets.only(right: 3.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.w),
                      color: AppTheme.lightTheme.colorScheme.surface,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3.w),
                            child: kIsWeb
                                ? FutureBuilder<Uint8List>(
                                    future: photo.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return Container(
                                        color: AppTheme
                                            .lightTheme.colorScheme.surface,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : CustomImageWidget(
                                    imageUrl: photo.path,
                                    width: 40.w,
                                    height: 25.h,
                                    fit: BoxFit.cover,
                                    semanticLabel:
                                        "Selected photo for journal entry",
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 1.h,
                          right: 2.w,
                          child: GestureDetector(
                            onTap: () => _removePhoto(index),
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'close',
                                color: Colors.white,
                                size: 4.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
