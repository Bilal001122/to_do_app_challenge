import 'package:flutter/material.dart';
import '../shared/components/default_form_field.dart';
import '../shared/cubit/cubit.dart';
import '../shared/cubit/states.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final Shader linearGradient = const LinearGradient(
  colors: <Color>[Color(0xff4470E4), Color(0xff9379F3)],
).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

class HomeLayout extends StatelessWidget {
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return AppCubit()..createDataBase();
      },
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDataBaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            floatingActionButton: Builder(builder: (builderContext) {
              return FloatingActionButton(
                backgroundColor: Color(0xFF3C6FE2),
                onPressed: () {
                  if (cubit.isBottomSheetShown) {
                    if (formKey.currentState!.validate()) {
                      cubit.insertToDataBase(
                        title: titleController.text,
                        time: timeController.text,
                      );
                    }
                  } else {
                    Scaffold.of(builderContext)
                        .showBottomSheet(
                          (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DefaultFormField(
                                      controller: titleController,
                                      textInputType: TextInputType.text,
                                      isPassword: false,
                                      onFieldSubmitted: (value) {},
                                      onTap: () {},
                                      onChanged: (value) {},
                                      onValidate: (value) {
                                        if (value!.isEmpty) {
                                          return 'title must not be empty';
                                        }
                                      },
                                      prefixIcon: Icons.title,
                                      label: const Text('Task Title'),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    DefaultFormField(
                                      label: const Text('Task Time'),
                                      controller: timeController,
                                      textInputType: TextInputType.datetime,
                                      isPassword: false,
                                      onFieldSubmitted: (value) {},
                                      onTap: () {
                                        showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        ).then((value) {
                                          timeController.text =
                                              value!.format(context).toString();
                                          print(value.format(context));
                                        });
                                      },
                                      onChanged: (value) {},
                                      onValidate: (value) {
                                        if (value!.isEmpty) {
                                          return 'time must not be empty';
                                        }
                                      },
                                      prefixIcon: Icons.watch_later_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                        .closed
                        .then((value) {
                          cubit.changeBottomSheetState(
                              isShow: false, icon: Icons.add);
                        });
                    cubit.changeBottomSheetState(
                        isShow: true, icon: Icons.send);
                  }
                },
                child: Icon(
                  cubit.fabIcon,
                ),
              );
            }),
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(cubit.appBarTitles[cubit.currentIndex],
                  style: TextStyle(
                    foreground: Paint()..shader = linearGradient,
                  )),
            ),
            body: state is AppGetDataBaseLoadingState
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : cubit.screens[cubit.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Color(0xFF3C6FE2),
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (value) {
                cubit.changeIndex(value);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'New Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archived Tasks',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
