import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/models/food_model.dart';

class AddFoodManually extends StatefulWidget {
  const AddFoodManually({super.key});

  @override
  State<AddFoodManually> createState() => _AddFoodManuallyState();
}

class _AddFoodManuallyState extends State<AddFoodManually> {
  late final TextEditingController foodController;
  late final TextEditingController calController;
  late final TextEditingController proController;
  late final TextEditingController carbController;
  late final TextEditingController fatController;
  late final TextEditingController fibeController;
  late final TextEditingController waterController;

  bool _isWater = false;

  @override
  void initState() {
    super.initState();
    foodController = TextEditingController();
    calController = TextEditingController();
    proController = TextEditingController();
    carbController = TextEditingController();
    fatController = TextEditingController();
    fibeController = TextEditingController();
    waterController = TextEditingController(text: "250");
  }

  @override
  void dispose() {
    foodController.dispose();
    calController.dispose();
    proController.dispose();
    carbController.dispose();
    fatController.dispose();
    fibeController.dispose();
    waterController.dispose();
    super.dispose();
  }

  void _save() {
    if (_isWater) {
      final waterText = waterController.text.trim();
      final waterAmount = double.tryParse(waterText);
      if (waterText.isEmpty || waterAmount == null || waterAmount <= 0) {
        Get.snackbar(
          "Required",
          "Please enter a valid water amount",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      final controller = Get.find<DashboardController>();
      controller.addWater(waterAmount);
      Navigator.pop(context);
    } else {
      final name = foodController.text.trim();
      if (name.isEmpty) {
        Get.snackbar(
          "Required",
          "Please enter a food name",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (calController.text.trim().isEmpty ||
          double.tryParse(calController.text.trim()) == null) {
        Get.snackbar(
          "Required",
          "Please enter valid calories",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (proController.text.trim().isEmpty ||
          double.tryParse(proController.text.trim()) == null) {
        Get.snackbar(
          "Required",
          "Please enter valid protein",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (carbController.text.trim().isEmpty ||
          double.tryParse(carbController.text.trim()) == null) {
        Get.snackbar(
          "Required",
          "Please enter valid carbs",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (fatController.text.trim().isEmpty ||
          double.tryParse(fatController.text.trim()) == null) {
        Get.snackbar(
          "Required",
          "Please enter valid fat",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (fibeController.text.trim().isEmpty ||
          double.tryParse(fibeController.text.trim()) == null) {
        Get.snackbar(
          "Required",
          "Please enter valid fiber",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final newFood = foodModel(
        uid: "",
        name: name,
        calories: double.parse(calController.text.trim()),
        protein: double.parse(proController.text.trim()),
        carbs: double.parse(carbController.text.trim()),
        fat: double.parse(fatController.text.trim()),
        Fiber: double.parse(fibeController.text.trim()),
        date: DateTime.now(),
      );

      final controller = Get.find<DashboardController>();
      controller.addFood(newFood);
      Navigator.pop(context, newFood);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.15)
        : AppColors.lightBorder;

    InputDecoration buildInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSecondary, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 12.0,
            left: 20.0,
            right: 20.0,
            bottom: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                "Add Food / Water",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Segmented selector for Food vs Water
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isWater = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isWater
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Food",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: !_isWater ? Colors.white : textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isWater = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isWater
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Water",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isWater ? Colors.white : textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_isWater) ...[
                TextField(
                  controller: waterController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: buildInputDecoration("Water Amount (ml)"),
                  style: TextStyle(fontSize: 14, color: textPrimary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [250, 500, 750, 1000].map((amount) {
                    final isSelected =
                        waterController.text == amount.toString();
                    return ActionChip(
                      label: Text("$amount ml"),
                      backgroundColor: isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.1)),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : borderColor,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onPressed: () {
                        setState(() {
                          waterController.text = amount.toString();
                        });
                      },
                    );
                  }).toList(),
                ),
              ] else ...[
                TextField(
                  controller: foodController,
                  keyboardType: TextInputType.text,
                  decoration: buildInputDecoration("Food Name"),
                  style: TextStyle(fontSize: 14, color: textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: calController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: buildInputDecoration("Calories (kcal)"),
                        style: TextStyle(fontSize: 14, color: textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: proController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: buildInputDecoration("Protein (g)"),
                        style: TextStyle(fontSize: 14, color: textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: buildInputDecoration("Carbs (g)"),
                        style: TextStyle(fontSize: 14, color: textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: buildInputDecoration("Fat (g)"),
                        style: TextStyle(fontSize: 14, color: textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fibeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: buildInputDecoration("Fiber (g)"),
                        style: TextStyle(fontSize: 14, color: textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    _isWater ? "Save Water" : "Save Food",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
