library todo_mvc;

import 'dart:async';

import 'package:options_file/options_file.dart';
import 'package:sqljocky/sqljocky.dart';

import "package:dartling/dartling.dart";

part "todo/mvc/json/data.dart";
part "todo/mvc/json/model.dart";

part "todo/mvc/init.dart";

part "todo/mvc/tasks.dart";

part "gen/todo/mvc/entries.dart";
part "gen/todo/mvc/tasks.dart";

part "gen/todo/models.dart";
part "gen/todo/repository.dart";

part 'persistence/mysql.dart';