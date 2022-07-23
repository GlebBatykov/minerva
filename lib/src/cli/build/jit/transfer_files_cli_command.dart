part of minerva_cli;

class TransferFilesCLICommand extends CLICommand<List<FileLog>> {
  final String projectPath;

  final String mode;

  late final String _packageName;

  TransferFilesCLICommand(this.projectPath, this.mode);

  @override
  Future<List<FileLog>> run() async {
    await _setPackageName();

    var files = await _getUsedFiles();

    var buildLibPath = '$projectPath/build/$mode/lib';

    var buildLibdirectory = Directory.fromUri(Uri.directory(buildLibPath));

    await buildLibdirectory.create(recursive: true);

    var futures = <Future>[];

    var fileLogs = <FileLog>[];

    for (var file in files) {
      var filePathSegment = file.pathStartingFrom('lib');

      var buildfilePath = '$buildLibPath/$filePathSegment';

      var buildFile = File.fromUri(Uri.file(buildfilePath));

      var entityStat = await file.stat();

      var modificationTime = entityStat.modified;

      fileLogs.add(FileLog(file.absolute.path, modificationTime));

      futures.add(buildFile.create(recursive: true).then(
          (value) async => buildFile.writeAsBytes(await file.readAsBytes())));
    }

    await Future.wait(futures);

    return fileLogs;
  }

  Future<void> _setPackageName() async {
    var pubSpecPath = '$projectPath/pubspec.yaml';

    var pubSpecFile = File.fromUri(Uri.file(pubSpecPath));

    if (!await pubSpecFile.exists()) {
      throw CLICommandException(
          message: 'File pubspec.yaml not exist by path: $pubSpecPath.');
    }

    String? packageNameLine;

    for (var line in await pubSpecFile.readAsLines()) {
      if (line.startsWith('name:')) {
        packageNameLine = line;
        break;
      }
    }

    if (packageNameLine == null) {
      throw CLICommandException(
          message: 'Can\'t find package name in pubspec.yaml file.');
    } else {
      try {
        var segments = packageNameLine.split(' ');

        segments.removeWhere((element) => element.isEmpty);

        _packageName = segments[1];
      } catch (_) {
        throw CLICommandException(
            message: 'Can\'t find package name in pubspec.yaml file.');
      }
    }
  }

  Future<List<File>> _getUsedFiles() async {
    var entryPointFilePath = '$projectPath/lib/main.dart';

    var entryPointFile = File.fromUri(Uri.file(entryPointFilePath));

    if (!await entryPointFile.exists()) {
      throw CLICommandException(
          message: 'Entry point not found by path: $entryPointFilePath.');
    }

    var files = <File>[entryPointFile];

    files.addAll(await _getRelatedFiles(entryPointFile));

    return files;
  }

  Future<List<File>> _getRelatedFiles(File file) async {
    var links = await _getLinks(file);

    var files = <File>[];

    for (var link in links) {
      late String path;

      if (!isAbsolute(link)) {
        path = normalize(absolute(file.parent.path, link));
      } else {
        path = link;
      }

      var linkFile = File.fromUri(Uri.file(path));

      if (await linkFile.exists()) {
        files.add(linkFile);

        var relatedFiles = await _getRelatedFiles(linkFile);

        for (var relatedFile in relatedFiles) {
          if (!_isContainsFile(files, relatedFile)) {
            files.add(relatedFile);
          }
        }
      }
    }

    return files;
  }

  bool _isContainsFile(List<File> files, File file) {
    return files.map((e) => e.path).contains(file.path);
  }

  Future<List<String>> _getLinks(File file) async {
    var lines = await file.readAsLines();

    var links = <String>[];

    for (var line in lines) {
      var segments = line.split(' ');

      segments.removeWhere((element) => element.isEmpty);

      if (_isLink(segments)) {
        var link = segments[1];

        if (!_isPackageLink(link)) {
          link = link.substring(1, link.length - 2);

          links.add(link);
        } else if (link.startsWith('\'package:$_packageName')) {
          link = link.substring(9 + _packageName.length + 1, link.length - 2);

          link = '$projectPath/lib/$link';

          links.add(link);
        }
      }
    }

    return links;
  }

  bool _isLink(List<String> segments) {
    if (segments.length < 2) {
      return false;
    }

    return segments.first == 'import' && _isFilePath(segments[1]) ||
        (segments.first == 'part' && _isFilePath(segments[1]));
  }

  bool _isFilePath(String string) {
    if (string.length < 3) {
      return false;
    }

    if (string[0] != '\'' && string[string.length - 1] != '\'') {
      return false;
    }

    return true;
  }

  bool _isPackageLink(String link) {
    return link.startsWith('\'package:');
  }
}
