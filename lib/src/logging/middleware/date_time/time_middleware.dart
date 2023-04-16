part of minerva_logging;

class TimeMiddleware extends LoggerMiddleware {
  final DateTimeInserter _dateTimeInserter;

  const TimeMiddleware()
      : _dateTimeInserter = const DateTimeInserter('&time', 'Hms');

  @override
  Log handle(Log log) {
    final dateTimeNow = DateTime.now();

    final time = DateTime(
      0,
      0,
      0,
      dateTimeNow.hour,
      dateTimeNow.minute,
      dateTimeNow.second,
    );

    log.template = _dateTimeInserter.insert(log.template, time);

    return log;
  }
}
