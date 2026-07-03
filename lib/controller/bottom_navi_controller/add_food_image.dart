import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/models/food_model.dart';

class AddFoodImage extends StatefulWidget {
  const AddFoodImage({super.key});

  @override
  State<AddFoodImage> createState() => _AddFoodImageState();
}

class _AddFoodImageState extends State<AddFoodImage> {
  final DashboardController _controller = Get.find<DashboardController>();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool _loading = false;
  String? _errorMessage;

  String _foodName = 'Unknown Food';
  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;
  double _fiber = 0;

  bool _readyToSave = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
      _readyToSave = false;
    });

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _loading = true;
      _readyToSave = false;
    });

    await _recogniseFood(_image!);
  }

  Future<void> _recogniseFood(File imageFile) async {
    try {
      final String geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

      if (geminiApiKey.isEmpty) {
        setState(() {
          _errorMessage =
              'Missing GEMINI_API_KEY in .env file. You can still save manually.';
          _loading = false;
          _readyToSave = true;
        });
        return;
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      const prompt = '''
You are a nutrition expert. Look at this food photo.
Identify the food and estimate nutrition for a typical single serving.
Respond ONLY with valid JSON, no markdown, no extra text:
{"name":"Food Name","calories":0,"protein":0,"carbs":0,"fat":0,"fiber":0}
All values must be numbers. Use 0 if unknown.
''';

      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {'mime_type': mimeType, 'data': base64Image},
                },
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'maxOutputTokens': 1024, 'temperature': 0.1},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('FULL RESPONSE: ${response.body}');

        final rawText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        print('RAW TEXT: $rawText');

        final cleaned = rawText
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();

        print('CLEANED: $cleaned');

        final nutrition = jsonDecode(cleaned) as Map<String, dynamic>;

        setState(() {
          _foodName = nutrition['name']?.toString() ?? 'Unknown Food';
          _calories = (nutrition['calories'] as num?)?.toDouble() ?? 0;
          _protein = (nutrition['protein'] as num?)?.toDouble() ?? 0;
          _carbs = (nutrition['carbs'] as num?)?.toDouble() ?? 0;
          _fat = (nutrition['fat'] as num?)?.toDouble() ?? 0;
          _fiber = (nutrition['fiber'] as num?)?.toDouble() ?? 0;

          _loading = false;
          _readyToSave = true;
        });
      } else {
        print('=== GEMINI ERROR ${response.statusCode} ===');
        print(response.body);

        String detail = response.body;
        try {
          final err = jsonDecode(response.body);
          detail = err['error']?['message']?.toString() ?? response.body;
        } catch (_) {}

        setState(() {
          _errorMessage = 'Scan failed (${response.statusCode}): $detail';
          _loading = false;
          _readyToSave = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Scan error: $e\nYou can still save manually below.';
        _loading = false;
        _readyToSave = true;
      });
    }
  }

  void _saveFood() async {
    final food = foodModel(
      uid: '',
      name: _foodName,
      calories: _calories,
      protein: _protein,
      carbs: _carbs,
      fat: _fat,
      Fiber: _fiber,
      date: DateTime.now(),
    );

    _controller.addFood(food);
    await Future.delayed(const Duration(milliseconds: 100));

    final messengerState = ScaffoldMessenger.of(context);

    Navigator.pop(context);

    messengerState.showSnackBar(
      SnackBar(
        content: Text('${food.name} added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  'Scan Food',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                _buildImagePreview(),
                const SizedBox(height: 16),

                if (!_loading && !_readyToSave) ...[
                  _PickButton(
                    icon: Icons.camera_alt,
                    label: 'Take Photo',
                    color: Colors.deepOrangeAccent,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(height: 10),
                  _PickButton(
                    icon: Icons.photo_library,
                    label: 'Choose from Gallery',
                    color: Colors.blueAccent,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],

                if (_loading) ...[
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 10),
                  const Text(
                    'Recognising food…',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.orange.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                if (_readyToSave) ...[
                  const SizedBox(height: 16),
                  _buildEditableFields(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _readyToSave = false;
                              _image = null;
                              _errorMessage = null;
                              _foodName = 'Unknown Food';
                              _calories = 0;
                              _protein = 0;
                              _carbs = 0;
                              _fat = 0;
                              _fiber = 0;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Rescan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveFood,
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            'Add to Log',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepOrangeAccent, Color(0xFFFF3D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _foodName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MacroChip(label: 'Calories', value: '${_calories.toInt()} kcal'),
              const SizedBox(width: 8),
              _MacroChip(
                label: 'Protein',
                value: '${_protein.toStringAsFixed(1)}g',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MacroChip(
                label: 'Carbs',
                value: '${_carbs.toStringAsFixed(1)}g',
              ),
              const SizedBox(width: 8),
              _MacroChip(label: 'Fat', value: '${_fat.toStringAsFixed(1)}g'),
              const SizedBox(width: 8),
              _MacroChip(
                label: 'Fiber',
                value: '${_fiber.toStringAsFixed(1)}g',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_image == null) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Take or choose a photo of your meal',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(_image!, height: 180, fit: BoxFit.cover),
    );
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PickButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;

  const _MacroChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
