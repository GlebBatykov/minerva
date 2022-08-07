part of minerva_logging;

class FileLoggerAgentData extends AgentData {
  FileLoggerAgentData({String name = 'file_logger'})
      : super(name, FileLoggerAgent());
}
