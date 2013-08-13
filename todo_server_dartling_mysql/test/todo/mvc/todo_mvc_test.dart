// test/todo/mvc/todo_mvc_test.dart

import "package:unittest/unittest.dart";
import "package:dartling/dartling.dart";
import 'package:todo_server_dartling_mysql/todo_mvc.dart';

testTodoMvc(Repo repo, String domainCode, String modelCode) {
  TodoModels domainModels;
  MvcEntries modelEntries;
  DomainSession domainSession;
  Tasks tasks;
  int tasksLength = 0;
  Concept taskConcept;
  group("Testing ${domainCode}.${modelCode}", () {
    setUp(() {
      domainModels = repo.getDomainModels(domainCode);
      domainSession = domainModels.newSession();
      modelEntries = domainModels.getModelEntries(modelCode);
      expect(modelEntries, isNotNull);
      tasks = modelEntries.tasks;
      expect(tasks.length, equals(tasksLength));
      taskConcept = tasks.concept;
      expect(taskConcept, isNotNull);
      expect(taskConcept.attributes.toList(), isNot(isEmpty));

      var design = new Task(taskConcept);
      expect(design, isNotNull);
      design.title = 'design a model';
      tasks.add(design);
      expect(tasks.length, equals(++tasksLength));

      var json = new Task(taskConcept);
      json.title = 'generate json from the model';
      tasks.add(json);
      expect(tasks.length, equals(++tasksLength));

      var generate = new Task(taskConcept);
      generate.title = 'generate code from the json document';
      tasks.add(generate);
      expect(tasks.length, equals(++tasksLength));
    });
    tearDown(() {
      tasks.clear();
      expect(tasks.isEmpty, isTrue);
      tasksLength = 0;
    });
    test('Empty Entries Test', () {
      modelEntries.clear();
      expect(modelEntries.isEmpty, isTrue);
    });

    test('From Tasks to JSON', () {
      var json = tasks.toJson();
      expect(json, isNotNull);
      print(json);
    });
    test('From Task Model to JSON', () {
      var json = modelEntries.toJson();
      expect(json, isNotNull);
      modelEntries.displayJson();
    });
    test('From JSON to Task Model', () {
      tasks.clear();
      expect(tasks.isEmpty, isTrue);
      modelEntries.fromJsonToData();
      expect(tasks.isEmpty, isFalse);
      tasks.display(title:'From JSON to Task Model');
    });

    test('Add Task Required Title Error', () {
      var task = new Task(taskConcept);
      expect(taskConcept, isNotNull);
      var added = tasks.add(task);
      expect(added, isFalse);
      expect(tasks.length, equals(tasksLength));
      expect(tasks.errors.length, equals(1));
      expect(tasks.errors.toList()[0].category, equals('required'));
      tasks.errors.display(title:'Add Task Required Title Error');
    });
    test('Add Task Unique Error', () {
      var title = 'write a blog entry about dartling and DWT';
      var task = new Task.withId(taskConcept, title);
      expect(task, isNotNull);
      var added = tasks.add(task);
      expect(added, isTrue);
      added = tasks.add(task);
      expect(added, isFalse);
      expect(tasks.errors.length, equals(1));
      expect(tasks.errors.toList()[0].category, equals('unique'));
      tasks.errors.display(title:'Add Task Unique Error');
    });
    test('Add Task Pre Validation Empty Title Error', () {
      var task = new Task(taskConcept);
      expect(task, isNotNull);
      task.title = ' ';
      expect(task.errors, hasLength(1));
      expect(task.errors.toList()[0].category, equals('pre'));
      task.errors.display(title:'Set Task Title Pre Validation Empty Error');
      var added = tasks.add(task);
      expect(added, isFalse);
      expect(tasks.errors, hasLength(1));
      expect(tasks.errors.toList()[0].category, equals('required'));
      tasks.errors.display(title:'Add Task Pre Validation Empty Title Error');
    });
    test('Add Task Pre Validation Too Long Title Error', () {
      var task = new Task(taskConcept);
      expect(task, isNotNull);
      task.title =
          'A new task with a long name, longer than sixty four characters, is not be accepted';
      expect(task.errors, hasLength(1));
      expect(task.errors.toList()[0].category, equals('pre'));
      task.errors.display(title:'Set Task Title Pre Validation Too Long Error');
      var added = tasks.add(task);
      expect(added, isFalse);
      expect(tasks.errors, hasLength(1));
      expect(tasks.errors.toList()[0].category, equals('required'));
      tasks.errors.display(title:'Add Task Pre Validation Too Long Title Error');
    });

    test('Find Task by New Oid', () {
      var oid = new Oid.ts(1345648254063);
      var task = tasks.singleWhereOid(oid);
      expect(task, isNull);
    });
    test('Find Task by Attribute', () {
      var title = 'generate json from the model';
      var task = tasks.firstWhereAttribute('title', title);
      expect(task, isNotNull);
      expect(task.title, equals(title));
    });
    test('Find Task by Id', () {
      Id id = new Id(taskConcept);
      expect(id.length, equals(1));
      var searchTitle = 'design a model';
      id.setAttribute('title', searchTitle);
      var task = tasks.singleWhereId(id);
      expect(task, isNotNull);
      expect(task.title, equals(searchTitle));
    });
    test('Find Task by Attribute Id', () {
      var searchTitle = 'design a model';
      var task = tasks.singleWhereAttributeId('title', searchTitle);
      expect(task, isNotNull);
      expect(task.title, equals(searchTitle));
    });
    test('Find Project by Name Id', () {
      var searchTitle = 'design a model';
      // findByTitleId is a specific method
      var task = tasks.findByTitleId(searchTitle);
      expect(task, isNotNull);
      expect(task.title, equals(searchTitle));
    });
    test('Random Task', () {
      var task1 = tasks.random();
      expect(task1, isNotNull);
      task1.display(prefix:'random 1');
      var task2 = tasks.random();
      expect(task2, isNotNull);
      task2.display(prefix:'random 2');
    });

    test('Select Tasks by Function', () {
      Tasks generateTasks = tasks.selectWhere((task) => task.generate);
      expect(generateTasks.isEmpty, isFalse);
      expect(generateTasks.length, equals(2));

      generateTasks.display(title:'Select Tasks by Function');
    });
    test('Select Tasks by Function then Add', () {
      var generateTasks = tasks.selectWhere((task) => task.generate);
      expect(generateTasks.isEmpty, isFalse);
      expect(generateTasks.source.isEmpty, isFalse);

      var programmingTask = new Task(taskConcept);
      programmingTask.title = 'dartling programming';
      var added = generateTasks.add(programmingTask);
      expect(added, isTrue);

      generateTasks.display(title:'Select Tasks by Function then Add');
      tasks.display(title:'All Tasks');
    });
    test('Select Tasks by Function then Remove', () {
      var generateTasks = tasks.selectWhere((task) => task.generate);
      expect(generateTasks.isEmpty, isFalse);
      expect(generateTasks.source.isEmpty, isFalse);

      var title = 'generate json from the model';
      var task = generateTasks.firstWhereAttribute('title', title);
      expect(task, isNotNull);
      expect(task.title, equals(title));
      var generatelength = generateTasks.length;
      generateTasks.remove(task);
      expect(generateTasks.length, equals(--generatelength));
      expect(tasks.length, equals(--tasksLength));
    });
    test('Sort Tasks by Title', () {
      var length = tasks.length;
      tasks.sort();
      expect(tasks.isEmpty, isFalse);
      expect(tasks.length, equals(length));
      tasks.display(title:'Sort Tasks by Title');
    });
    test('Order Tasks by Title', () {
      var length = tasks.length;
      var sortedTasks = tasks.order();
      expect(sortedTasks.isEmpty, isFalse);
      expect(sortedTasks.length, equals(length));
      sortedTasks.display(title:'Order Tasks by Title');
    });

    test('Find Task then Set Oid with Failure', () {
      var title = 'generate json from the model';
      var task = tasks.firstWhereAttribute('title', title);
      expect(task, isNotNull);
      expect(() => task.oid = new Oid.ts(1345648254063), throws);
    });
    test('Find Task then Set Oid with Success', () {
      var title = 'generate json from the model';
      var task = tasks.firstWhereAttribute('title', title);
      expect(task, isNotNull);
      task.display(prefix:'before oid set: ');
      task.concept.updateOid = true;
      task.oid = new Oid.ts(1345648254063);
      task.concept.updateOid = false;
      task.display(prefix:'after oid set: ');
    });

    test('Update New Task Title with Failure', () {
      var task = new Task(taskConcept);
      expect(task, isNotNull);
      task.title = 'writing a tutorial on Dartling';
      tasks.add(task);
      expect(tasks.length, equals(++tasksLength));
      // The id cannot be updated.
      expect(() => task.title = 'writing a paper on Dartling', throws);
    });
    test('Update New Task Title Id with Success', () {
      var task = new Task(taskConcept);
      expect(task, isNotNull);
      task.title = 'writing a tutorial on Dartling';
      tasks.add(task);
      expect(tasks.length, equals(++tasksLength));
      var titleAttribute = task.concept.attributes.singleWhereCode('title');
      expect(titleAttribute.update, isFalse);
      titleAttribute.update = true;
      // The id can be updated but its index is not maintained (not recommended).
      task.title = 'writing a paper on Dartling';
      titleAttribute.update = false;
    });
    test('Update New Task Title with Success', () {
      var task = new Task(taskConcept);
      expect(task, isNotNull);
      task.title = 'writing a tutorial on Dartling';
      tasks.add(task);
      expect(tasks.length, equals(++tasksLength));

      var taskCopy = task.copy();
      var titleAttribute = task.concept.attributes.singleWhereCode('title');
      expect(titleAttribute.update, isFalse);
      titleAttribute.update = true;
      var newTitle = 'writing a paper on Dartling';
      taskCopy.title = newTitle;
      expect(taskCopy.title, equals(newTitle));
      // The id can be updated and its index is maintained.
      var updated = tasks.update(task, taskCopy);
      expect(updated, isTrue);
      titleAttribute.update = false;

      var dartlingPaper = tasks.singleWhereAttributeId('title', newTitle);
      expect(dartlingPaper, isNotNull);
      expect(dartlingPaper.title, equals(newTitle));
    });
    test('Update New Task Oid with Success', () {
      var task = new Task(taskConcept);
      expect(task, isNotNull);
      task.title = 'writing a tutorial on Dartling';
      tasks.add(task);
      expect(tasks.length, equals(++tasksLength));

      var copiedTask = task.copy();
      copiedTask.concept.updateOid = true;
      copiedTask.oid = new Oid.ts(1345648254063);
      copiedTask.concept.updateOid = false;
      // Entities.update can only be used if oid, code or id set.
      tasks.update(task, copiedTask);
      var foundTask = tasks.firstWhereAttribute('title', task.title);
      expect(foundTask, isNotNull);
      expect(foundTask.oid, equals(copiedTask.oid));
      // Entities.update removes the before update entity and
      // adds the after update entity,
      // in order to update oid, code and id entity maps.
      expect(task.oid, isNot(equals(copiedTask.oid)));
    });
    test('Find Task by Attribute then Examine Code and Id', () {
      var title = 'generate json from the model';
      var task = tasks.firstWhereAttribute('title', title);
      expect(task, isNotNull);
      expect(task.code, isNull);
      expect(task.id, isNotNull);
    });

    test('Add Task Undo and Redo', () {
      var task = new Task(taskConcept);
      expect(task, isNotNull);
      task.title = 'writing a tutorial on Dartling';

      var action = new AddAction(domainSession, tasks, task);
      action.doit();
      expect(tasks.length, equals(++tasksLength));

      action.undo();
      expect(tasks.length, equals(--tasksLength));

      action.redo();
      expect(tasks.length, equals(++tasksLength));
    });
    test('Remove Task Undo and Redo', () {
      var title = 'generate json from the model';
      var task = tasks.firstWhereAttribute('title', title);
      expect(task, isNotNull);

      var action = new RemoveAction(domainSession, tasks, task);
      action.doit();
      expect(tasks.length, equals(--tasksLength));

      action.undo();
      expect(tasks.length, equals(++tasksLength));

      action.redo();
      expect(tasks.length, equals(--tasksLength));
    });
    test('Add Task Undo and Redo with Session', () {
      var task = new Task(taskConcept);
      expect(task, isNotNull);
      task.title = 'writing a tutorial on Dartling';

      var action = new AddAction(domainSession, tasks, task);
      action.doit();
      expect(tasks.length, equals(++tasksLength));

      domainSession.past.undo();
      expect(tasks.length, equals(--tasksLength));

      domainSession.past.redo();
      expect(tasks.length, equals(++tasksLength));
    });
    test('Undo and Redo Update Task Title', () {
      var title = 'generate json from the model';
      var task = tasks.firstWhereAttribute('title', title);
      expect(task, isNotNull);
      expect(task.title, equals(title));

      var titleAttribute = task.concept.attributes.singleWhereCode('title');
      expect(titleAttribute.update, isFalse);
      titleAttribute.update = true;

      var newTitle = 'generate from model to json';
      // The id can be updated but its index is not maintained (not recommended).
      var action = new SetAttributeAction(domainSession, task, 'title', newTitle);
      action.doit();
      expect(action.done, isTrue);

      domainSession.past.undo();
      expect(task.title, equals(action.before));

      domainSession.past.redo();
      expect(task.title, equals(action.after));

      titleAttribute.update = false;
    });
    test('Undo and Redo Transaction with Two Adds', () {
      var task1 = new Task(taskConcept);
      task1.title = 'data modeling';
      var action1 = new AddAction(domainSession, tasks, task1);

      var task2 = new Task(taskConcept);
      task2.title = 'database design';
      var action2 = new AddAction(domainSession, tasks, task2);

      var transaction = new Transaction('two adds on tasks', domainSession);
      transaction.add(action1);
      transaction.add(action2);
      transaction.doit();
      tasksLength = tasksLength + 2;
      expect(tasks.length, equals(tasksLength));
      tasks.display(title:'Transaction Done');

      domainSession.past.undo();
      tasksLength = tasksLength - 2;
      expect(tasks.length, equals(tasksLength));
      tasks.display(title:'Transaction Undone');

      domainSession.past.redo();
      tasksLength = tasksLength + 2;
      expect(tasks.length, equals(tasksLength));
      tasks.display(title:'Transaction Redone');
    });
    test('Undo and Redo Update Task Title with Remove and Add Transaction', () {
      var title = 'generate json from the model';
      var task = tasks.firstWhereAttribute('title', title);
      expect(task, isNotNull);
      expect(task.title, equals(title));

      var removeAction = new RemoveAction(domainSession, tasks, task);
      var newTitle = 'generate from model to json';
      var newTaskWithNewTitle = new Task.withId(task.concept, newTitle);
      var addAction = new AddAction(domainSession, tasks, newTaskWithNewTitle);

      var count = tasks.count;
      var transaction = new Transaction('update title', domainSession);
      transaction.add(removeAction);
      transaction.add(addAction);
      // The id can be updated by removing and adding a task with a new id value.
      transaction.doit();
      expect(tasks.count, equals(count));
      expect(transaction.done, isTrue);

      domainSession.past.undo();
      expect(tasks.count, equals(count));
      task = tasks.firstWhereAttribute('title', title);
      expect(task, isNotNull);
      expect(task.title, equals(title));

      domainSession.past.redo();
      expect(tasks.count, equals(count));
      task = tasks.firstWhereAttribute('title', newTitle);
      expect(task, isNotNull);
      expect(task.title, equals(newTitle));
    });

    test('Reactions to Task Actions', () {
      var reaction = new Reaction();
      expect(reaction, isNotNull);

      domainModels.startActionReaction(reaction);
      var task = new Task(taskConcept);
      task.title = 'validate dartling documentation';

      var session = domainModels.newSession();
      var addAction = new AddAction(session, tasks, task);
      addAction.doit();
      expect(tasks.length, equals(++tasksLength));
      expect(reaction.reactedOnAdd, isTrue);
    });

    test('Copy Tasks', () {
      Tasks copiedTasks = tasks.copy();
      expect(copiedTasks.isEmpty, isFalse);
      expect(copiedTasks.length, equals(tasks.length));
      expect(copiedTasks, isNot(same(tasks)));
      expect(copiedTasks, equals(tasks));
      copiedTasks.forEach((ct) =>
          expect(ct, equals(tasks.singleWhereOid(ct.oid))));
      copiedTasks.forEach((ct) =>
          expect(ct.oid, equals(tasks.singleWhereOid(ct.oid).oid)));
      copiedTasks.forEach((ct) =>
          expect(ct, isNot(same(tasks.firstWhereAttribute('title', ct.title)))));
      copiedTasks.display(title:'Copied Tasks');
    });
    test('Copy Equality', () {
      var task = new Task(taskConcept);
      expect(task, isNotNull);
      task.title = 'writing a tutorial on Dartling';
      tasks.add(task);
      expect(tasks.length, equals(++tasksLength));

      task.display(prefix:'before copy: ');
      var copiedTask = task.copy();
      copiedTask.display(prefix:'after copy: ');
      expect(task, isNot(same(copiedTask)));
      expect(task, equals(copiedTask));
      expect(task.oid, equals(copiedTask.oid));
      expect(task.code, equals(copiedTask.code));
      expect(task.title, equals(copiedTask.title));
      expect(task.completed, equals(copiedTask.completed));
    });
    test('True for Every Task', () {
      expect(tasks.every((t) => t.code == null), isTrue);
      expect(tasks.every((t) => t.title != null), isTrue);
    });
  });
}

class Reaction implements ActionReactionApi {
  bool reactedOnAdd = false;
  bool reactedOnUpdate = false;

  react(BasicAction action) {
    if (action is EntitiesAction) {
      reactedOnAdd = true;
    }
  }
}

testTodoData(TodoRepo todoRepo) {
  testTodoMvc(todoRepo, TodoRepo.todoDomainCode,
      TodoRepo.todoMvcModelCode);
}

void main() {
  var todoRepo = new TodoRepo();
  testTodoData(todoRepo);
}


