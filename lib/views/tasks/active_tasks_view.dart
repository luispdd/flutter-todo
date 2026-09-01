import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/todo_controller.dart';
import '../../models/category.dart';
import '../../models/todo_item.dart';
import 'task_dialog.dart';

class ActiveTasksView extends StatelessWidget {
  final Category category;

  const ActiveTasksView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TodoController>();
    final activeTodos = controller.getActiveTodos(category.id);

    if (activeTodos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.task_alt_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No active tasks in ${category.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a task below to get started, or drag to organize your day.',
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
      itemCount: activeTodos.length,
      onReorder: (oldIndex, newIndex) {
        controller.reorderActiveTodos(category.id, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final item = activeTodos[index];
        final isSelected = controller.isItemSelected(item.id, isCompleted: false);

        return Card(
          key: ValueKey(item.id),
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 2 : 0,
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
              controller.toggleSelection(item.id, isCompleted: false);
            },
            onTap: () {
              controller.toggleSelection(item.id, isCompleted: false);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) =>
                        controller.toggleSelection(item.id, isCompleted: false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        if (item.dueDate != null) ...[
                          const SizedBox(height: 6),
                          _DueDateBadge(dueDate: item.dueDate!),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit Task',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _editTask(context, controller, item),
                  ),
                  IconButton(
                    tooltip: 'Delete Task',
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                    onPressed: () => controller.deleteTodo(item.id),
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

class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;

  const _DueDateBadge({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = dueDate.isBefore(DateTime(now.year, now.month, now.day));
    final isToday = dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;

    final color = isOverdue
        ? Colors.red.shade700
        : (isToday ? Colors.orange.shade800 : Colors.indigo.shade700);

    final bg = isOverdue
        ? Colors.red.shade50
        : (isToday ? Colors.orange.shade50 : Colors.indigo.shade50);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            isToday ? 'Today' : DateFormat.MMMd().format(dueDate),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
