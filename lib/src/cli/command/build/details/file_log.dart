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

  FileLog.fromJson(Map<String, Object?> json)
      : type = FileLogType.values.firstWhere((e) => e.name == json['type']),
        path = json['path'] as String,
        modificationTime = DateTime.parse(json['modificationTime'] as String);

  Map<String, Object?> toJson() => {
        'type': type.name,
        'path': path,
        'modificationTime': modificationTime.toString(),
      };
}
