import 'dart:io';
import 'package:flutter/material.dart';
import 'theme_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'verification_notification_screen.dart';
import '../widgets/app_brand_logo.dart';

class UploadImagesScreen extends StatefulWidget {
  const UploadImagesScreen({super.key});

  @override
  State<UploadImagesScreen> createState() => _UploadImagesScreenState();
}

class _UploadImagesScreenState extends State<UploadImagesScreen> {
  final ImagePicker _picker = ImagePicker();

  final List<File?> _images = [null, null, null];
  final List<String?> _fileNames = [null, null, null];

  bool get _allUploaded => _images.every((e) => e != null);

  Future<void> _onUploadTap(int index) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: context.appAccent),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: context.appAccent),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _images[index] = File(picked.path);
      _fileNames[index] = picked.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: EdgeInsets.only(left: 12),
          child: const AppBrandLogo(size: 28),
        ),
        title: Text(
          'Deslugify',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.appText,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        titleSpacing: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Required Images',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: context.appText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please upload 3 clear images to help us properly assess your issue. All images are required before submission.',
              style: TextStyle(
                fontSize: 14,
                color: context.appMutedText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            _imageSlot(context, 0, 'IMAGE 1: OVERVIEW'),
            const SizedBox(height: 16),
            _imageSlot(context, 1, 'IMAGE 2: CLOSE-UP VIEW'),
            const SizedBox(height: 16),
            _imageSlot(context, 2, 'IMAGE 3: ADDITIONAL ANGLE'),
            const SizedBox(height: 20),

            if (!_allUploaded)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.appErrorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.appErrorBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: context.appError,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please upload all required images before proceeding. Our AI verification system needs these to validate your service request.',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appError,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _allUploaded
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const VerificationNotificationScreen(),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.auto_awesome, size: 20),
                label: const Text(
                  'Submit for AI Verification',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appAccent,
                  foregroundColor: context.appOnAccent,
                  disabledBackgroundColor: context.appSurfaceContainer,
                  disabledForegroundColor: context.appMutedText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Step 2 of 4 · Photo Documentation',
                style: TextStyle(fontSize: 12, color: context.appMutedText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSlot(BuildContext context, int index, String title) {
    final completed = _images[index] != null;
    final badge = completed ? 'COMPLETED' : 'REQUIRED';
    final badgeColor = completed ? context.appAccent : context.appError;

    return GestureDetector(
      onTap: () => _onUploadTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: completed ? const Color(0xFF94F4AD) : context.appBorder,
            width: completed ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.appMutedText,
                    letterSpacing: 0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // REAL photo from gallery/camera
            if (completed)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _images[index]!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.appSurfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.appBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 32,
                      color: context.appMutedText,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Capture or Upload',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.appText,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Max size 10MB · JPG, PNG',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appMutedText,
                      ),
                    ),
                  ],
                ),
              ),

            if (_fileNames[index] != null) ...[
              const SizedBox(height: 8),
              Text(
                _fileNames[index]!,
                style: TextStyle(fontSize: 12, color: context.appMutedText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
