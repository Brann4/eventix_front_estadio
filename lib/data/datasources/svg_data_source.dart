import 'package:flutter/services.dart' show rootBundle;

// Contrato para la fuente de datos SVG
abstract class SvgDataSource {
  Future<String> getSvgContent(String svgPath);
}

// Implementación de la fuente de datos SVG
class SvgDataSourceImpl implements SvgDataSource {
  @override
  Future<String> getSvgContent(String svgPath) async {
    // Carga el contenido de un archivo SVG desde la carpeta de assets
    // y lo devuelve como un string.
    try {
      return await rootBundle.loadString(svgPath);
    } catch (e) {
      // Manejar el error, por ejemplo, si el archivo no se encuentra
      print('Error al cargar el archivo SVG: $e');
      throw Exception('No se pudo cargar el archivo SVG: $svgPath');
    }
  }
}