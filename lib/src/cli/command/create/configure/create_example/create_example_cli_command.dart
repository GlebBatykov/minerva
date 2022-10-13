part of minerva_cli;

class CreateExampleCLICommand extends CLICommand<void> {
  final String projectPath;

  CreateExampleCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    var mainFile = File.fromUri(Uri.file('$projectPath/lib/main.dart'));

    var endpointBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/endpoints_builder.dart'));

    var serverBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/builders/server_builder.dart'));

    var apisBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/builders/apis_builder.dart'));

    var loggersBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/loggers_builder.dart'));

    var settingBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/setting_builder.dart'));

    var middlewaresBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/middlewares_builder.dart'));

    var agentsBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/builders/agents_builder.dart'));

    await Future.wait([
      mainFile.create(recursive: true),
      endpointBuilderFile.create(recursive: true),
      serverBuilderFile.create(recursive: true),
      apisBuilderFile.create(recursive: true),
      loggersBuilderFile.create(recursive: true),
      settingBuilderFile.create(recursive: true),
      middlewaresBuilderFile.create(recursive: true),
      agentsBuilderFile.create(recursive: true)
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

import 'builders/setting_builder.dart';

void main(List<String> args) async {
  // Bind server
  await Minerva.bind(args: args, setting: SettingBuilder());
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

    // Adds console logger to log pipeline
    loggers.add(ConsoleLogger());

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

    // Adds middleware for handling errors in middleware pipeline
    middlewares.add(ErrorMiddleware());

    // Adds middleware for query mappings to endpoints in middleware pipeline
    middlewares.add(EndpointMiddleware());

    return middlewares;
  }
}
''';

    var settingBuilderContent = '''
import 'package:minerva/minerva.dart';

import 'agents_builder.dart';
import 'apis_builder.dart';
import 'endpoints_builder.dart';
import 'middlewares_builder.dart';
import 'server_builder.dart';
import 'loggers_builder.dart';

class SettingBuilder extends MinervaSettingBuilder {
  @override
  MinervaSetting build() {
    // Creates server setting
    return MinervaSetting(
        instance: 1,
        loggersBuilder: LoggersBuilder(),
        endpointsBuilder: EndpointsBuilder(),
        serverBuilder: ServerBuilder(),
        apisBuilder: ApisBuilder(),
        agentsBuilder: AgentsBuilder(),
        middlewaresBuilder: MiddlewaresBuilder());
  }
}
''';

    var agentsBuilderContent = '''
import 'package:minerva/minerva.dart';

class AgentsBuilder extends MinervaAgentsBuilder {
  @override
  List<AgentData> build() {
    var agents = <AgentData>[];

    return agents;
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
      middlewaresBuilderFile.writeAsString(middlewaresBuilderContent),
      agentsBuilderFile.writeAsString(agentsBuilderContent)
    ]);
  }
}
