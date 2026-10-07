import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/app.dart';
import 'package:taqs/core/storage/shared_preferences_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent key-value storage before the widget tree boots
  final storage = await SharedPreferencesStorage.create();

  runApp(
    ProviderScope(
      overrides: [
        keyValueStorageProvider.overrideWithValue(storage),
      ],
      child: const TaqsApp(),
    ),
  );
}
