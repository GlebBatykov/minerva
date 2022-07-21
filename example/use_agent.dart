import 'dart:io';

import 'package:minerva/minerva.dart';

//
class CounterAgent extends Agent {
  //
  int _counter = 0;

  //
  @override
  dynamic call(String action, Map<String, dynamic> data) {
    switch (action) {
      case ('get'):
        return _counter;
    }
  }

  //
  @override
  void cast(String action, Map<String, dynamic> data) {
    switch (action) {
      case ('increment'):
        _counter++;
        break;
      case ('decrement'):
        _counter--;
        break;
      case ('set'):
        _counter = data['value'];
        break;
      case ('add'):
        _counter += data['value'] as int;
        break;
      case ('minus'):
        _counter -= data['value'] as int;
    }
  }
}

void endpointsBuilder(Endpoints endpoints) {
  //
  endpoints.get('/counter', (context, request) async {
    var counter = await context.connectors['counter']!.call('get');

    return counter;
  });

  //
  endpoints.post('/counter', (context, request) async {
    var json = await request.json;

    context.connectors['counter']!.cast('set', data: json);
  });

  //
  endpoints.post('/counter/increment', (context, request) {
    context.connectors['counter']!.cast('increment');
  });

  //
  endpoints.post('/counter/decrement', (context, request) {
    context.connectors['counter']!.cast('decrement');
  });

  //
  endpoints.post('/counter/add', (context, request) async {
    var json = await request.json;

    context.connectors['counter']!.cast('add', data: json);
  });

  //
  endpoints.post('/counter/minus', (context, request) async {
    var json = await request.json;

    context.connectors['counter']!.cast('minus', data: json);
  });
}

void main() async {
  //
  var setting = ServerSetting('127.0.0.1', 5555);

  //
  var agents = [AgentData('counter', CounterAgent())];

  //
  await Minerva.bind(
      setting: setting,
      builder: endpointsBuilder,
      agents: agents,
      instance: Platform.numberOfProcessors);
}
