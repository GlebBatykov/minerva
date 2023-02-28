part of minerva_cli;

class CreateExampleCLICommand extends CLICommand<void> {
  final String projectPath;

  final ProjectTemplate projectTemplate;

  CreateExampleCLICommand(
    this.projectPath,
    this.projectTemplate,
  );

  @override
  Future<void> run() async {
    switch (projectTemplate) {
      case ProjectTemplate.controllers:
        await _createControllersExample();
        break;
      case ProjectTemplate.endpoints:
        await _createEndpointsExample();
    }
  }

  Future<void> _createControllersExample() async {
    final mainFile = File.fromUri(Uri.file('$projectPath/lib/main.dart'));

    final apisBuilderFile =
        File.fromUri(Uri.file('$projectPath/lib/builders/apis_builder.dart'));

    final loggersBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/loggers_builder.dart'));

    final settingBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/setting_builder.dart'));

    final middlewaresBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/middlewares_builder.dart'));

    final weatherForecastControllerFile = File.fromUri(Uri.file(
        '$projectPath/lib/controllers/weather_forecast_controller.dart'));

    final weatherForecastFile =
        File.fromUri(Uri.file('$projectPath/lib/models/weather_forecast.dart'));

    await Future.wait([
      mainFile.create(
        recursive: true,
      ),
      apisBuilderFile.create(
        recursive: true,
      ),
      loggersBuilderFile.create(
        recursive: true,
      ),
      settingBuilderFile.create(
        recursive: true,
      ),
      middlewaresBuilderFile.create(
        recursive: true,
      ),
      weatherForecastControllerFile.create(
        recursive: true,
      ),
      weatherForecastFile.create(
        recursive: true,
      )
    ]);

    final mainContent = '''
import 'package:minerva/minerva.dart';

import 'builders/setting_builder.dart';

void main(List<String> args) async {
  // Bind server
  await Minerva.bind(args: args, settingBuilder: SettingBuilder());
}
''';

    final loggersBuilderContent = '''
import 'package:minerva/minerva.dart';

class LoggersBuilder extends MinervaLoggersBuilder {
  @override
  List<Logger> build() {
    final loggers = <Logger>[];

    // Adds console logger to log pipeline
    loggers.add(ConsoleLogger());

    return loggers;
  }
}
''';

    final apisBuilderContent = '''
import 'package:minerva/minerva.dart';

import '../controllers/weather_forecast_controller.dart';

class ApisBuilder extends MinervaApisBuilder {
  @override
  List<Api> build() {
    return [WeatherForecastApi()];
  }
}
''';

    final middlewaresBuilderContent = '''
import 'package:minerva/minerva.dart';

class MiddlewaresBuilder extends MinervaMiddlewaresBuilder {
  @override
  List<Middleware> build() {
    final middlewares = <Middleware>[];

    // Adds middleware for handling errors in middleware pipeline
    middlewares.add(ErrorMiddleware());

    // Adds middleware for query mappings to endpoints in middleware pipeline
    middlewares.add(EndpointMiddleware());

    return middlewares;
  }
}
''';

    final weatherForecastControllerContent = '''
import 'dart:math';

import 'package:minerva/minerva.dart';
import 'package:minerva_controller_annotation/minerva_controller_annotation.dart';

import '../models/weather_forecast.dart';

part 'weather_forecast_controller.g.dart';

@Controller()
class WeatherForecastController extends ControllerBase {
  final Random _random = Random();

  static const _summaries = [
    'Freezing',
    'Bracing',
    'Chilly',
    'Cool',
    'Mild',
    'Warm',
    'Balmy',
    'Hot',
    'Sweltering',
    'Scorching'
  ];

  @Get()
  JsonResult get() {
    final weatherForecasts = List.generate(
        _random.nextInt(5) + 1,
        (index) => WeatherForecast(
            date: DateTime.now().add(Duration(days: index)),
            temperature: _random.nextInt(75) - 20,
            summary: _summaries[_random.nextInt(_summaries.length)]));

    final json = weatherForecasts.map((e) => e.toJson()).toList();

    return JsonResult(json);
  }
}
''';

    final weatherForecastContent = '''
class WeatherForecast {
  final DateTime date;

  final int temperature;

  final String summary;

  WeatherForecast(
      {required this.date, required this.temperature, required this.summary});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'temperature': temperature,
        'summary': summary
      };
}
''';

    final settingBuilderContent = '''
import 'dart:io';

import 'package:minerva/minerva.dart';

import 'apis_builder.dart';
import 'middlewares_builder.dart';
import 'loggers_builder.dart';

class SettingBuilder extends MinervaSettingBuilder {
  @override
  MinervaSetting build() {
    // Creates server setting
    return MinervaSetting(
        instance: Platform.numberOfProcessors,
        loggersBuilder: LoggersBuilder(),
        apisBuilder: ApisBuilder(),
        middlewaresBuilder: MiddlewaresBuilder());
  }
}
''';

    await Future.wait([
      mainFile.writeAsString(mainContent),
      apisBuilderFile.writeAsString(apisBuilderContent),
      loggersBuilderFile.writeAsString(loggersBuilderContent),
      settingBuilderFile.writeAsString(settingBuilderContent),
      middlewaresBuilderFile.writeAsString(middlewaresBuilderContent),
      weatherForecastControllerFile
          .writeAsString(weatherForecastControllerContent),
      weatherForecastFile.writeAsString(weatherForecastContent)
    ]);
  }

