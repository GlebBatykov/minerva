part of minerva_logging;

class FileLoggerAgentData extends AgentData {
  FileLoggerAgentData({String name = 'file_logger', super.data})
      : super(name, FileLoggerAgent());
}
