part of todo_mvc;

// lib/todo/mvc/tasks.dart

class Task extends TaskGen {

  Task(Concept concept) : super(concept);

  Task.withId(Concept concept, String title) :
    super.withId(concept, title);

  // begin: added by hand
  Task.fromDb(Concept concept, Map value): super(concept) {
    title = value['title'];
    completed = value['completed'] != '0' ? true : false;
    updated = DateTime.parse(value['updated']);
  }

  Task.fromJson(Concept concept, Map value): super(concept) {
    title = value['title'];
    completed = value['completed'] == 'true' ? true : false;
    updated = DateTime.parse(value['updated']);
  }

  bool get left => !completed;
  bool get generate =>
      title.contains('generate') ? true : false;

  Map toDb() {
    return {
      'title': title,
      'completed': completed ? 1 : 0,
      'updated': updated.toString()
    };
  }

  bool preSetAttribute(String name, Object value) {
    bool validation = super.preSetAttribute(name, value);
    if (name == 'title') {
      String title = value;
      if (validation) {
        validation = title.trim() != '';
        if (!validation) {
          var error = new ValidationError('pre');
          error.message = 'The title should not be empty.';
          errors.add(error);
        }
      }
      if (validation) {
        validation = title.length <= 64;
        if (!validation) {
          var error = new ValidationError('pre');
          error.message =
              'The "${title}" title should not be longer than 64 characters.';
              errors.add(error);
        }
      }
    }
    return validation;
  }
  // end: added by hand
}

class Tasks extends TasksGen {

  Tasks(Concept concept) : super(concept);

  // begin: added by hand
  Tasks.fromJson(Concept concept, List<Map> jsonList): super(concept) {
    for (var taskMap in jsonList) {
      add(new Task.fromJson(concept, taskMap));
    }
  }

  Tasks get completed => selectWhere((task) => task.completed);
  Tasks get left => selectWhere((task) => task.left);

  Task findByTitleId(String title) {
    return singleWhereId(new Id(concept)..setAttribute('title', title));
  }
  // end: added by hand
}
