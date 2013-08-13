import 'package:todo_client_idb/todo_client_idb.dart';

main() {
  var tasksDb = new TasksDb();
  tasksDb.open().then((_) {
    TasksStore tasksStore = tasksDb.tasksStore;
    var tasksView = new TasksView(tasksStore);
    tasksView.loadElements(tasksStore.tasks);
  });

}