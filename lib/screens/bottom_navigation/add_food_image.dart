import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/models/food_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddFoodImage extends StatefulWidget {
  const AddFoodImage({super.key});

  @override
  State<AddFoodImage> createState() => _AddFoodImageState();
}

class _AddFoodImageState extends State<AddFoodImage> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  bool isScanning = false;

  String get _geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ??
      ''; // Make sure to set this in your .env file

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
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: 500,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Gallery"),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
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
    return SafeArea(
      child: SizedBox(
        height: 500,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selectedImage != null
                ? Image.file(
                    selectedImage!,
                    height: 350,
                    width: double.infinity,
                  )
                : const Text("No Image Selected"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: showOptions,
              child: const Text("Pick Image"),
            ),
            ElevatedButton(
              onPressed: isScanning ? null : _saveFood,
              child: isScanning
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
