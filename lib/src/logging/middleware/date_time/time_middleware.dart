part of minerva_logging;

class TimeMiddleware extends LoggerMiddleware {
  final DateTimeInserter _dateTimeInserter;

  TimeMiddleware({String pattern = '&time', String timePattern = 'Hms'})
      : _dateTimeInserter = DateTimeInserter(pattern, timePattern);

  @override
  Log handle(Log log) {
    var dateTimeNow = DateTime.now();

    var time = DateTime(
        0, 0, 0, dateTimeNow.hour, dateTimeNow.minute, dateTimeNow.second);

    log.template = _dateTimeInserter.insert(log.template, time);

    return log;
  }
}
