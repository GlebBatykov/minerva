part of minerva_cli;

class ConfigureDockerCommand extends CLICommand<void> {
  final String projectPath;

  ConfigureDockerCommand(this.projectPath);

  @override
  Future<void> run() async {
    await _createDockerignore();

    await _createDockerFile();
  }

  Future<void> _createDockerignore() async {
    var filePath = '$projectPath/.dockerignore';

    var file = File.fromUri(Uri.file(filePath));

    await file.create();

    await file.writeAsString('''
.dockerignore
Dockerfile
build/
.dart_tool/
.git/
.github/
.gitignore
.pubignore
.package
''');
  }

  Future<void> _createDockerFile() async {
    var filePath = '$projectPath/Dockerfile';

    var dockerFile = File.fromUri(Uri.file(filePath));

    await dockerFile.create();

    await dockerFile.writeAsString('''
# Specify the Dart SDK base image
FROM dart:stable

# Create application directory.
WORKDIR /app

# Copy project.
COPY . .

# Resolve app dependencies and activate Minerva.
RUN dart pub get --offline
RUN dart pub global activate minerva

# Start server.
EXPOSE 8080
CMD ["minerva", "run", "-d", "/app", "-m", "release"]
''');
  }
}
