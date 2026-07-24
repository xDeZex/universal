import 'package:flutter/material.dart';

import '../models/routine.dart';
import 'coplanar_card.dart';

class RoutineTile extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;

  const RoutineTile({super.key, required this.routine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CoplanarCard(
      child: ListTile(title: Text(routine.name), onTap: onTap),
    );
  }
}
