part of minerva_cli;

class FileLog {
  final FileLogType type;

  final String path;

  final DateTime modificationTime;

  FileLog(this.type, this.path, this.modificationTime);

  FileLog.fromJson(Map<String, dynamic> json)
      : type = FileLogType.values
            .firstWhere((element) => element.name == json['type']),
        path = json['path'],
        modificationTime = DateTime.parse(json['modificationTime']);

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'path': path,
        'modificationTime': modificationTime.toString()
      };
}
