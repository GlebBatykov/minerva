part of minerva_cli;

class ConfigureDockerCommand extends CLICommand<void> {
  final String projectPath;

  final String dockerCompileType;

  ConfigureDockerCommand(this.projectPath, this.dockerCompileType);

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

    var file = File.fromUri(Uri.file(filePath));

    await file.create();

    await file.writeAsString('''
FROM dart:stable AS build

WORKDIR /minerva
COPY pubspec.* ./
RUN dart pub get
RUN dart pub global activate minerva

COPY . .

${() {
      if (dockerCompileType == 'AOT') {
        return '''
RUN dart pub get --offline
RUN dart compile exe bin/main.dart -o bin/main
        ''';
      } else {
        return '''
RUN dart pub get --offline
        ''';
      }
    }()}

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /minerva/bin/main /minerva/bin/

EXPOSE 8080

${() {
      if (dockerCompileType == 'AOT') {
        return 'CMD ["/minerva/bin/main"]';
      } else {
        return 'CMD ["dart", "/minerva/bin/main.dart"]';
      }
    }()}
''');
  }
}
