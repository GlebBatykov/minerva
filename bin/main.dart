// import 'package:minerva/minerva.dart';

// class CounterAgent extends Agent {
//   int _counter = 0;

//   @override
//   dynamic call(String action, Map<String, dynamic> data) {
//     switch (action) {
//       case ('get'):
//         return _counter;
//     }
//   }

//   @override
//   void cast(String action, Map<String, dynamic> data) {
//     switch (action) {
//       case ('add'):
//         _counter += data['value']! as int;
//         break;
//       case ('minus'):
//         _counter -= data['value']! as int;
//         break;
//       case ('set'):
//         _counter = data['value'];
//         break;
//       case ('increment'):
//         _counter++;
//         break;
//       case ('decrement'):
//         _counter--;
//         break;
//     }
//   }
// }

// void serverBuilder(ServerContext context) {
//   context.store['message'] = 'Hello, world!';
// }

// void endpointsBuilder(Endpoints endpoints) {
//   endpoints.get('/hello', (context, request) {
//     var message = context.store.get('message');

//     return OkResult(body: message);
//   });

//   endpoints.get('/counter', (context, request) async {
//     var agent = context.connectors['counter']!;

//     var counter = await agent.call<int>('get');

//     return OkResult(body: counter);
//   });

//   endpoints.post('/counter/increment', (context, request) async {
//     var agent = context.connectors['counter']!;

//     agent.cast('increment');

//     return OkResult();
//   });

//   endpoints.post('/counter/decrement', (context, request) {
//     var agent = context.connectors['counter']!;

//     agent.cast('decrement');

//     return OkResult();
//   });

//   endpoints.post('/counter/add', (context, request) async {
//     var agent = context.connectors['counter']!;

//     agent.cast('add', data: await request.json);

//     return OkResult();
//   });

//   endpoints.post('/counter/minus', (context, request) async {
//     var agent = context.connectors['counter']!;

//     agent.cast('minus', data: await request.json);

//     return OkResult();
//   });
// }

// bool verifyToken(ServerContext context, String token) {
//   return true;
// }

// List<String> getRoles(ServerContext context, String token) {
//   return ['User'];
// }

// void main() async {
//   var middlewares = [
//     AuthMiddleware(tokenVerify: verifyToken, getRoles: getRoles),
//     EndpointMiddleware()
//   ];

//   var setting = ServerSetting('127.0.0.1', 5000,
//       builder: serverBuilder, middlewares: middlewares);

//   var agents = [AgentData('counter', CounterAgent())];

//   await Minerva.bind(
//       setting: setting,
//       builder: endpointsBuilder,
//       agents: agents,
//       instance: 12);
// }

// import 'dart:io';

// import 'package:minerva/minerva.dart';

// void serverBuilder(ServerContext context) {
//   context.store['message'] = 'Hello, world!';

//   context.store['directory'] = '/home/darkartes';
// }

// void endpointsBuilder(Endpoints endpoints) {
//   endpoints.get('/hello', (context, request) {
//     var message = context.store['message'];

//     return OkResult(body: message);
//   });

//   endpoints.get('/file',
//       (context, request) => FilePathContentResult('/home/darkartes/test.txt'));

//   endpoints.get('/downloadFile',
//       (context, request) => FilePathResult('/home/darkartes/test.txt'));

//   endpoints.get('/someFile', (context, request) async {
//     var fileName = request.requestedUri.queryParameters['fileName'];

//     if (fileName != null) {
//       var directory = context.store['directory']!;

//       var file = File.fromUri(Uri.file('$directory/$fileName'));

//       if (await file.exists()) {
//         return FileResult(file, name: fileName);
//       } else {
//         return NotFoundResult();
//       }
//     }

//     return NotFoundResult();
//   });
// }

// void main() async {
//   var setting = ServerSetting('127.0.0.1', 5000, builder: serverBuilder);

//   await Minerva.bind(setting: setting, builder: endpointsBuilder, instance: 12);
// }

// import 'package:minerva/minerva.dart';

// void serverBuilder(ServerContext context) {
//   context.store['message'] = 'Hello, world!';
// }

// void endpointsBuilder(Endpoints endpoints) {
//   endpoints.ws('/hello', (context, socket) async {
//     var message = context.store['message'];

//     socket.add(message);

//     await socket.close();
//   });
// }

// void main() async {
//   var setting = ServerSetting('127.0.0.1', 5000, builder: serverBuilder);

//   await Minerva.bind(setting: setting, builder: endpointsBuilder);
// }

import 'package:minerva/minerva.dart';

void serverBuilder(ServerContext context) {}

void endpointsBuilder(Endpoints endpoints) {
  endpoints.get('/hello', (context, request) {
    throw FormatException();
  });
}

void main() async {
  var setting = ServerSetting('127.0.0.1', 5000, builder: serverBuilder);

  await Minerva.bind(setting: setting, builder: endpointsBuilder);
}
