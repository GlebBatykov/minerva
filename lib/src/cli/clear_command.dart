part of minerva_cli;

class ClearCommand extends Command {
  @override
  String get name => 'clear';

  @override
  String get description => 'Clear project build files.';

  @override
  String get usage => '''
    -d  --directory points to the project directory.
  ''';

  ClearCommand() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
  }

  @override
  Future<void> run() async {
    var directory = argResults!['directory'];

    var buildDirectory = Directory.fromUri(Uri.directory('$directory/build'));

    var futures = <Future>[];

    if (await buildDirectory.exists()) {
      var size = 0;

      var fileCount = 0;

      var childrens = await buildDirectory.list(recursive: true).toList();

      childrens = childrens.whereType<File>().toList();

      for (var entity in childrens) {
        fileCount++;

        var stat = await entity.stat();

        size += stat.size;

        futures.add(entity.delete());
      }

      await Future.wait(futures);

      await buildDirectory.delete(recursive: true);

      print('Cleared files: $fileCount');
      print('Cleared size: $size byte');
    }
  }
}
