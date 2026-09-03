import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/profile_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';

class YourProfileWidget extends StatelessWidget {
  YourProfileWidget({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  radius: 26,
                  backgroundImage: AssetImage("assets/images/profile.jpg"),
                ),
                title: Text(
                  controller.name.value.isEmpty
                      ? "User"
                      : controller.name.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  "Manage Your Health Goals",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatChip("Age", "${controller.age.value} yrs"),
                  const SizedBox(width: 12),
                  _buildStatChip("Weight", "${controller.weight.value} kg"),
                  const SizedBox(width: 12),
                  _buildStatChip("Height", "${controller.height.value} ft"),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
