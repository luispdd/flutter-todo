import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/todo_controller.dart';
import '../../models/category.dart';
import '../../models/todo_item.dart';
import 'task_dialog.dart';

class CompletedTasksView extends StatelessWidget {
  final Category category;

  const CompletedTasksView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TodoController>();
    final completedTodos = controller.getCompletedTodos(category.id);
    final isSelectionMode = controller.isSelectionActive(true);

    if (completedTodos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.done_all_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No completed tasks yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Finished tasks in this category will appear here. You can edit, reorder, restore, or delete them.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
      itemCount: completedTodos.length,
      onReorder: (oldIndex, newIndex) {
        controller.reorderCompletedTodos(category.id, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final item = completedTodos[index];
        final isSelected = controller.isItemSelected(item.id, isCompleted: true);

        return Card(
          key: ValueKey(item.id),
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 2 : 0,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B).withOpacity(0.6)
              : const Color(0xFFF1F5F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor.withOpacity(0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onLongPress: () {
              controller.toggleSelection(item.id, isCompleted: true);
            },
            onTap: () {
              if (isSelectionMode) {
                controller.toggleSelection(item.id, isCompleted: true);
              } else {
                _editTask(context, controller, item);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) =>
                          controller.toggleSelection(item.id, isCompleted: true),
                    )
                  else
                    IconButton(
                      tooltip: 'Restore to Active List',
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                      onPressed: () => controller.toggleTodoComplete(item.id),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (item.completedAt != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                'Completed ${DateFormat.yMMMd().add_jm().format(item.completedAt!)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send Back to Active List',
                    icon: const Icon(Icons.replay_rounded, size: 18, color: Colors.indigo),
                    onPressed: () => controller.toggleTodoComplete(item.id),
                  ),
                  IconButton(
                    tooltip: 'Edit Task',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _editTask(context, controller, item),
                  ),
                  IconButton(
                    tooltip: 'Delete Permanently',
                    icon: const Icon(Icons.delete_forever_rounded, size: 18, color: Colors.redAccent),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Permanently?'),
                          content: Text('Delete "${item.title}" permanently?'),
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
                        await controller.deleteTodo(item.id);
                      }
                    },
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editTask(
    BuildContext context,
    TodoController controller,
    TodoItem item,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => TaskDialog(
        categoryId: category.id,
        categories: controller.categories,
        item: item,
      ),
    );

    if (result != null) {
      final updated = item.copyWith(
        title: result['title'] as String,
        description: result['description'] as String,
        categoryId: result['categoryId'] as String,
        dueDate: result['dueDate'] as DateTime?,
        clearDueDate: result['dueDate'] == null,
      );
      await controller.updateTodo(updated);
    }
  }
}
