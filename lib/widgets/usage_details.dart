
import 'package:flutter/material.dart';

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
        return SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 4),
              Text(value.toString(), style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        );
      }
    );
  }
}