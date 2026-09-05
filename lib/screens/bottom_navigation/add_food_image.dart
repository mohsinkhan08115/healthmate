import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/models/food_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddFoodImage extends StatefulWidget {
  const AddFoodImage({super.key});

  @override
  State<AddFoodImage> createState() => _AddFoodImageState();
}

class _AddFoodImageState extends State<AddFoodImage> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  bool isScanning = false;

  String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  String get _geminiUrl =>
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiApiKey";

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);
    debugPrint("pickImage result: ${image?.path}");

    if (image != null && mounted) {
      setState(() {
        selectedImage = File(image.path);
      });
      debugPrint("selectedImage set to: ${selectedImage?.path}");
    }
  }

  void showOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.15) : AppColors.lightBorder;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Upload Food Image",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primary, size: 20),
                ),
                title: Text("Take Photo",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: textPrimary)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primary, size: 20),
                ),
                title: Text("Choose from Gallery",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: textPrimary)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _scanFoodWithGemini() async {
    debugPrint("=== _scanFoodWithGemini called ===");
    debugPrint("selectedImage is: ${selectedImage?.path ?? 'NULL'}");

    if (selectedImage == null) {
      debugPrint("selectedImage is NULL — skipping scan, returning early");
      return null;
    }

    final bytes = await selectedImage!.readAsBytes();
    final base64Image = base64Encode(bytes);

    const prompt = """
Identify the food in this image and estimate its nutrition.
Respond ONLY with raw JSON, no markdown, in this exact format:
{"name": "string", "calories": number, "protein": number, "carbs": number, "fat": number, "fiber": number}
""";

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inlineData": {"mimeType": "image/jpeg", "data": base64Image},
            },
          ],
        },
      ],
    });

    debugPrint("Calling Gemini API now...");

    final response = await http.post(
      Uri.parse(_geminiUrl),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    debugPrint("Gemini status: ${response.statusCode}");
    debugPrint("Gemini body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Scan failed ${response.statusCode}: ${response.body}");
    }

    final data = jsonDecode(response.body);

    final candidates = data["candidates"] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception("No candidates returned from Gemini");
    }

    final text = candidates[0]["content"]?["parts"]?[0]?["text"] as String?;
    if (text == null) {
      throw Exception("Unexpected Gemini response format");
    }

    final cleaned = text.replaceAll("```json", "").replaceAll("```", "").trim();

    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      throw Exception("Could not parse Gemini response as JSON: $cleaned");
    }
  }

  void _saveFood() async {
    debugPrint("=== _saveFood tapped ===");
    debugPrint("selectedImage at save time: ${selectedImage?.path ?? 'NULL'}");

    if (selectedImage == null) {
      Get.snackbar(
        "Error",
        "Please select an image first",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => isScanning = true);

    Map<String, dynamic>? result;
    try {
      result = await _scanFoodWithGemini();
    } catch (e) {
      debugPrint("Scan failed: $e");
      Get.snackbar(
        "Scan failed",
        "$e — saved as unknown food",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    if (!mounted) return;
    setState(() => isScanning = false);

    final food = foodModel(
      uid: FirebaseAuth.instance.currentUser?.uid ?? "",
      name: result?["name"] ?? "Unknown Food",
      calories: (result?["calories"] ?? 0).toDouble(),
      protein: (result?["protein"] ?? 0).toDouble(),
      carbs: (result?["carbs"] ?? 0).toDouble(),
      fat: (result?["fat"] ?? 0).toDouble(),
      Fiber: (result?["fiber"] ?? 0).toDouble(),
      date: DateTime.now(),
    );

    Get.find<DashboardController>().addFood(food);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dragHandleColor =
        isDark ? Colors.white.withOpacity(0.15) : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final placeholderBg =
        isDark ? AppColors.darkBackground : const Color(0xFFF0FDF4);
    final placeholderBorder = isDark
        ? Border.all(color: Colors.white.withOpacity(0.15))
        : Border.all(color: const Color(0xFFDCFCE7));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 12.0, left: 20.0, right: 20.0, bottom: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dragHandleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Scan Food Image",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Take a photo of your food to auto-estimate macros using AI",
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              selectedImage != null
                  ? Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: placeholderBorder,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: showOptions,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: placeholderBg,
                          borderRadius: BorderRadius.circular(16),
                          border: placeholderBorder,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withOpacity(isDark ? 0.15 : 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Tap to upload or take a photo",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Supports JPG, PNG, WEBP",
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              if (selectedImage != null)
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: showOptions,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Retake Photo",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              if (selectedImage != null) const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      isScanning || selectedImage == null ? null : _saveFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isScanning
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Scan & Save Food",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
