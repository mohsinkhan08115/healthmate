import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/models/food_model.dart';
import 'package:healthmate/core/theme/app_colors.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  'Scan Food',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                _buildImagePreview(),
                const SizedBox(height: 20),

                if (!_loading && !_readyToSave) ...[
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'Take Photo',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 18),
                      label: const Text(
                        'Choose from Gallery',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                if (_loading) ...[
                  const SizedBox(height: 32),
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Recognising food…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                if (_readyToSave) ...[
                  const SizedBox(height: 16),
                  _buildEditableFields(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
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
                            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
                            label: const Text(
                              'Rescan',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _saveFood,
                            icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                            label: const Text(
                              'Add to Log',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.steps, // Green save button
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _foodName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MacroChip(
                  label: 'Calories',
                  value: '${_calories.toInt()} kcal',
                  color: AppColors.calories,
                  trackColor: AppColors.caloriesTrack,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroChip(
                  label: 'Protein',
                  value: '${_protein.toStringAsFixed(1)}g',
                  color: AppColors.protein,
                  trackColor: AppColors.proteinTrack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MacroChip(
                  label: 'Carbs',
                  value: '${_carbs.toStringAsFixed(1)}g',
                  color: AppColors.water,
                  trackColor: AppColors.waterTrack,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroChip(
                  label: 'Fat',
                  value: '${_fat.toStringAsFixed(1)}g',
                  color: AppColors.breakfast,
                  trackColor: AppColors.stepsTrack,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroChip(
                  label: 'Fiber',
                  value: '${_fiber.toStringAsFixed(1)}g',
                  color: AppColors.textSecondary,
                  trackColor: AppColors.primarySurface,
                ),
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
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.textSecondary),
              SizedBox(height: 8),
              Text(
                'Take or choose a photo of your meal',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(_image!, height: 180, width: double.infinity, fit: BoxFit.cover),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color trackColor;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

