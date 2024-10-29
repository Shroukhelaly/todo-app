import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

class AppFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType type;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final Icon prefix;
  final String label;
  final Function()? onTap;

  const AppFormField({
    super.key,
    required this.controller,
    required this.type,
    required this.validator,
    required this.prefix,
    required this.label,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        keyboardType: type,
        validator: validator,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          prefixIcon: prefix,
        ));
  }
}

class BuildTaskItem extends StatelessWidget {
  final Map model;
  const BuildTaskItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Dismissible(key: Key(model['id'].toString()), child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.0,
            child: Text(
                '${model['time']}'
            ),


          ),
          const SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${model['title']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0
                  ),
                ),
                Text(
                  '${model['date']}',
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 20.0
                  ),
                ),

              ],
            ),

          ),
          const SizedBox(
            width: 10.0,
          ),
          IconButton(
            onPressed: () {
              AppCubit.get(context).updateData(
                status: 'archived',
                id: model['id'],
              );
            },
            icon: const Icon(Icons.archive_outlined,

            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          IconButton(
            onPressed: () {
              AppCubit.get(context).updateData(
                status: 'done',
                id: model['id'],
              );
            },
            icon: const Icon(Icons.check_box,
                color: Colors.green
            ),
          ),
        ],
      ),
    ), onDismissed: (direction){
      AppCubit.get(context).deleteData(id: model['id']);
    },);
  }
}

class TaskBuilder extends StatelessWidget {
  final List<Map> tasks;
  const TaskBuilder({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition:  tasks.isNotEmpty,
      builder: (context)=> ListView.separated(
        itemBuilder: (context, index) => BuildTaskItem(model: tasks[index]),
        separatorBuilder: (context, index) => Container(
          color: Colors.grey[400],
          height: 1,
        ),
        itemCount: tasks.length,
      ),
      fallback: (context) => const Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              size: 80,
              color: Colors.grey,
            ),
            Text('No Tasks Yet',
              style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


