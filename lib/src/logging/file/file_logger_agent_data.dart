part of minerva_logging;

class FileLoggerAgentData extends AgentData {
  FileLoggerAgentData(
      {String name = 'file_logger', String logPath = '~/log/log.log'})
      : super(name, FileLoggerAgent(), data: {'logPath': logPath});
}
