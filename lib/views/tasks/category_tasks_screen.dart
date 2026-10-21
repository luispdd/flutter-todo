import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/todo_controller.dart';
import '../../models/category.dart';
import '../../services/screen_api_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TodoController>().setLastActiveCategoryId(widget.categoryId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _screenApiService = ScreenApiService();
  bool _isSyncing = false;

  Future<void> _pullFromApi(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pull from API'),
        content: const Text(
          'This will delete all current tasks in this category and replace them with tasks from http://screen.local.\n\nAre you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.teal.shade700),
            child: const Text('Pull & Replace'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSyncing = true);

    try {
      final remoteTasks = await _screenApiService.fetchTasks();
      final tasksToImport = remoteTasks
          .map((t) => (title: t.text, isCompleted: t.done))
          .toList();

      if (!mounted) return;
      await context.read<TodoController>().replaceCategoryTasks(
            categoryId: category.id,
            tasks: tasksToImport,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully pulled ${remoteTasks.length} task(s) from screen.',
          ),
          backgroundColor: Colors.teal.shade800,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pull from API: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _pushToApi(Category category) async {
    setState(() => _isSyncing = true);
    final controller = context.read<TodoController>();

    try {
      final existingTasks = await _screenApiService.fetchTasks();
      for (final task in existingTasks) {
        await _screenApiService.deleteTask(task.id);
      }

      final activeTodos = controller.getActiveTodos(category.id);
      if (activeTodos.isNotEmpty) {
        await _screenApiService.createTasks(
          activeTodos.map((t) => t.title).toList(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully pushed ${activeTodos.length} pending task(s) to screen.',
            ),
            backgroundColor: Colors.indigo.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to push to API: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<TodoController>().clearLastActiveCategoryId();
        }
      },
      child: Scaffold(
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
          : (category.isApiSyncEnabled
              ? Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'pull_api_fab',
                      onPressed: _isSyncing ? null : () => _pullFromApi(category),
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Pull from API'),
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                    ),
                    FloatingActionButton.extended(
                      heroTag: 'push_api_fab',
                      onPressed: _isSyncing ? null : () => _pushToApi(category),
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Push to API'),
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                    ),
                    FloatingActionButton.extended(
                      heroTag: 'add_task_fab',
                      onPressed: () => _addTask(context, category),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Task'),
                    ),
                  ],
                )
              : FloatingActionButton.extended(
                  heroTag: 'add_task_fab',
                  onPressed: () => _addTask(context, category),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Task'),
                )),
      ),
    );
  }
}
