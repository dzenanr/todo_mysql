part of todo_mvc;

// lib/gen/todo/mvc/tasks.dart

abstract class TaskGen extends ConceptEntity<Task> {

  TaskGen(Concept concept) : super.of(concept);

  TaskGen.withId(Concept concept, String title) : super.of(concept) {
    setAttribute("title", title);
  }

  String get title => getAttribute("title");
  set title(String a) => setAttribute("title", a);

  bool get completed => getAttribute("completed");
  set completed(bool a) => setAttribute("completed", a);

  DateTime get updated => getAttribute("updated");
  set updated(DateTime a) => setAttribute("updated", a);

  Task newEntity() => new Task(concept);
  Tasks newEntities() => new Tasks(concept);

  int titleCompareTo(Task other) {
    return title.compareTo(other.title);
  }

}

abstract class TasksGen extends Entities<Task> {

  TasksGen(Concept concept) : super.of(concept);

  Tasks newEntities() => new Tasks(concept);
  Task newEntity() => new Task(concept);

}