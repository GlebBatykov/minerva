part of minerva_cli;

class CreateDockerFileCLICommand extends CLICommand<void> {
  final String directoryPath;

  final String compileType;

  CreateDockerFileCLICommand(this.directoryPath, this.compileType);

  @override
  Future<void> run() async {
    var filePath = '$directoryPath/Dockerfile';

    var dockerFile = File.fromUri(Uri.file(filePath));

    await dockerFile.create();

    if (compileType == 'AOT') {
      await _writeAOTFile(dockerFile);
    } else {
      await _writeJTIFile(dockerFile);
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

# Start server.
EXPOSE 8080
CMD ["dart", "app/bin/main.dill"]
''');
  }
}
