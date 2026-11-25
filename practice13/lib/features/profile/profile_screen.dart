import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  // the gallery picker on new Android needs no permission
  Future<void> _choosePhoto() => _pick(ImageSource.gallery);

  // ask at the tap, not in initState: the user should know why
  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted || PermissionStatus.limited:
        await _pick(ImageSource.camera);
      case PermissionStatus.permanentlyDenied:
        await _askToOpenSettings();
      case PermissionStatus.denied ||
          PermissionStatus.restricted ||
          PermissionStatus.provisional:
        _say(
          'No camera access. You can still choose a photo from the gallery.',
        );
    }
  }

  Future<void> _askToOpenSettings() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.no_photography),
        title: const Text('Camera is turned off'),
        content: const Text(
          "You said No twice, so Android won't ask again. "
          'To take a photo, allow the camera in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open ?? false) await openAppSettings();
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return; // Cancel
    // copy into Documents, the picker's own file can be in a cache folder
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}${Platform.pathSeparator}avatar.jpg';
    await File(picked.path).copy(path);
    await FileImage(File(path)).evict(); // same path, so drop the old image
    if (!mounted) return;
    await context.read<SettingsModel>().setAvatar(path);
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<SettingsModel>().avatarPath;
    final file = path == null ? null : File(path);
    final hasPhoto = file != null && file.existsSync();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 72,
              backgroundImage: hasPhoto ? FileImage(file) : null,
              child: hasPhoto ? null : const Icon(Icons.person, size: 72),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _choosePhoto,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
