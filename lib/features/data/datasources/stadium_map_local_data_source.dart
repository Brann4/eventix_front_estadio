import 'package:flutter/services.dart' show rootBundle;

abstract class StadiumMapLocalDataSource {
  Future<String> getStadiumMapSvgContent();
}

class StadiumMapLocalDataSourceImpl implements StadiumMapLocalDataSource {
  @override
  Future<String> getStadiumMapSvgContent() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return await rootBundle.loadString('assets/estadio.svg');
  }
}