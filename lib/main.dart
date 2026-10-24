import 'package:flutter/material.dart';
import 'app.dart';
import 'data/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await AppStore.load();
  runApp(CamshareApp(store: store));
}
