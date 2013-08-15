part of todo_mvc;

class TodoDb implements ActionReactionApi {
  TodoModels domain;
  DomainSession session;
  MvcEntries model;
  Tasks tasks;

  ConnectionPool pool;
  TaskTable taskTable;

  TodoDb() {
    var repo = new TodoRepo();
    domain = repo.getDomainModels('Todo');
    domain.startActionReaction(this);
    session = domain.newSession();
    model = domain.getModelEntries('Mvc');
    tasks = model.tasks;

    pool = getPool(new OptionsFile('connection.options'));
    taskTable = new TaskTable(this);
  }

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
    return taskTable.load();
  }

  react(ActionApi action) {
    if (action is AddAction) {
      taskTable.insert(action.entity);
    } else if (action is RemoveAction) {
      taskTable.delete(action.entity);
    } else if (action is SetAttributeAction) {
      taskTable.update(action.entity);
    }
  }
}

class TaskTable {
  TodoDb db;

  TaskTable(this.db);

  Future load() {
    Completer completer = new Completer();
    db.pool.query(
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
        var task = new Task.fromDb(db.tasks.concept, taskMap);
        db.tasks.add(task);
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
    db.pool.prepare(
      'insert into task (title, completed, updated) values (?, ?, ?)'
    ).then((query) {
      //print('prepared query insert into task: ${task.title}');
      query[0] = taskMap['title'];;
      query[1] = taskMap['completed'];
      query[2] = taskMap['updated'];
      return query.execute();
    }).then((_) {
      print('executed query insert into task: ${task.title}');
      completer.complete();
    });
    return completer.future;
  }

  Future<Task> delete(Task task) {
    var completer = new Completer();
    var taskMap = task.toDb();
    db.pool.prepare(
      'delete from task where title = ?'
    ).then((query) {
      //print('prepared query delete from task: ${task.title}');
      query[0] = taskMap['title'];;
      return query.execute();
    }).then((_) {
      print('executed query delete from task: ${task.title}');
      completer.complete();
    });
    return completer.future;
  }

  Future<Task> update(Task task) {
    var completer = new Completer();
    var taskMap = task.toDb();
    db.pool.prepare(
      'update task set completed = ?, updated = ? where title = ?'
    ).then((query) {
      //print('prepared query update task: ${task.title}');
      query[0] = taskMap['completed'];
      query[1] = taskMap['updated'];
      query[2] = taskMap['title'];
      return query.execute();
    }).then((_) {
      print('executed query update task: ${task.title}');
      completer.complete();
    });
    return completer.future;
  }
}

