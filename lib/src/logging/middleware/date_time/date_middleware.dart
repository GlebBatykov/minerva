part of minerva_logging;

class DateMiddleware extends LoggerMiddleware {
  final DateTimeInserter _dateTimeInserter;

  DateMiddleware({String pattern = '&date', String timePattern = 'yMd'})
      : _dateTimeInserter = DateTimeInserter(pattern, timePattern);

  @override
  Log handle(Log log) {
    var dateTimeNow = DateTime.now();

    var time =
        DateTime(dateTimeNow.year, dateTimeNow.month, dateTimeNow.day, 0, 0, 0);

    log.template = _dateTimeInserter.insert(log.template, time);

    return log;
  }
}
