import 'package:flutter/material.dart';

import '../cubit/cubit.dart';

class TaskWidget extends StatelessWidget {
  final String title;
  final String time;
  final int id;
  const TaskWidget({
    required this.title,
    required this.time,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('$id'),
      onDismissed: (direction) {
        AppCubit.get(context).deleteDataFromDataBase(id: id);
      },
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                maxRadius: 40,
                backgroundColor: const Color(0xFF3C6FE2),
                child: Text(
                  '$time',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$title',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () {
                  AppCubit.get(context).updateDataBase(status: 'DONE', id: id);
                },
                icon: const Icon(
                  Icons.check_box,
                  color: Colors.green,
                ),
              ),
              IconButton(
                onPressed: () {
                  AppCubit.get(context)
                      .updateDataBase(status: 'ARCHIVE', id: id);
                },
                icon: const Icon(
                  Icons.archive,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
