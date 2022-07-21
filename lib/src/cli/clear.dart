part of minerva_cli;

class Clear extends Command {
  @override
  String get name => 'clear';

  @override
  String get description => 'Clear project build files.';

  @override
  String get usage => '''
    -d  --directory points to the project directory.
  ''';

  Clear() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
  }

  @override
  Future<void> run() async {
    var directory = argResults!['directory'];

    var buildDirectory = Directory.fromUri(Uri.directory('$directory/build'));

    var futures = <Future>[];

    if (await buildDirectory.exists()) {
      for (var entity in await buildDirectory.list().toList()) {
        futures.add(entity.delete(recursive: true));
      }
    }

    await Future.wait(futures);
  }
}
