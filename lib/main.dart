import 'package:eventix_estadio/features/presentation/pages/stadium_map_page.dart';
import 'package:eventix_estadio/features/presentation/provider/stadium_map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dependency_injector.dart' as di;

void main() {
  // Inicializa el inyector de dependencias
  di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Obtiene la instancia del provider desde el service locator
      create: (context) => di.sl<StadiumMapProvider>(),
      child: MaterialApp(
        title: 'Visor de Estadio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[200],
        ),
        debugShowCheckedModeBanner: false,
        home: const StadiumMapPage(),
      ),
    );
  }
}