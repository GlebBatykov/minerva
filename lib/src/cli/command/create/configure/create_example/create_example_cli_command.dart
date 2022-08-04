part of minerva_cli;

class CreateExampleCLICommand extends CLICommand<void> {
  final String projectPath;

  CreateExampleCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    var mainFile = File.fromUri(Uri.file('$projectPath/lib/main.dart'));

    var endpointBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builder/endpoints_builder.dart'));

    var serverBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/builder/server_builder.dart'));

    var apisBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/builder/apis_builder.dart'));

    var loggersBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/builder/loggers_builder.dart'));

    var settingBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/builder/setting_builder.dart'));

    var middlewaresBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builder/middlewares_builder.dart'));

    await Future.wait([
      mainFile.create(recursive: true),
      endpointBuilderFile.create(recursive: true),
      serverBuilderFile.create(recursive: true),
      apisBuilderFile.create(recursive: true),
      loggersBuilderFile.create(recursive: true),
      settingBuilderFile.create(recursive: true),
      middlewaresBuilderFile.create(recursive: true)
    ]);

    var endpointsBuilderContent = '''
import 'package:minerva/minerva.dart';

class EndpointsBuilder extends MinervaEndpointsBuilder {
  @override
  void build(Endpoints endpoints) {
    // Create route for GET requests with path '/hello'
    endpoints.get('/hello', (context, request) {
      var message = context.store['message'];

      return message;
    });
  }
}
''';

    var serverBuilderContent = '''
import 'package:minerva/minerva.dart';

class ServerBuilder extends MinervaServerBuilder {
  @override
  void build(ServerContext context) {
    // Inject dependency or resource
    context.store['message'] = 'Hello, world!';
  }
}
''';

    var mainContent = '''
import 'package:minerva/minerva.dart';

import 'builder/setting_builder.dart';

void main(List<String> args) async {
  // Bind server
  await Minerva.bind(args: args, setting: SettingBuilder().build());
}
''';

    var apisBuilderContent = '''
import 'package:minerva/minerva.dart';

class ApisBuilder extends MinervaApisBuilder {
  @override
  List<Api> build() {
    var apis = <Api>[];

    return apis;
  }
}
''';

    var loggersBuilderContent = '''
import 'package:minerva/minerva.dart';

class LoggersBuilder extends MinervaLoggersBuilder {
  @override
  List<Logger> build() {
    var loggers = <Logger>[];

    //
    loggers.add(MinervaLogger());

    return loggers;
  }
}
''';

    var middlewaresBuilderContent = '''
import 'package:minerva/minerva.dart';

class MiddlewaresBuilder extends MinervaMiddlewaresBuilder {
  @override
  List<Middleware> build() {
    var middlewares = <Middleware>[];

    //
    middlewares.add(ErrorMiddleware());

    //
    middlewares.add(EndpointMiddleware());

    return middlewares;
  }
}
''';

    var settingBuilderContent = '''
import 'package:minerva/minerva.dart';

import 'apis_builder.dart';
import 'endpoints_builder.dart';
import 'middlewares_builder.dart';
import 'server_builder.dart';
import 'loggers_builder.dart';

class SettingBuilder extends MinervaSettingBuilder {
  @override
  MinervaSetting build() {
    //
    return MinervaSetting(
        instance: 1,
        loggersBuilder: LoggersBuilder(),
        endpointsBuilder: EndpointsBuilder(),
        serverBuilder: ServerBuilder(),
        apisBuilder: ApisBuilder(),
        middlewaresBuilder: MiddlewaresBuilder());
  }
}
''';

    await Future.wait([
      endpointBuilderFile.writeAsString(endpointsBuilderContent),
      serverBuilderFile.writeAsString(serverBuilderContent),
      mainFile.writeAsString(mainContent),
      apisBuilderFile.writeAsString(apisBuilderContent),
      loggersBuilderFile.writeAsString(loggersBuilderContent),
      settingBuilderFile.writeAsString(settingBuilderContent),
      middlewaresBuilderFile.writeAsString(middlewaresBuilderContent)
    ]);
  }
}