  Future<void> _createEndpointsExample() async {
    final mainFile = File.fromUri(Uri.file('$projectPath/lib/main.dart'));

    final endpointBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/endpoints_builder.dart'));

    final loggersBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/loggers_builder.dart'));

    final settingBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/setting_builder.dart'));

    final middlewaresBuilderFile = File.fromUri(
        Uri.file('$projectPath/lib/builders/middlewares_builder.dart'));

    await Future.wait([
      mainFile.create(
        recursive: true,
      ),
      endpointBuilderFile.create(
        recursive: true,
      ),
      loggersBuilderFile.create(
        recursive: true,
      ),
      settingBuilderFile.create(
        recursive: true,
      ),
      middlewaresBuilderFile.create(
        recursive: true,
      )
    ]);

    final endpointsBuilderContent = '''
import 'package:minerva/minerva.dart';

class EndpointsBuilder extends MinervaEndpointsBuilder {
  @override
  void build(Endpoints endpoints) {
    endpoints.get('/hello', (context, request) {
      return 'Hello, world!';
    });
  }
}
''';

    final mainContent = '''
import 'package:minerva/minerva.dart';

import 'builders/setting_builder.dart';

void main(List<String> args) async {
  // Bind server
  await Minerva.bind(args: args, settingBuilder: SettingBuilder());
}
''';

    final loggersBuilderContent = '''
import 'package:minerva/minerva.dart';

class LoggersBuilder extends MinervaLoggersBuilder {
  @override
  List<Logger> build() {
    final loggers = <Logger>[];

    // Adds console logger to log pipeline
    loggers.add(ConsoleLogger());

    return loggers;
  }
}
''';

    final middlewaresBuilderContent = '''
import 'package:minerva/minerva.dart';

class MiddlewaresBuilder extends MinervaMiddlewaresBuilder {
  @override
  List<Middleware> build() {
    final middlewares = <Middleware>[];

    // Adds middleware for handling errors in middleware pipeline
    middlewares.add(ErrorMiddleware());

    // Adds middleware for query mappings to endpoints in middleware pipeline
    middlewares.add(EndpointMiddleware());

    return middlewares;
  }
}
''';

    final settingBuilderContent = '''
import 'dart:io';

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
        instance: Platform.numberOfProcessors,
        loggersBuilder: LoggersBuilder(),
        endpointsBuilder: EndpointsBuilder(),
        middlewaresBuilder: MiddlewaresBuilder());
  }
}
''';

    await Future.wait([
      endpointBuilderFile.writeAsString(endpointsBuilderContent),
      mainFile.writeAsString(mainContent),
      loggersBuilderFile.writeAsString(loggersBuilderContent),
      settingBuilderFile.writeAsString(settingBuilderContent),
      middlewaresBuilderFile.writeAsString(middlewaresBuilderContent)
    ]);
  }
}
