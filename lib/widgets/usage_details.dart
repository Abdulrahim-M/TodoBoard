
import 'package:flutter/material.dart';
import 'package:todo_board/constants/palette.dart' as clr;

class UsageDetailsRow extends StatelessWidget {
  final ValueNotifier<int> completedTasks;
  final ValueNotifier<int> totalTasks;

  const UsageDetailsRow({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow("Total Tasks", totalTasks),
        _buildRow("Completed Tasks", completedTasks),
      ],
    );
  }

  Widget _buildRow(String label, ValueNotifier<int> value) {
    return ValueListenableBuilder<int>(
      valueListenable: value,
      builder: (context, value, child) {
        return Container(
          width: 150,
          // height: 56,
          decoration: BoxDecoration(
            color: clr.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: clr.textDisabled, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(color: clr.textSecondary, fontSize: 15)),
              SizedBox(height: 4),
              Text(value.toString(), style: TextStyle(color: clr.textPrimary, fontSize: 20)),
            ],
          ),
        );
      }
    );
  }
}