import 'package:unittest/unittest.dart';
import 'package:options_file/options_file.dart';
import 'package:sqljocky/sqljocky.dart';
import 'package:sqljocky/utils.dart';
import 'dart:async';

testTasks(ConnectionPool pool) {
  group('Testing tasks', () {
    test('Select all tasks', () {
      pool.query(
        'select t.title, t.completed, t.updated '
        'from task t '
      ).then((rows) {
        var count = 0;
        print('selected all tasks');
        rows.listen((row) {
          print(
            'count: ${++count} - '
            'title: ${row[0]}, '
            'completed: ${row[1]}, '
            'updated: ${row[2]}'
          );
        });
      });
    });

    test('Select completed tasks', () {
      pool.query(
        'select t.title, t.completed, t.updated '
        'from task t '
        'where t.completed = 1 '
      ).then((rows) {
        print('selected completed tasks');
        rows.listen((row) {
          expect(row[1], equals(1));
          print(
            'title: ${row[0]}, '
            'completed: ${row[1]}, '
            'updated: ${row[2]}'
          );
        });
      });
    });
  });
}

Future dropTable(ConnectionPool pool) {
  print('dropping task table');
  var dropper = new TableDropper(pool, ['task']);
  return dropper.dropTables();
}

Future createTable(ConnectionPool pool) {
  print('creating task table');
  var query = new QueryRunner(pool, [
    'create table task ('
      'title varchar(64) not null, '
      'completed bool not null, '
      'updated datetime not null, '
      'primary key (title) '
    ')'
  ]);
  return query.executeQueries();
}

Future initData(ConnectionPool pool) {
  print('initializing task data');
  var completer = new Completer();
  pool.prepare(
    'insert into task (title, completed, updated) values (?, ?, ?)'
  ).then((query) {
    print('prepared query insert into task');
    var data = [
      ['a', 0, '2013-08-11'],
      ['b', 1, '2013-08-11'],
      ['c', 0, '2013-08-11']
    ];
    return query.executeMulti(data);
  }).then((results) {
    print('executed query insert into task');
    completer.complete(results);
  });
  return completer.future;
}

Future emptyTable(ConnectionPool pool) {
  print('empting task table');
  var query = new QueryRunner(pool, [
    'truncate task'
  ]);
  return query.executeQueries();
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

main() {
  var pool = getPool(new OptionsFile('connection.options'));
  dropTable(pool).then((_) {
    print('dropped task table');
    createTable(pool).then((_) {
      print('created task table');
      initData(pool).then((x) {
        print('initialized task data');
        testTasks(pool);
      });
    });
  });
}