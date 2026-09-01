# Proposal: Update Selection Model & Bottom Action Bars (`update-selection-and-bottom-actions`)

## Problem Statement
The current UI automatically completes/reactivates tasks immediately upon single-clicking radio-like buttons, and tapping anywhere on a task card opens the edit modal. Users require an intentional checkbox selection flow where:
1. Tasks are checked/selected without instantly moving between tabs.
2. Clicking the card body toggles the checkbox selection.
3. Editing is strictly isolated to tapping the dedicated Edit button.
4. When items are selected, a dedicated Bottom Action Bar appears:
   - In Active Tasks: "Complete" action to batch complete all selected tasks.
   - In Completed Tasks: "Reactivate" action to restore selected tasks, and "Permanently Delete" action to purge them.

## Proposed Changes
1. **Active Tasks View**:
   - Replace circle action button with an interactive `Checkbox`.
   - Update `onTap` on task body to check/uncheck the task.
   - Restrict edit dialog trigger to the Edit icon button.
2. **Completed Tasks View**:
   - Replace instant restore button with an interactive `Checkbox`.
   - Update `onTap` on task body to check/uncheck the task.
   - Restrict edit dialog trigger to the Edit icon button.
3. **Bottom Action Bar**:
   - For Active Tasks: Show bottom action bar with count, Select/Deselect All, "Complete (N)" button, and Delete button.
   - For Completed Tasks: Show bottom action bar with count, Select/Deselect All, "Reactivate (N)" button, and "Permanently Delete" button.
   - Hide standard FAB when selection bar is active.

## Impact & Boundaries
- Non-breaking to the data models (`AppData`, `Category`, `TodoItem`) and persistence.
- Enhances usability and prevents accidental task completion/restoration.
