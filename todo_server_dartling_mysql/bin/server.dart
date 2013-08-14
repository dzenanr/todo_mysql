import 'dart:io';
import 'dart:json' as json;

import 'package:dartling/dartling.dart';
import 'package:todo_server_dartling_mysql/todo_mvc.dart';

/*
 * Based on http://www.dartlang.org/articles/json-web-service/.
 * A web server that responds to GET and POST requests.
 * Use it at http://localhost:8080.
 */

const String HOST = "127.0.0.1"; // eg: localhost
const int PORT = 8080;

TodoDb db;

_integrateDataFromClient(List<Map> jsonList) {
  var clientTasks = new Tasks.fromJson(db.tasks.concept, jsonList);
  var serverTaskList = db.tasks.toList();
  for (var serverTask in serverTaskList) {
    var clientTask =
        clientTasks.singleWhereAttributeId('title', serverTask.title);
    if (clientTask == null) {
      new RemoveAction(db.session, db.tasks, serverTask).doit();
    }
  }
  for (var clientTask in clientTasks) {
    var serverTask =
        db.tasks.singleWhereAttributeId('title', clientTask.title);
    if (serverTask != null) {
      if (serverTask.updated.millisecondsSinceEpoch <
          clientTask.updated.millisecondsSinceEpoch) {
        new SetAttributeAction(
          db.session, serverTask, 'completed', clientTask.completed).doit();
      }
    } else {
      new AddAction(db.session, db.tasks, clientTask).doit();
    }
  }
}

start() {
  HttpServer.bind(HOST, PORT)
    .then((server) {
      server.listen((HttpRequest request) {
        switch (request.method) {
          case "GET":
            handleGet(request);
            break;
          case 'POST':
            handlePost(request);
            break;
          case 'OPTIONS':
            handleOptions(request);
            break;
          default: defaultHandler(request);
        }
      });
    })
    .catchError((e) => print(e))
    .whenComplete(() => print('Server bound to http://$HOST:$PORT'));
}

void handleGet(HttpRequest request) {
  HttpResponse res = request.response;
  //print('${request.method}: ${request.uri.path}');

  addCorsHeaders(res);
  res.headers.contentType =
      new ContentType("application", "json", charset: 'utf-8');
  List<Map> jsonList = db.tasks.toJson();
  String jsonString = json.stringify(jsonList);
  //print('JSON list in GET: ${jsonList}');
  res.write(jsonString);
  res.close();
}

void handlePost(HttpRequest request) {
  //print('${request.method}: ${request.uri.path}');
  request.listen((List<int> buffer) {
    var jsonString = new String.fromCharCodes(buffer);
    List<Map> jsonList = json.parse(jsonString);
    //print('JSON list in POST: ${jsonList}');
    _integrateDataFromClient(jsonList);
  },
  onError: print);
}

/**
 * Add Cross-site headers to enable accessing this server from pages
 * not served by this server
 *
 * See: http://www.html5rocks.com/en/tutorials/cors/
 * and http://enable-cors.org/server.html
 */
void addCorsHeaders(HttpResponse response) {
  response.headers.add('Access-Control-Allow-Origin', '*, ');
  response.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.headers.add('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
}

void handleOptions(HttpRequest request) {
  HttpResponse res = request.response;
  addCorsHeaders(res);
  print('${request.method}: ${request.uri.path}');
  res.statusCode = HttpStatus.NO_CONTENT;
  res.close();
}

void defaultHandler(HttpRequest request) {
  HttpResponse res = request.response;
  addCorsHeaders(res);
  res.statusCode = HttpStatus.NOT_FOUND;
  res.write('Not found: ${request.method}, ${request.uri.path}');
  res.close();
}

void main() {
  db = new TodoDb();
  db.open().then((_) {
    start();
  });
}


