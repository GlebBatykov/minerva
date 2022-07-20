part of minerva_isolate;

class IsolateHandler {
  final ReceivePort _receivePort = ReceivePort();

  late final Stream _receiveStream;

  final SendPort _supervisorPort;

  late IsolateContext _context;

  late IsolateTaskHandler _taskHandler;

  IsolateHandler(SendPort supervisorPort) : _supervisorPort = supervisorPort;

  void initialize() {
    _receiveStream = _receivePort.asBroadcastStream();

    _receiveStream.listen((message) {
      if (message is IsolateAction) {
        _handleIsolateAction(message);
      }
    });

    _supervisorPort.send(IsolateInitialized(_receivePort.sendPort));
  }

  void _handleIsolateAction(IsolateAction action) {
    if (action is IsolateStart) {
      _start(action);
    } else if (action is IsolateStop) {
      _stop();
    } else if (action is IsolatePause) {
      _pause();
    } else if (action is IsolateResume) {
      _resume();
    }
  }

  void _start(IsolateStart action) async {
    _context = IsolateContext(_receiveStream, _supervisorPort, action.data);

    _taskHandler = action.handler;

    await _taskHandler.onStart(_context);

    _supervisorPort.send(IsolateStarted());
  }

  void _stop() async {
    await _taskHandler.onStop(_context);

    _supervisorPort.send(IsolateStoped());
  }

  void _pause() async {
    await _taskHandler.onPause(_context);

    _supervisorPort.send(IsolatePaused());
  }

  void _resume() async {
    await _taskHandler.onResume(_context);

    _supervisorPort.send(IsolateResumed());
  }
}
