part of todo_server_mysql;

class TodoDb {
  TaskTable _taskTable;

  TaskTable get taskTable => _taskTable;

  ConnectionPool getPool(OptionsFile options) {
    String user = options.getString('user');
    String password = options.getString('password');
    int port = options.getInt('port', 3306);
    String db = options.getString('db');
    String host = options.getString('host', 'localhost');
    return new ConnectionPool(
      host: host, port: port, user: user, password: password, db: db);
  }

  Future open() {
    var pool = getPool(new OptionsFile('connection.options'));
    _taskTable = new TaskTable(pool);
    return _taskTable.load();
  }
}

class TaskTable {
  final ConnectionPool _pool;
  Tasks _tasks;

  TaskTable(this._pool) {
    _tasks = new Tasks.withTable(this);
  }

  Tasks get tasks => _tasks;
  bool get isEmpty => tasks.length == 0;

  Future load() {
    Completer completer = new Completer();
    _pool.query(
      'select t.title, t.completed, t.updated '
      'from task t '
    ).then((rows) {
      var taskMap;
      rows.stream.listen((row) {
        taskMap = {
          'title'    : '${row[0]}',
          'completed': '${row[1]}',
          'updated'  : '${row[2]}'
        };
        var task = new Task.fromDb(taskMap);
        tasks.load(task);
      },
        onError: (e) => print('loading data error: $e'),
        onDone: () {
          completer.complete();
          print('all tasks loaded');
        }
      );
    });
    return completer.future;
  }

  Future<Task> insert(Task task) {
    var completer = new Completer();
    var taskMap = task.toDb();
    _pool.prepare(
      'insert into task (title, completed, updated) values (?, ?, ?)'
    ).then((query) {
      print('prepared query insert into task');
      query[0] = taskMap['title'];
      query[1] = taskMap['completed'];
      query[2] = taskMap['updated'];
      return query.execute();
    }).then((_) {
      print("executed query insert into task");
      completer.complete();
    }).catchError(print);
    return completer.future;
  }

  Future<Task> update(Task task) {
    var completer = new Completer();
    var taskMap = task.toDb();
    _pool.prepare(
      'update task set completed = ?, updated = ? where title = ?'
    ).then((query) {
      print('prepared query update task');
      query[0] = taskMap['completed'];
      query[1] = taskMap['updated'];
      query[2] = taskMap['title'];
      return query.execute();
    }).then((_) {
      print("executed query update task");
      completer.complete();
    }).catchError(print);
    return completer.future;
  }

  Future<Task> delete(Task task) {
    var completer = new Completer();
    var taskMap = task.toDb();
    _pool.prepare(
      'delete from task where title = ?'
    ).then((query) {
      print('prepared query delete from task');
      query[0] = taskMap['title'];
      return query.execute();
    }).then((_) {
      print("executed query delete from task");
      completer.complete();
    }).catchError(print);
    return completer.future;
  }
}

