import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/todo_controller.dart';
import '../../models/category.dart';
import '../import_export/import_export_dialog.dart';
import '../tasks/category_tasks_screen.dart';
import 'category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const CategoriesScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _searchQuery = '';

  Future<void> _addCategory(BuildContext context) async {
    final controller = context.read<TodoController>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const CategoryDialog(),
    );

    if (result != null) {
      await controller.addCategory(
        name: result['name'] as String,
        colorValue: result['colorValue'] as int,
        iconCodePoint: result['iconCodePoint'] as int,
      );
    }
  }

  Future<void> _editCategory(BuildContext context, Category category) async {
    final controller = context.read<TodoController>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => CategoryDialog(category: category),
    );

    if (result != null) {
      final updated = category.copyWith(
        name: result['name'] as String,
        colorValue: result['colorValue'] as int,
        iconCodePoint: result['iconCodePoint'] as int,
      );
      await controller.updateCategory(updated);
    }
  }

  Future<void> _deleteCategory(BuildContext context, Category category) async {
    final controller = context.read<TodoController>();
    final activeCount = controller.getActiveCount(category.id);
    final completedCount = controller.getCompletedCount(category.id);
    final totalCount = activeCount + completedCount;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?' +
              (totalCount > 0
                  ? '\n\nThis will also permanently delete $totalCount task(s) inside it.'
                  : ''),
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
      await controller.deleteCategory(category.id);
    }
  }

  void _openImportExport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const ImportExportDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TodoController>();

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allCategories = controller.categories;
    final filteredCategories = _searchQuery.isEmpty
        ? allCategories
        : allCategories.where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.check_box_rounded,
                color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Tasks & Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clipboard Backup / Restore',
            icon: const Icon(Icons.swap_vert_rounded),
            onPressed: () => _openImportExport(context),
          ),
          IconButton(
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: filteredCategories.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            allCategories.isEmpty
                                ? 'No categories yet'
                                : 'No matching categories found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            allCategories.isEmpty
                                ? 'Create your first category to start organizing tasks.'
                                : 'Try searching for something else.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800
                          ? 3
                          : (constraints.maxWidth > 500 ? 2 : 1);

                      return GridView.builder(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 12, bottom: 88),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.35,
                        ),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          final activeCount = controller.getActiveCount(category.id);
                          final completedCount =
                              controller.getCompletedCount(category.id);
                          final total = activeCount + completedCount;
                          final progress = total > 0 ? (completedCount / total) : 0.0;

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CategoryTasksScreen(
                                      categoryId: category.id,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: category.color.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            category.icon,
                                            color: category.color,
                                            size: 24,
                                          ),
                                        ),
                                        const Spacer(),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert_rounded, size: 20),
                                          onSelected: (val) {
                                            if (val == 'edit') {
                                              _editCategory(context, category);
                                            } else if (val == 'delete') {
                                              _deleteCategory(context, category);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_outlined, size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Edit Category'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline_rounded,
                                                      size: 18, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Delete Category',
                                                      style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$activeCount active · $completedCount completed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 5,
                                            backgroundColor:
                                                category.color.withOpacity(0.15),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              category.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCategory(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Category'),
      ),
    );
  }
}
