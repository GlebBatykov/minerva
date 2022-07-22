part of minerva_cli;

class ConfigureProjectCLICommand extends CLICommand<void> {
  final String projectName;

  final String projectPath;

  final String compileType;

  ConfigureProjectCLICommand(
      this.projectName, this.projectPath, this.compileType);

  @override
  Future<void> run() async {
    await Directory.fromUri(Uri.directory('$projectPath/build')).create();

    await Future.wait([
      _configureAppSetting(),
      _createExample(),
      _configureGitignore(),
      _configurePubspec()
    ]);
  }

  Future<void> _configureAppSetting() async {
    var appSettingFile = File.fromUri(Uri.file('$projectPath/appsetting.json'));

    await appSettingFile.create();

    var appSetting = <String, dynamic>{};

    appSetting['debug'] = <String, dynamic>{
      'compile-type': compileType,
      'host': '127.0.0.1',
      'port': 5000
    };

    appSetting['release'] = <String, dynamic>{
      'compile-type': compileType,
      'host': '0.0.0.0',
      'port': 8080
    };

    var json = jsonEncode(appSetting);

    await appSettingFile.writeAsString(json);
  }

  Future<void> _configurePubspec() async {
    var pubSpecFile = File.fromUri(Uri.file('$projectPath/pubspec.yaml'));

    await pubSpecFile.create();

    await pubSpecFile.writeAsString('''
publish_to: none
name: $projectName
description: Minerva application.
version: 1.0.0

environment:
  sdk: '>=2.17.5 <3.0.0'

dependencies:
  minerva:
    git: https://github.com/GlebBatykov/minerva.git

dev_dependencies:
  lints: ^2.0.0
  test: ^1.16.0
''');
  }

  Future<void> _createExample() async {
    var mainFile = File.fromUri(Uri.file('$projectPath/lib/main.dart'));

    var endpointBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/endpoints_builder.dart'));

    var serverBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/server_builder.dart'));

    await Future.wait([
      mainFile.create(),
      endpointBuilderFile.create(),
      serverBuilderFile.create()
    ]);

    var endpointBuilderContent = '''
import 'package:minerva/minerva.dart';

void endpointsBuilder(Endpoints endpoints) {
  // Create route for GET requests with path '/hello'
  endpoints.get('/hello', (context, request) {
    var message = context.store['message'];

    return message;
  });
}
''';

    var serverBuilderContent = '''
import 'package:minerva/minerva.dart';

void serverBuilder(ServerContext context) {
  // Inject dependency or resource
  context.store['message'] = 'Hello, world!';
}
''';

    var mainContent = '''
import 'package:minerva/minerva.dart';

import 'endpoints_builder.dart';
import 'server_builder.dart';

void main(List<String> args) async {
  // Create server setting
  var setting = MinervaSetting(endpointsBuilder: endpointsBuilder, serverBuilder: serverBuilder);

  // Bind server
  await Minerva.bind(args: args, setting: setting);
}
''';

    await Future.wait([
      endpointBuilderFile.writeAsString(endpointBuilderContent),
      serverBuilderFile.writeAsString(serverBuilderContent),
      mainFile.writeAsString(mainContent)
    ]);
  }

  Future<void> _configureGitignore() async {
    var gitIgnoreFile = File.fromUri(Uri.file('$projectPath/.gitignore'));

    await gitIgnoreFile.create();

    await gitIgnoreFile.writeAsString('''
/build
/.dart_tool
''');
  }
}
