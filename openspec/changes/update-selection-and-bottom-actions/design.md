# Technical Design: Update Selection Model & Bottom Action Bars (`update-selection-and-bottom-actions`)

## 1. Interaction Flow

### Active Tasks Tab
1. Each item displays a `Checkbox(value: isSelected, onChanged: ...)`.
2. Tapping anywhere on the item body (`InkWell.onTap`) invokes `controller.toggleSelection(item.id, isCompleted: false)`.
3. Tapping the Edit icon button (`IconButton(icon: Icon(Icons.edit_outlined))`) opens `TaskDialog`.
4. When $\ge 1$ active tasks are selected:
   - A bottom action bar appears docked at the bottom part of the screen (mobile-first).
   - It displays a single primary "Complete" button spanning the entire available width (`double.infinity`).
   - No delete action button is presented in this section for the active selection.
   - Tapping "Complete" calls `controller.batchCompleteSelected()`, setting `isCompleted = true` on all selected tasks and moving them to the Completed list.

### Completed Tasks Tab
1. Each completed item displays a `Checkbox(value: isSelected, onChanged: ...)`.
2. Tapping anywhere on the item body (`InkWell.onTap`) invokes `controller.toggleSelection(item.id, isCompleted: true)`.
3. Tapping the Edit icon button opens `TaskDialog`.
4. When $\ge 1$ completed tasks are selected:
   - The bottom action bar appears docked at the bottom part of the screen with two actions:
     1. Primary "Reactivate" button (`controller.batchRestoreSelected()`).
     2. "Permanently Delete" button (`controller.batchDeleteSelected(isCompleted: true)` with confirmation prompt).

## 2. Component Architecture

```
CategoryTasksScreen (Scaffold)
├── AppBar (Category info + TabBar: Active / Completed)
├── TabBarView
│   ├── ActiveTasksView (ReorderableListView of items with Checkboxes)
│   └── CompletedTasksView (ReorderableListView of completed items with Checkboxes)
└── bottomNavigationBar / bottomSheet
    ├── SelectionBottomBar (Rendered when selectionCount > 0)
    └── Standard FloatingActionButton ("Add Task" rendered when selectionCount == 0)
```

## 3. State & Controller Integration
The existing `TodoController` methods (`toggleSelection`, `selectAll`, `clearSelection`, `batchCompleteSelected`, `batchRestoreSelected`, `batchDeleteSelected`) already support this workflow seamlessly.
