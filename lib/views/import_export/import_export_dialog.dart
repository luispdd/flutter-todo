import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/todo_controller.dart';
import '../../services/clipboard_service.dart';

class ImportExportDialog extends StatefulWidget {
  const ImportExportDialog({super.key});

  @override
  State<ImportExportDialog> createState() => _ImportExportDialogState();
}

class _ImportExportDialogState extends State<ImportExportDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _importTextController;
  final ClipboardService _clipboardService = ClipboardService();

  ValidationResult? _validationResult;
  bool _mergeMode = false;
  String _exportJsonString = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _importTextController = TextEditingController();

    final controller = context.read<TodoController>();
    _exportJsonString = controller.exportToJson();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _importTextController.dispose();
    super.dispose();
  }

  void _validateInput(String text) {
    if (text.trim().isEmpty) {
      setState(() => _validationResult = null);
      return;
    }
    final result = _clipboardService.validateJson(text);
    setState(() => _validationResult = result);
  }

  Future<void> _pasteFromClipboard() async {
    final text = await _clipboardService.pasteFromClipboard();
    if (text != null && text.isNotEmpty) {
      _importTextController.text = text;
      _validateInput(text);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty or contains non-text data.')),
        );
      }
    }
  }

  Future<void> _copyExportToClipboard() async {
    await _clipboardService.copyToClipboard(_exportJsonString);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application data copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _executeImport() async {
    if (_validationResult == null || !_validationResult!.isValid) return;

    final appData = _validationResult!.data!;
    final controller = context.read<TodoController>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_mergeMode ? 'Merge Data?' : 'Replace All Data?'),
        content: Text(
          _mergeMode
              ? 'This will add ${appData.categories.length} category(ies) and ${appData.todos.length} task(s) to your existing data.'
              : 'This will completely REPLACE your current data with ${appData.categories.length} category(ies) and ${appData.todos.length} task(s). Current data will be overwritten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: _mergeMode
                ? null
                : FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(_mergeMode ? 'Confirm Merge' : 'Confirm Replace'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.importData(appData, replaceAll: !_mergeMode);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _mergeMode
                  ? 'Data merged successfully!'
                  : 'Data imported and restored successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TodoController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        height: 620,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.swap_horiz_rounded, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Clipboard Sync & Backup',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.upload_rounded, size: 18),
                  text: 'Export (Copy JSON)',
                ),
                Tab(
                  icon: Icon(Icons.download_rounded, size: 18),
                  text: 'Import (Paste JSON)',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- EXPORT TAB ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${controller.categories.length} Categories, ${controller.allTodos.length} Tasks ready for export.',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _exportJsonString,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy JSON to Clipboard'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _copyExportToClipboard,
                      ),
                    ],
                  ),

                  // --- IMPORT TAB ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.content_paste_rounded),
                              label: const Text('Paste from Clipboard'),
                              onPressed: _pasteFromClipboard,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Clear',
                            icon: const Icon(Icons.clear_all_rounded),
                            onPressed: () {
                              _importTextController.clear();
                              _validateInput('');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TextField(
                          controller: _importTextController,
                          maxLines: null,
                          expands: true,
                          onChanged: _validateInput,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Paste valid JSON data here...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_validationResult != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _validationResult!.isValid
                                ? Colors.green.withOpacity(0.12)
                                : Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _validationResult!.isValid
                                  ? Colors.green
                                  : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _validationResult!.isValid
                                    ? Icons.check_circle_rounded
                                    : Icons.error_outline_rounded,
                                color: _validationResult!.isValid
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _validationResult!.isValid
                                      ? 'Valid schema: ${_validationResult!.data!.categories.length} Categories, ${_validationResult!.data!.todos.length} Tasks'
                                      : (_validationResult!.errorMessage ?? 'Invalid format'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _validationResult!.isValid
                                        ? Colors.green.shade900
                                        : Colors.red.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          const Text('Import Mode: '),
                          ChoiceChip(
                            label: const Text('Replace All'),
                            selected: !_mergeMode,
                            onSelected: (val) {
                              if (val) setState(() => _mergeMode = false);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Merge'),
                            selected: _mergeMode,
                            onSelected: (val) {
                              if (val) setState(() => _mergeMode = true);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        icon: const Icon(Icons.download_rounded),
                        label: Text(_mergeMode ? 'Merge Import' : 'Replace & Import'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: _validationResult?.isValid == true
                              ? (_mergeMode ? Colors.indigo : Colors.deepOrange.shade700)
                              : Colors.grey,
                        ),
                        onPressed: _validationResult?.isValid == true
                            ? _executeImport
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
