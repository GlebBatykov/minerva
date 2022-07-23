part of minerva_cli;

class FileLog {
  final String path;

  final DateTime modificationTime;

  FileLog(this.path, this.modificationTime);

  FileLog.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        modificationTime = DateTime.parse(json['modificationTime']);

  Map<String, dynamic> toJson() =>
      {'path': path, 'modificationTime': modificationTime.toString()};
}
