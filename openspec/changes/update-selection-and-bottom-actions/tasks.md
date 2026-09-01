# Tasks: Update Selection Model & Bottom Action Bars (`update-selection-and-bottom-actions`)

- [x] 1. Update `ActiveTasksView` <!-- id: 1-active-tasks-view -->
  - [x] 1.1 Replace radio/circle action button with a permanent `Checkbox` indicating selection
  - [x] 1.2 Update card body `onTap` to toggle selection instead of opening edit dialog
  - [x] 1.3 Ensure Edit dialog is strictly triggered by tapping the Edit icon button
- [x] 2. Update `CompletedTasksView` <!-- id: 2-completed-tasks-view -->
  - [x] 2.1 Replace instant restore button with a permanent `Checkbox` indicating selection
  - [x] 2.2 Update card body `onTap` to toggle selection instead of opening edit dialog
  - [x] 2.3 Ensure Edit dialog is strictly triggered by tapping the Edit icon button
- [x] 3. Update `CategoryTasksScreen` & Bottom Action Bars <!-- id: 3-bottom-actions -->
  - [x] 3.1 Implement mobile-first full-width bottom action bar for Active tasks with a single "Complete" button (no Delete action)
  - [x] 3.2 Implement bottom action bar for Completed tasks with "Reactivate" and "Permanently Delete" buttons
  - [x] 3.3 Seamlessly toggle between Bottom Action Bar (when $\ge 1$ item selected) and standard "Add Task" FAB
- [x] 4. Verification & Testing <!-- id: 4-verification -->
  - [x] 4.1 Update widget & unit tests to reflect new checkbox and bottom action flows
