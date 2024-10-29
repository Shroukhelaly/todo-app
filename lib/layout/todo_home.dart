import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertToDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: cubit.scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isButtomSheetShown) {
                  if (cubit.formKey.currentState!.validate()) {
                    cubit.insertToDatabase();
                    cubit.changeBottomSheet();
                  }
                } else {
                  cubit.scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          padding: const EdgeInsets.all(20.0),
                          color: Colors.grey[200],
                          child: Form(
                            key: cubit.formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppFormField(
                                    controller: cubit.textController,
                                    type: TextInputType.text,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Task name required';
                                      }
                                      return null;
                                    },
                                    prefix:
                                        const Icon(Icons.text_fields_outlined),
                                    label: 'Task name'),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                AppFormField(
                                    controller: cubit.timeController,
                                    type: TextInputType.datetime,
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) {
                                        cubit.timeController.text =
                                            value!.format(context);
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Task time required';
                                      }
                                      return null;
                                    },
                                    prefix:
                                        const Icon(Icons.watch_later_outlined),
                                    label: 'Task time'),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                AppFormField(
                                    controller: cubit.dateController,
                                    type: TextInputType.datetime,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse('2024-18-08'),
                                      ).then((value) {
                                        cubit.dateController.text =
                                            DateFormat.yMMMd().format(value!);
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Task date required';
                                      }
                                      return null;
                                    },
                                    prefix: const Icon(Icons.calendar_today),
                                    label: 'Task time'),
                              ],
                            ),
                          ),
                        ),
                      )
                      .closed
                      .then((value)  {
                  cubit.changeBottomSheet();

                          });

                  cubit.changeBottomSheet();
                }
              },
              child: Icon(
                cubit.isButtomSheetShown ? Icons.add : Icons.edit,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Done',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive_outlined,
                    ),
                    label: 'Archived',
                  ),
                ]),
          );
        },
      ),
    );
  }
}
