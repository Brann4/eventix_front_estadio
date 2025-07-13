import 'package:flutter/services.dart' show rootBundle;

abstract class StadiumMapLocalDataSource {
  Future<String> getStadiumMapSvgContent(String svgPath);
}

class StadiumMapLocalDataSourceImpl implements StadiumMapLocalDataSource {
  @override
  Future<String> getStadiumMapSvgContent(String svgPath) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return await rootBundle.loadString(svgPath);
  }
}