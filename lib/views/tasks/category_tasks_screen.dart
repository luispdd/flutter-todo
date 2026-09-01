import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/todo_controller.dart';
import '../../models/category.dart';
import 'active_tasks_view.dart';
import 'completed_tasks_view.dart';
import 'selection_action_bar.dart';
import 'task_dialog.dart';

class CategoryTasksScreen extends StatefulWidget {
  final String categoryId;

  const CategoryTasksScreen({super.key, required this.categoryId});

  @override
  State<CategoryTasksScreen> createState() => _CategoryTasksScreenState();
}

class _CategoryTasksScreenState extends State<CategoryTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addTask(BuildContext context, Category category) async {
    final controller = context.read<TodoController>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => TaskDialog(
        categoryId: category.id,
        categories: controller.categories,
      ),
    );

    if (result != null) {
      await controller.addTodo(
        categoryId: result['categoryId'] as String,
        title: result['title'] as String,
        description: result['description'] as String,
        dueDate: result['dueDate'] as DateTime?,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TodoController>();
    final category = controller.getCategoryById(widget.categoryId);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Category not found.')),
      );
    }

    final activeCount = controller.getActiveCount(category.id);
    final completedCount = controller.getCompletedCount(category.id);
    final isCurrentTabCompleted = _tabController.index == 1;
    final isSelectionMode = controller.isSelectionActive(isCurrentTabCompleted);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_box_outline_blank_rounded, size: 18),
                  const SizedBox(width: 8),
                  const Text('Active'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$activeCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.task_alt_rounded, size: 18),
                  const SizedBox(width: 8),
                  const Text('Completed'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$completedCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ActiveTasksView(category: category),
          CompletedTasksView(category: category),
        ],
      ),
      bottomNavigationBar: isSelectionMode
          ? SelectionActionBar(
              categoryId: category.id,
              isCompleted: isCurrentTabCompleted,
            )
          : null,
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addTask(context, category),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Task'),
            ),
    );
  }
}
