part of minerva_cli;

class CreateExampleTestCLICommand extends CLICommand<void> {
  final String projectPath;

  CreateExampleTestCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    var exampleTestFilePath = '$projectPath/test/endpoints_test.dart';

    var examapleTestFile = File.fromUri(Uri.file(exampleTestFilePath));

    await examapleTestFile.create(recursive: true);

    await examapleTestFile.writeAsString('''
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import 'test_app_setting.g.dart';

void main() {
  group('Endpoints', () {
    final Dio dio = Dio();

    final String host = TestAppSetting.host;

    final int port = TestAppSetting.port;

    test('GET /hello', () async {
      var response = await dio.get('http://\$host:\$port/hello');

      expect(response.data, 'Hello, world!');
    });
  });
}
''');
  }
}
