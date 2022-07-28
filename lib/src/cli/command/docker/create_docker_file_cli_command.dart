part of minerva_cli;

class CreateDockerFileCLICommand extends CLICommand<void> {
  final String projectPath;

  final String compileType;

  late final List<String> _assets;

  CreateDockerFileCLICommand(this.projectPath, this.compileType);

  @override
  Future<void> run() async {
    await _parseAssets();

    var filePath = '$projectPath/Dockerfile';

    var dockerFile = File.fromUri(Uri.file(filePath));

    await dockerFile.create();

    if (compileType == 'AOT') {
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
      throw CLICommandException(message: object.message);
    }

    var appSetting = appSettingParseResult.data;

    try {
      _assets = AppSettingAssetsParser().parse(appSetting);
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
RUN dart pub global activate Minerva

# Build project.
RUN dart pub get --offline
RUN minerva build -m release

# Build minimal serving image from AOT-compiled and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime /

COPY --from=build /app/build/release/bin /app
COPY --from=build /app/build/release/appsetting.json /app

${_generateCopyAssets(_assets)}

# Start server.
EXPOSE 8080
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
RUN dart pub global activate Minerva

# Build project.
RUN dart pub get --offline
RUN minerva build -m release

# Build minimal serving image from kernel snapshot and dart from build stage.
FROM scratch
COPY --from=build /usr/lib/dart/bin/dart /usr/lib/dart/bin/dart

COPY --from=build /app/build/release/bin /app
COPY --from=build /app/build/release/appsetting.json /app

${_generateCopyAssets(_assets)}

# Start server.
EXPOSE 8080
CMD ["dart", "app/bin/main.dill"]
''');
  }

  String _generateCopyAssets(List<String> assets) {
    var value = '';

    for (var i = 0; i < assets.length; i++) {
      var asset = assets[i];

      if (asset.startsWith('/')) {
        value += 'COPY --from=build /app/build/release$asset /app';
      } else {
        value += 'COPY --from=build /app/build/release/$asset /app';
      }

      if (i < assets.length - 1) {
        value += '\n';
      }
    }

    return value;
  }
}
