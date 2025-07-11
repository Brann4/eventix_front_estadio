import 'dart:convert';

import 'package:eventix_estadio/core/config/constants.dart';
import 'package:eventix_estadio/features/domain/models/asiento_detalle_model.dart';
import 'package:eventix_estadio/utils/api_response.dart';
import 'package:http/http.dart' as http;

class AsientoService {
  final String baseUrl = '${ApiConstants.baseUrl}/api/gestor/Asiento';
  final http.Client client;

  AsientoService({http.Client? client}) : client = client ?? http.Client();

  Future<ApiResponse<PlanoDetalle>> obtenerDetalleAsiento(String idAsiento,String idSector ) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/ObtenerEstadoAsiento/$idAsiento/$idSector'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data['value'] == null || (data['value']  is! Map)) {
          return ApiResponse(
            status: true,
            value: null,
            msg: 'No se encontró detalle del asiento o el formato es incorrecto.',
          );
        }

       final asientoDetalle = PlanoDetalle.fromJson(data['value']);

        return ApiResponse(
          status: true,
          value: asientoDetalle,
          msg: 'OK',
        );
      } else {
        return ApiResponse(
          status: false,
          value: null,
          msg: 'Error HTTP: ${response.statusCode}',
        );
      }
    } 
    
    catch (e) {
      return ApiResponse(status: false, value: null, msg: 'Excepción: $e');
    }
  }

   void dispose() {
    client.close();
  }
}
