import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app_challenge/shared/cubit/states.dart';
import '../../layouts/archived_task_screen.dart';
import '../../layouts/done_task_screen.dart';
import '../../layouts/new_task_screen.dart';

class AppCubit extends Cubit<AppStates> {
  int currentIndex = 0;
  late Database dataBase;
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  List<Widget> screens = [
    const NewTaskScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];

  List<String> appBarTitles = [
    'All tasks',
    'Done tasks',
    'Archived tasks',
  ];

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  AppCubit()
      : super(
          AppInitialState(),
        );

  static AppCubit get(context) => BlocProvider.of(context);

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDataBase() {
    openDatabase(
      'todo1.db',
      version: 2,
      onCreate: (db, version) {
        db
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT, status TEXT)')
            .then(
          (value) {
            print(
              'table created',
            );
          },
        ).catchError(
          (error) {
            print('Error when creating TABLE ${error.toString()}');
          },
        );
      },
      onOpen: (db) {
        getDataFromDataBase(db);
        print('Database opened');
      },
    ).then(
      (value) {
        dataBase = value;
        emit(AppCreateDataBaseState());
      },
    );
  }

  void insertToDataBase({
    required String title,
    required String time,
  }) async {
    await dataBase.transaction(
      (txn) {
        return txn
            .rawInsert(
          'INSERT INTO tasks(title, time, status) VALUES ("$title","$time","NEW")',
        )
            .then(
          (value) {
            print('$value inserted succefully');
            emit(AppInsertDataBaseState());
            getDataFromDataBase(dataBase);
          },
        ).catchError(
          (error) {
            print('Error when inserting new value ${error.toString()}');
          },
        );
      },
    );
  }

  void getDataFromDataBase(Database dataBase) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDataBaseLoadingState());
    dataBase
        .rawQuery(
      'SELECT * FROM tasks',
    )
        .then(
      (value) {
        for (var element in value) {
          if (element['status'] == 'NEW') {
            newTasks.add(element);
          } else if (element['status'] == 'DONE') {
            doneTasks.add(element);
          } else {
            archivedTasks.add(element);
          }
        }

        emit(AppGetDataBaseState());
      },
    );
  }

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  void updateDataBase({required String status, required int id}) {
    dataBase.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ? ',
      [
        status,
        id,
      ],
    ).then(
      (value) {
        getDataFromDataBase(dataBase);
        emit(AppUpdateDataBaseState());
      },
    );
  }

  void deleteDataFromDataBase({required int id}) {
    dataBase.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then(
      (value) {
        getDataFromDataBase(dataBase);
        emit(AppDeleteDataBaseState());
      },
    );
  }
}
