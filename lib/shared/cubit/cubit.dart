import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';
import '../../modules/archived_tasks/archived_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  late GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController textController = TextEditingController();
  late TextEditingController timeController = TextEditingController();
  late TextEditingController dateController = TextEditingController();

  int currentIndex = 0;
  List<Widget> screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changIndex(int index) {
    currentIndex = index;
    emit(AppChangeNavBarState());
  }

  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  bool isButtomSheetShown = false;

  void changeBottomSheet() {
    isButtomSheetShown = !isButtomSheetShown;
    emit(AppChangeBottomSheetState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) async {
        print('Database created');

        await database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        });
      },
      onOpen: (database) {
        getFromDatabase(database);
        print('Database open');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  void getFromDatabase(database) async {
    emit(AppGetDatabaseLoadingState());
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    await database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateData({required String status, required int id}) {
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      getFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({required int id}) {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id])
        .then((value) {
      getFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  insertToDatabase() async {
    await database.transaction((txn) async {
      txn.rawInsert(
          'Insert into tasks (title,time, date,status)values("${textController.text}", "${timeController.text}", "${dateController.text}", "new")');
    }).then((value) {
      emit(AppInsertToDatabaseState());
      getFromDatabase(database);
    });
  }
}
