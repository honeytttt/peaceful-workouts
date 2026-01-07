import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/loading_button.dart';
import 'add_post_provider.dart';
import '../../core/helpers/image_picker_helper.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _selectedWorkoutType;
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isLoadingImage = false;

  final List<String> _workoutTypes = [
    'Yoga',
    'Meditation',
    'Running',
    'Cycling',
    'Strength Training',
    'Swimming',
    'Walking',
    'Pilates',
    'HIIT',
    'Dance',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadImageIfNeeded();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadImageIfNeeded() async {
    if (_selectedImage != null && mounted) {
      await _loadImageBytes();
    }
  }

  Future<void> _loadImageBytes() async {
    if (_selectedImage == null || !mounted) return;
    
    setState(() {
      _isLoadingImage = true;
    });
    
    try {
      final bytes = await _selectedImage!.readAsBytes();
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading image bytes: $e');
      if (mounted) {
        setState(() {
          _imageBytes = null;
          _isLoadingImage = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
  if (!mounted) return;
  
  final picker = ImagePicker();
  
  // Show options based on platform
  final source = await showModalBottomSheet<ImageSource?>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show camera option for all platforms (browser will handle it)
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take Photo'),
              subtitle: kIsWeb 
                ? const Text('Use your webcam (browser permission required)')
                : const Text('Use camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from Gallery'),
              subtitle: kIsWeb 
                ? const Text('Upload from your computer')
                : const Text('Select from photo gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context, null),
            ),
          ],
        ),
      );
    },
  );

  if (source != null && mounted) {
    try {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      
      if (image != null && mounted) {
        print('Image selected: ${image.path}');
        setState(() {
          _selectedImage = image;
          _imageBytes = null;
          _isLoadingImage = true;
        });
        await _loadImageBytes();
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

  void _removeImage() {
    if (mounted) {
      setState(() {
        _selectedImage = null;
        _imageBytes = null;
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _submitPost() async {
  if (!mounted) return;
  
  if (_formKey.currentState!.validate() && _selectedWorkoutType != null) {
    final provider = Provider.of<AddPostProvider>(context, listen: false);
    
    try {
      final success = await provider.createPost(
        content: _contentController.text,
        workoutType: _selectedWorkoutType!,
        durationMinutes: int.parse(_durationController.text),
        imageFile: _selectedImage,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Workout shared successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Wait a bit then return to feed
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      } else if (mounted && provider.errorMessage.isNotEmpty) {
        // Show error but still success (image might have failed but post created)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚠️ Post created with issues:'),
                const SizedBox(height: 4),
                Text(
                  provider.errorMessage,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to share workout: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  } else if (_selectedWorkoutType == null && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a workout type')),
    );
  }
}

  void _resetForm() {
    _contentController.clear();
    _durationController.clear();
    setState(() {
      _selectedWorkoutType = null;
      _selectedImage = null;
      _imageBytes = null;
      _isLoadingImage = false;
    });
  }

Widget _buildImagePreview() {
  if (_selectedImage == null) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add photo',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          kIsWeb 
            ? 'Camera & Gallery options available' 
            : 'Camera available on mobile',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  if (_isLoadingImage || _imageBytes == null) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Loading image...'),
        ],
      ),
    );
  }

  return Image.memory(
    _imageBytes!,
    width: double.infinity,
    height: 200,
    fit: BoxFit.cover,
  );
}

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photo (Optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Image preview
                  Center(child: _buildImagePreview()),
                  
                  // Remove button if image is selected
                  if (_selectedImage != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          color: Colors.white,
                          onPressed: _removeImage,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Upload progress indicator
        Consumer<AddPostProvider>(
          builder: (context, provider, child) {
            if (provider.uploadProgress > 0 && provider.uploadProgress < 1) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: provider.uploadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Uploading to Cloudinary... ${(provider.uploadProgress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildWorkoutTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Type *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedWorkoutType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Select workout type',
          ),
          items: _workoutTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            if (mounted) {
              setState(() {
                _selectedWorkoutType = value;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a workout type';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration (minutes) *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'e.g., 30',
            suffixText: 'minutes',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter duration';
            }
            final minutes = int.tryParse(value);
            if (minutes == null || minutes <= 0) {
              return 'Please enter valid minutes';
            }
            if (minutes > 360) {
              return 'Duration too long (max 6 hours)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share your experience *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'How was your workout? Share your thoughts...',
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please share your experience';
            }
            if (value.length < 10) {
              return 'Please share more details (min. 10 characters)';
            }
            if (value.length > 1000) {
              return 'Content too long (max 1000 characters)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 0,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Sharing Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Share what made your workout peaceful\n'
              '• Mention any challenges you overcame\n'
              '• Include tips for others\n'
              '• Keep it positive and inspiring',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Workout'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<AddPostProvider>(
              builder: (context, provider, child) {
                return LoadingButton(
                  onPressed: _submitPost,
                  isLoading: provider.isLoading,
                  text: 'Post',
                  icon: Icons.send,
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              _buildImageUploadSection(),
              const SizedBox(height: 24),
              
              // Workout Type
              _buildWorkoutTypeDropdown(),
              const SizedBox(height: 16),
              
              // Duration
              _buildDurationField(),
              const SizedBox(height: 16),
              
              // Content
              _buildContentField(),
              const SizedBox(height: 24),
              
              // Tips
              _buildTipsCard(),
            ],
          ),
        ),
      ),
    );
  }
}