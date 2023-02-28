part of minerva_cli;

class CreateDockerFileCLICommand extends CLICommand<void> {
  final String projectPath;

  final CompileType compileType;

  late AppSetting _appSetting;

  late CurrentBuildAppSetting _buildSetting;

  late final List<String> _assets;

  CreateDockerFileCLICommand(
    this.projectPath,
    this.compileType,
  );

  @override
  Future<void> run() async {
    await _parseAssets();

    final filePath = '$projectPath/Dockerfile';

    final dockerFile = File.fromUri(Uri.file(filePath));

    await dockerFile.create();

    if (compileType == CompileType.aot) {
      await _writeAOTFile(dockerFile);
    } else {
      await _writeJTIFile(dockerFile);
    }
  }

  Future<void> _parseAssets() async {
    late AppSettingParseResult appSettingParseResult;

    try {
      appSettingParseResult = await AppSettingParcer().parse(projectPath);
    } on AppSettingParserException catch (object) {
      throw CLICommandException(
        message: object.message!,
      );
    }

    _appSetting = appSettingParseResult.data;

    _buildSetting = CurrentBuildSettingParser()
        .parseCurrent(_appSetting, BuildMode.release);

    try {
      _assets = AppSettingAssetsParser().parse(
        _appSetting,
        _buildSetting,
      );
    } on CLICommandException catch (_) {
      rethrow;
    }
  }

  Future<void> _writeAOTFile(File file) async {
    await file.writeAsString('''
# Specify the Dart SDK base image
FROM dart:stable as build

# Create application directory.
WORKDIR /app

# Copy project.
COPY . . 

# Resolve app dependencies.
RUN dart pub get

# Activate Minerva.
RUN dart pub global activate minerva

# Build project.
RUN dart pub get --offline
RUN \${HOME}/.pub-cache/bin/minerva build -m release

# Build minimal serving image from AOT-compiled and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime /

COPY --from=build /app/build/release/bin /app/bin
COPY --from=build /app/build/release/appsetting.json /app${await _generateCopyAssets()}

# Start server.
EXPOSE ${_buildSetting.port}
CMD ["app/bin/main"]
''');
  }

  Future<void> _writeJTIFile(File file) async {
    await file.writeAsString('''
# Specify the Dart SDK base image
FROM dart:stable as build

# Create application directory.
WORKDIR /app

# Copy project.
COPY . . 

# Resolve app dependencies.
RUN dart pub get

# Activate Minerva.
RUN dart pub global activate minerva

# Build project.
RUN dart pub get --offline
RUN \${HOME}/.pub-cache/bin/minerva build -m release

# Build minimal serving image from kernel snapshot and dart from build stage.
FROM subfuzion/dart:slim
COPY --from=build /usr/lib/dart/bin/dart /usr/lib/dart/bin/dart

COPY --from=build /app/build/release/bin /app/bin
COPY --from=build /app/build/release/appsetting.json /app${await _generateCopyAssets()}

# Start server.
EXPOSE ${_buildSetting.port}
CMD ["usr/lib/dart/bin/dart", "app/bin/main.dill"]
''');
  }

  Future<String> _generateCopyAssets() async {
    var value = '';

    if (_assets.isNotEmpty) {
      value += '\n\n';
    }

    for (var i = 0; i < _assets.length; i++) {
      final asset = _assets[i];

      final files = await AssetsFilesParser(projectPath).parseOne(asset);

      if (files.isNotEmpty) {
        if (asset.startsWith('/')) {
          value +=
              'COPY --from=build /app/build/release$asset /app/${asset.substring(1)}';
        } else {
          final segments = asset.split('/');

          segments.removeLast();

          final path = segments.join('/');

          value += 'COPY --from=build app/build/release/$asset /app/$path';
        }

        if (i < _assets.length - 1) {
          value += '\n';
        }
      }
    }

    return value == '\n\n' ? '' : value;
  }
}
