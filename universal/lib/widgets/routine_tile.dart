import 'package:flutter/material.dart';

import '../models/routine.dart';

class RoutineTile extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;

  const RoutineTile({super.key, required this.routine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(routine.name), onTap: onTap);
  }
}
