import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';
import '../widgets/analyzed_result_card.dart';

class CameraScreen extends StatefulWidget {
  final void Function()? onQuizStarted;
  const CameraScreen({super.key, this.onQuizStarted});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _selectedImage;
  Map<String, dynamic>? _analysisResult;
  List<DetectedObject> _detectedObjects = [];
  bool _isAnalyzing = false;
  String? _errorMessage;

  // Future<void> _pickImage(ImageSource source) async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: source, imageQuality: 90);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImage = File(pickedFile.path);
  //       _analysisResult = null;
  //       _errorMessage = null;
  //       _detectedObjects = [];
  //     });
  //     _analyzeImage(_selectedImage!);
  //   }
  // }

  Future<void> _analyzeImage(File image) async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.analyzeImage(image);
      final objectsRaw = result['objects'] as List?;
      final objects =
          objectsRaw
              ?.map((e) => DetectedObject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      // The 'image' field from the backend is a base64 string.
      final imageBase64 = result['image'] as String?;

      setState(() {
        _analysisResult = result;
        _detectedObjects = objects;
      });

      if (imageBase64 != null && imageBase64.isNotEmpty) {
        final processedImageBytes = base64Decode(imageBase64);
        // Create a new temporary file
        final tempDir = await getTemporaryDirectory();
        final newFile = File(
          '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await newFile.writeAsBytes(processedImageBytes);

        // Second setState call - update the image
        setState(() {
          _selectedImage = newFile; // Replace with the new file
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70, // Reduced from 90 to 70 for better compression
      maxWidth: 1920, // Limits the width to Full HD size
      maxHeight: 1080, // Limits the height to Full HD size
    );

    if (pickedFile != null) {
      // Optional: Further compress the image if needed
      final compressedFile = await _compressImage(File(pickedFile.path));

      setState(() {
        _selectedImage = compressedFile;
        _analysisResult = null;
        _errorMessage = null;
        _detectedObjects = [];
      });
      _analyzeImage(_selectedImage!);
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: 80, // Adjust as needed
        minWidth: 800, // Minimum width
        minHeight: 600, // Minimum height
      );
      return result != null ? File(result.path) : file;
    } catch (e) {
      return file;
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedImage = null;
      _analysisResult = null;
      _detectedObjects = [];
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture & Analyze'),
        elevation: 0,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: Column(
        children: [
          // Error message display
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main content area
          Expanded(
            child: _selectedImage != null
                ? _buildImageAnalysisView(theme)
                : _buildEmptyState(theme),
          ),

          // Bottom action buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    isPrimary: true,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Capture or select an image',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get insights about objects in your photos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageAnalysisView(ThemeData theme) {
    final text = _analysisResult?['text'] as String?;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // Image display
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Analysis results
            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            else if (_analysisResult != null)
              AnalyzedResultCard(
                objects: _detectedObjects,
                text: text ?? '',
                prompt: _analysisResult?['prompt']?.toString(),
                onShowTopicPicker: null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isPrimary = false,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          foregroundColor: isPrimary
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          elevation: 2,
          onPressed: _isAnalyzing ? null : onPressed,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
