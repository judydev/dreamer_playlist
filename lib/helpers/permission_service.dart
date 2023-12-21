import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future requestStoragePermission();
  Future<bool> handleStoragePermission(BuildContext context);
}

class PermissionHandler implements PermissionService {
  @override
  Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.storage.request();
  }

  @override
  Future<bool> handleStoragePermission(BuildContext context) async {
    PermissionStatus storagePermissionStatus = await requestStoragePermission();

    if (storagePermissionStatus != PermissionStatus.granted) {
      if (!context.mounted) return false;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Denied'),
          content: Text('You can change this setting in app settings'),
          actions: [
            ElevatedButton(
              onPressed: () => openAppSettings(),
              child: const Text('Confirm'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }
}
