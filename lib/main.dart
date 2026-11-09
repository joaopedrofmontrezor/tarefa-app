import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'screens/tarefas_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização multiplataforma do SQLite
  if (kIsWeb) {
    // Suporte a Web (Chrome / Edge via WebAssembly)
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Suporte a Desktop (Windows via FFI nativo)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aula 13 - SQLite',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const TarefasScreen(),
    );
  }
}
