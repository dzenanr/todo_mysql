#Todo MySQL

Project based on
[Target 11: Use IndexedDB](http://www.dartlang.org/docs/tutorials/indexeddb/),
[Using Dart with JSON Web Services](http://www.dartlang.org/articles/json-web-service/),
[dartling] (https://github.com/dzenanr/dartling)
and
[SQLJocky: MySQL connector for Dart](http://pub.dartlang.org/packages/sqljocky).

Client

+ client uses locally IndexedDB
+ client starts by loading data from IndexedDB
+ local data saved in IndexedDB by default
+ client has 2 buttons: To server and From server
+ To server (POST) integrates local tasks to data on the server
+ From server (GET) integrates server data to local tasks

Server

+ there are 2 versions of server: one without (todo_server_mysql) and
  the other with dartling (todo_server_dartling_mysql)
+ when it starts, server loads data from MySQL to the model in main memory
+ when the model in main memory changes, the database is updated
+ server programming uses the model in main memory and not the database
+ todo_server_dartling_mysql reacts to changes in the model by updating mysql

Use

1. do not forget to start the MySQL server
2. in MySQL Workbench create a new schema (empty database) with the todo name
3. put a path to the project folder (todo_server_mysql or todo_server_dartling_mysql)
   in the working directory field in Run/Manage Launches
   (in order to have access to the connection.options file).
4. run tests in test/mysql_test.dart to create tables
5. run server (todo_server_mysql/bin/server.dart or
   todo_server_dartling_mysql/bin/server.dart) in Dart Editor;
   it runs when you see in the server.dart tab in Dart Editor:
   Server at http://127.0.0.1:8080;
   if it does not run, use Run/Manage Launches
6. run client (todo_client_idb/web/app.html) in Dartium
7. run client as JavaScript (todo_client_idb/web/app.html) in Chrome
8. use the client app in Dartium:
   1. From server to integrate server data locally
   2. add, remove and update tasks (saved locally in IndexedDB by default)
   3. To server to integrate local data to server
9. use the client app in Chrome:
   1. From server to integrate server data locally
   2. add, remove and update tasks (saved locally in IndexedDB by default)
   3. To server to integrate local data to server





