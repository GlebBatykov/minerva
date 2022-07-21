part of minerva_cli;

class ConfigureProjectCommand extends CLICommand<void> {
  final String projectName;

  final String projectPath;

  final String compileType;

  ConfigureProjectCommand(this.projectName, this.projectPath, this.compileType);

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
      'compile-tyoe': compileType,
      'entry-point': 'lib/startup.dart'
    };

    appSetting['release'] = <String, dynamic>{
      'compile-tyoe': compileType,
      'entry-point': 'lib/startup.dart'
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
    var startupFile = File.fromUri(Uri.file('$projectPath/lib/startup.dart'));

    var endpointBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/endpoints_builder.dart'));

    var serverBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/server_builder.dart'));

    await Future.wait([
      startupFile.create(),
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

    var startupContent = '''
import 'package:minerva/minerva.dart';

import 'endpoints_builder.dart';
import 'server_builder.dart';

void main() async {
  // Create server setting
  var setting = ServerSetting('127.0.0.1', 5000, builder: serverBuilder);

  // Bind server
  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}
''';

    await Future.wait([
      endpointBuilderFile.writeAsString(endpointBuilderContent),
      serverBuilderFile.writeAsString(serverBuilderContent),
      startupFile.writeAsString(startupContent)
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
