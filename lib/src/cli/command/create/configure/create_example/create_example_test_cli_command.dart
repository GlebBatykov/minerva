part of minerva_cli;

class CreateExampleTestCLICommand extends CLICommand<void> {
  final String projectPath;

  final ProjectTemplate projectTemplate;

  CreateExampleTestCLICommand(this.projectPath, this.projectTemplate);

  @override
  Future<void> run() async {
    final exampleTestFilePath = '$projectPath/test/endpoints_test.dart';

    final examapleTestFile = File.fromUri(Uri.file(exampleTestFilePath));

    await examapleTestFile.create(recursive: true);

    await examapleTestFile.writeAsString(_getContent());
  }

  String _getContent() {
    switch (projectTemplate) {
      case ProjectTemplate.controllers:
        return '''
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:test/test.dart';

import 'test_app_setting.g.dart';

void main() {
  group('Endpoints', () {
    final Dio dio = Dio();

    final String host = \$TestAppSetting.host;

    final int port = \$TestAppSetting.port;

    test('Get weather forecasts', () async {
      final response = await dio.get('http://\$host:\$port/weatherforecast');

      final data = response.data;

      expect(data, isList);

      final item = (data as List).first;

      expect(item, isMap);
      expect((item as Map).length, 3);
      expect(item.containsKey('date'), true);
      expect(item.containsKey('temperature'), true);
      expect(item.containsKey('summary'), true);
      expect(
          item['date'].runtimeType == String &&
              DateTime.tryParse(item['date']) != null,
          true);
      expect(item['temperature'].runtimeType == int, true);
      expect(item['summary'].runtimeType == String, true);
    });
  });
}
''';
      case ProjectTemplate.endpoints:
        return '''
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import 'test_app_setting.g.dart';

void main() {
  group('Endpoints', () {
    final Dio dio = Dio();

    final String host = \$TestAppSetting.host;

    final int port = \$TestAppSetting.port;

    test('Get 'Hello, world!' message', () async {
      final response = await dio.get('http://\$host:\$port/hello');

      expect(response.data, 'Hello, world!');
    });
  });
}
''';
    }
  }
}
