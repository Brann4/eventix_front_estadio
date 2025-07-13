import 'package:eventix_estadio/features/presentation/pages/1_eventos_page.dart';
import 'package:eventix_estadio/features/presentation/pages/stadium_map_page.dart';
import 'package:eventix_estadio/features/presentation/provider/stadium_map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dependency_injector.dart' as di;

Future<void> main() async  {
  // Inicializa el inyector de dependencias
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env.development");

  di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visor de Estadios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const EventosPage(),
    );
  }
}
