part of minerva_logging;

class LoggingSetting {
  bool isLevelEnabled(String loggerName, LogLevel level) {
    var logging = AppSetting.instance.logging;

    if (logging == null) {
      return true;
    }

    if (!logging.keys.contains(loggerName)) {
      return true;
    }

    var levels = logging[loggerName]!
        .cast<String>()
        .map((e) => LogLevel.values.firstWhere((element) => element.name == e))
        .toList();

    if (levels.contains(level)) {
      return true;
    } else {
      return false;
    }
  }
}
