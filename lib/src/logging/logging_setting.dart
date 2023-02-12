part of minerva_logging;

class LoggingSetting {
  bool isLevelEnabled(String loggerName, LogLevel level) {
    final logging = AppSetting.instance.logging;

    if (logging == null) {
      return true;
    }

    if (!logging.keys.contains(loggerName)) {
      return true;
    }

    final levels =
        logging[loggerName]!.map((e) => LogLevel.fromName(e)).toList();

    if (levels.contains(level)) {
      return true;
    } else {
      return false;
    }
  }
}
