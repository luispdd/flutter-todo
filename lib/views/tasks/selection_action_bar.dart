import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/todo_controller.dart';

class SelectionActionBar extends StatelessWidget {
  final String categoryId;
  final bool isCompleted;

  const SelectionActionBar({
    super.key,
    required this.categoryId,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TodoController>();
    final count = controller.getSelectionCount(isCompleted);
    final totalItems = isCompleted
        ? controller.getCompletedCount(categoryId)
        : controller.getActiveCount(categoryId);
    final allSelected = count > 0 && count == totalItems;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Clear Selection',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => controller.clearSelection(isCompleted: isCompleted),
          ),
          const SizedBox(width: 8),
          Text(
            '$count selected',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            icon: Icon(
              allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
              size: 18,
            ),
            label: Text(allSelected ? 'Deselect All' : 'Select All'),
            onPressed: () => controller.selectAll(categoryId, isCompleted: isCompleted),
          ),
          const SizedBox(width: 8),
          if (!isCompleted) ...[
            FilledButton.icon(
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Complete'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => controller.batchCompleteSelected(),
            ),
            const SizedBox(width: 8),
          ] else ...[
            FilledButton.icon(
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text('Restore to Active'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => controller.batchRestoreSelected(),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            tooltip: isCompleted ? 'Delete Permanently' : 'Delete Selected',
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(isCompleted ? 'Delete Permanently?' : 'Delete Selected Tasks?'),
                  content: Text(
                    'Are you sure you want to remove $count selected task(s)? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await controller.batchDeleteSelected(isCompleted: isCompleted);
              }
            },
          ),
        ],
      ),
    );
  }
}
