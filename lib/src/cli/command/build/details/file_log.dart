part of minerva_cli;

class FileLog {
  final FileLogType type;

  final String path;

  final DateTime modificationTime;

  FileLog({
    required this.type,
    required this.path,
    required this.modificationTime,
  });

  FileLog.fromJson(Map<String, dynamic> json)
      : type = FileLogType.values.firstWhere((e) => e.name == json['type']),
        path = json['path'],
        modificationTime = DateTime.parse(json['modificationTime']);

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'path': path,
        'modificationTime': modificationTime.toString(),
      };
}
