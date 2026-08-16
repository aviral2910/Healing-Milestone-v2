import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaUploadBottomSheet extends StatefulWidget {
  const MediaUploadBottomSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const MediaUploadBottomSheet(),
      ),
    );
  }

  @override
  State<MediaUploadBottomSheet> createState() => _MediaUploadBottomSheetState();
}

class _MediaUploadBottomSheetState extends State<MediaUploadBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSensitive = false;
  XFile? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _upload() {
    // TODO: Compress image, upload to Firebase Storage, construct MediaAttachment and return
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Media', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor, size: 40),
                        const SizedBox(height: 8),
                        const Text('Tap to select an image', style: TextStyle(color: Color(0xFFA0A0A0))),
                      ],
                    )
                  : Center(
                      child: Text('Image Selected', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mark as Sensitive', style: TextStyle(color: Color(0xFFE0E0E0))),
              Switch(
                value: _isSensitive,
                activeThumbColor: Theme.of(context).colorScheme.secondary,
                onChanged: (val) {
                  setState(() => _isSensitive = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedImage == null ? null : _upload,
              child: const Text('Save Attachment'),
            ),
          ),
        ],
      ),
    );
  }
}
