part of minerva_logging;

class DateMiddleware extends LoggerMiddleware {
  final DateTimeInserter _dateTimeInserter;

  const DateMiddleware()
      : _dateTimeInserter = const DateTimeInserter('&date', 'yMd');

  @override
  Log handle(Log log) {
    final dateTimeNow = DateTime.now();

    final time = DateTime(
      dateTimeNow.year,
      dateTimeNow.month,
      dateTimeNow.day,
      0,
      0,
      0,
    );

    log.template = _dateTimeInserter.insert(log.template, time);

    return log;
  }
}
