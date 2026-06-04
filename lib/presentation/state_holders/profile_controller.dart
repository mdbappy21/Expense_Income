import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  String userName = 'User';

  String? profileImagePath;

  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading = true;
      update();

      final prefs =
      await SharedPreferences.getInstance();

      userName =
          prefs.getString('profile_name') ??
              'Dear User';

      profileImagePath =
          prefs.getString('profile_image');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> updateName() async {
    final controller =
    TextEditingController(text: userName);

    await Get.dialog(
      AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name =
              controller.text.trim();

              if (name.isEmpty) {
                return;
              }

              final prefs =
              await SharedPreferences
                  .getInstance();

              await prefs.setString(
                'profile_name',
                name,
              );

              userName = name;

              update();

              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> pickProfileImage() async {
    try {
      final picker = ImagePicker();

      final image =
      await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'profile_image',
        image.path,
      );

      profileImagePath = image.path;

      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
      );
    }
  }

  Future<void> inviteFriend() async {
    await Share.share(
      'Track your income, expenses, payable and receivable money easily with Expense & Income Tracker.',
    );
  }

  ImageProvider get profileImage {
    if (profileImagePath != null &&
        File(profileImagePath!).existsSync()) {
      return FileImage(
        File(profileImagePath!),
      );
    }

    return const AssetImage(
      'assets/images/img.png',
    );
  }
}