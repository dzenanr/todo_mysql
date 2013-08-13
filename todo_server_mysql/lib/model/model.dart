part of todo_server_mysql;

class Task {
  String _title;
  bool _completed = false;
  DateTime _updated = new DateTime.now();

  TaskTable _taskTable;

  Task(this._title);

  Task.withTable(this._title, this._taskTable);

  Task.fromDb(Map value):
    _title = value['title'],
    _updated = DateTime.parse(value['updated']),
    _completed = value['completed'] != '0' ? true : false {
  }

  Task.fromJson(Map value):
    _title = value['title'],
    _updated = DateTime.parse(value['updated']),
    _completed = value['completed'] == 'true' ? true : false {
  }

  String get title => _title;
  set title(String title) {
    _title = title;
  }

  bool get completed => _completed;
  set completed(bool completed) {
    _completed = completed;
    if (_taskTable != null) {
      _taskTable.update(this);
    }
  }

  DateTime get updated => _updated;
  set updated(DateTime updated) {
    _updated = updated;
    if (_taskTable != null) {
      _taskTable.update(this);
    }
  }

  Map toDb() {
    return {
      'title': _title,
      'completed': _completed ? 1 : 0,
      'updated': _updated.toString()
    };
  }

  Map toJson() {
    return {
      'title': _title,
      'completed': _completed.toString(),
      'updated': _updated.toString()
    };
  }

  /**
   * Compares two tasks based on title.
   * If the result is less than 0 then the first task is less than the second,
   * if it is equal to 0 they are equal and
   * if the result is greater than 0 then the first is greater than the second.
   */
  int compareTo(Task task) {
    if (_title != null) {
      return _title.compareTo(task._title);
    }
  }

  /**
   * Returns a string that represents this task.
   */
  String toString() {
    return '${_title}';
  }

  display() {
    print(toString);
  }
}

class Tasks {
  var _tasks = new List<Task>();
  TaskTable _taskTable;

  Tasks();

  Tasks.withTable(this._taskTable);

  Tasks.fromJson(List<Map> jsonList) {
    for (var taskMap in jsonList) {
      add(new Task.fromJson(taskMap));
    }
  }

  Iterator<Task> get iterator => _tasks.iterator;

  int get length => _tasks.length;

  Tasks get completed {
    var completed = new Tasks();
    for (var task in _tasks) {
      if (task.completed) {
        completed.add(task);
      }
    }
    return completed;
  }

  Tasks get active {
    var active = new Tasks();
    for (var task in _tasks) {
      if (!task.completed) {
        active.add(task);
      }
    }
    return active;
  }


  List<Task> toList() => _tasks.toList();

  sort() {
    _tasks.sort((m,n) => m.compareTo(n));
  }

  bool contains(String title) {
    if (title != null) {
      for (var task in _tasks) {
        if (task.title == title) {
          return true;
        }
      }
    }
    return false;
  }

  Task find(String title) {
    if (title != null) {
      for (var task in _tasks) {
        if (task.title == title) {
          return task;
        }
      }
    }
  }

  load(Task task) {
    _tasks.add(task);
  }

  bool add(Task task) {
    if (contains(task._title)) {
      return false;
    } else {
      _tasks.add(task);
      if (_taskTable != null) {
        _taskTable.insert(task);
      }
      return true;
    }
  }

  bool remove(Task task) {
    bool removed = _tasks.remove(task);
    if (removed && _taskTable != null) {
      _taskTable.delete(task);
    }
    return removed;
  }

  Tasks copy() {
    var copy = new Tasks();
    for (var task in this) {
      copy.add(task);
    }
    return copy;
  }

  clear() => _tasks.clear();

  display() {
    _tasks.forEach((t) {
      t.display();
    });
  }

  List<Map> toJson() {
    var list = new List<Map>();
    for (var task in _tasks) {
      list.add(task.toJson());
    }
    return list;
  }

  String toJsonString() {
    return json.stringify(toJson());
  }
}
