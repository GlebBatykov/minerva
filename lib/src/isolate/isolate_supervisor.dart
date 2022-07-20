part of minerva_isolate;

class IsolateSupervisor {
  final StreamController _messageController = StreamController.broadcast();

  final StreamController<IsolateEvent> _eventController =
      StreamController.broadcast();

  final ReceivePort _receivePort = ReceivePort();

  late final Stream _receiveStream;

  Isolate? _isolate;

  SendPort? _isolatePort;

  Capability? _resumeCapability;

  bool _isInitialized = false;

  bool _isStarted = false;

  bool _isPaused = false;

  bool _isDisposed = false;

  bool get isInitialized => _isInitialized;

  bool get isStarted => _isStarted;

  bool get isPaused => _isPaused;

  bool get isDisposed => _isDisposed;

  Stream get messages => _messageController.stream;

  SendPort? get isolatePort => _isolatePort;

  IsolateSupervisor() {
    _receiveStream = _receivePort.asBroadcastStream();

    _receiveStream.listen(_handleMessage);
  }

  void _handleMessage(dynamic message) {
    if (message is IsolateEvent) {
      _eventController.sink.add(message);
    } else {
      _messageController.sink.add(message);
    }
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      var spawnMessage = IsolateSpawnMessage(_receivePort.sendPort);

      _isolate = await Isolate.spawn<IsolateSpawnMessage>(
          _isolateEntryPoint, spawnMessage);

      var event = await _eventController.stream
              .firstWhere((element) => element is IsolateInitialized)
          as IsolateInitialized;

      _isolatePort = event.isolatePort;

      _isInitialized = true;
    }
  }

  static void _isolateEntryPoint(IsolateSpawnMessage message) {
    var handler = IsolateHandler(message.supervisorPort);

    handler.initialize();
  }

  void send(dynamic message) {
    _isolatePort?.send(message);
  }

  Future<void> start(IsolateTaskHandler handler,
      [Map<String, dynamic> data = const {}]) async {
    if (_isInitialized) {
      _isolatePort!.send(IsolateStart(handler, data));

      await _eventController.stream
          .firstWhere((element) => element is IsolateStarted);

      _isStarted = true;
    }
  }

  Future<void> stop() async {
    if (_isStarted) {
      _isolatePort!.send(IsolateStop());

      await _eventController.stream
          .firstWhere((element) => element is IsolateStoped);

      _isStarted = false;
    }
  }

  Future<void> pause() async {
    if (_isInitialized && !_isPaused) {
      _isolatePort!.send(IsolatePause());

      await _eventController.stream
          .firstWhere((element) => element is IsolatePaused);

      _resumeCapability = _isolate!.pause(_isolate!.pauseCapability);

      _isPaused = true;
    }
  }

  Future<void> resume() async {
    if (_isInitialized && _isPaused) {
      _isolate!.resume(_resumeCapability!);

      _isolatePort!.send(IsolateResume());

      await _eventController.stream
          .firstWhere((element) => element is IsolateResumed);

      _isPaused = false;
    }
  }

  Future<void> kill() async {
    if (_isInitialized) {
      if (_isStarted) {
        await stop();

        _isolate!.kill(priority: Isolate.immediate);

        _isolate = null;

        _isInitialized = false;
      }
    }
  }

  Future<void> dispose() async {
    await kill();

    await _eventController.close();
    await _messageController.close();

    _isDisposed = true;
    _isStarted = false;
  }
}
