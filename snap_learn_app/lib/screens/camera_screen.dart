import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/analyzed_result_card.dart';

class CameraScreen extends StatefulWidget {
  final void Function()? onQuizStarted;
  const CameraScreen({super.key, this.onQuizStarted});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _cameraImage;
  Map<String, dynamic>? _visionResult;
  List<DetectedObject> _detectedObjects = [];
  bool _analyzing = false;
  String? _visionError;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked != null) {
      setState(() {
        _cameraImage = File(picked.path);
        _visionResult = null;
        _visionError = null;
        _detectedObjects = [];
      });
      _analyzeImage(_cameraImage!);
    }
  }

  Future<void> _analyzeImage(File image) async {
    setState(() {
      _analyzing = true;
      _visionResult = null;
      _visionError = null;
      _detectedObjects = [];
    });
    try {
      final result = await ApiService.analyzeImage(image);
      final objectsRaw = result['objects'] as List?;
      final objects = objectsRaw != null
          ? objectsRaw
                .map((e) => DetectedObject.fromJson(e as Map<String, dynamic>))
                .toList()
          : <DetectedObject>[];
      setState(() {
        _visionResult = result;
        _detectedObjects = objects;
      });
    } catch (e) {
      setState(() {
        _visionError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _analyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = _visionResult?['text'] as String?;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_cameraImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  _cameraImage!,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(
                Icons.camera_alt_rounded,
                size: 96,
                color: theme.colorScheme.primary,
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    textStyle: theme.textTheme.titleMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    textStyle: theme.textTheme.titleMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
            if (_cameraImage != null && _analyzing)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_visionError != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: MaterialBanner(
                  backgroundColor: theme.colorScheme.errorContainer,
                  content: Text(
                    _visionError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: theme.colorScheme.onErrorContainer,
                      onPressed: () => setState(() => _cameraImage = null),
                      tooltip: 'Dismiss',
                    ),
                  ],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
              ),
            if (_visionResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: AnalyzedResultCard(
                  objects: _detectedObjects,
                  text: text is String ? text : '',
                  prompt: _visionResult?['prompt']?.toString(),
                  onShowTopicPicker: null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
