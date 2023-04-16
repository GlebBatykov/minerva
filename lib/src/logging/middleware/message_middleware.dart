part of minerva_logging;

class MessageMiddleware extends LoggerMiddleware {
  const MessageMiddleware();

  @override
  Log handle(Log log) {
    log.template = log.template.replaceAll('&message', log.message);

    return log;
  }
}
