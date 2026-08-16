import '../../../../features/milestone/presentation/providers/post_creation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:healing_milestones/features/milestone/presentation/providers/drafts_provider.dart';

class DraftsScreen extends ConsumerStatefulWidget {
  const DraftsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends ConsumerState<DraftsScreen> {
  final Set<String> _selectedIds = {};
  
  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drafts = ref.watch(draftsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedIds.length} Selected', style: const TextStyle(fontWeight: FontWeight.bold))
            : const Text('My Drafts', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Select All',
              onPressed: () {
                setState(() {
                  if (_selectedIds.length == drafts.length) {
                    _selectedIds.clear();
                  } else {
                    _selectedIds.addAll(drafts.map((d) => d.id));
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete Selected',
              onPressed: () async {
                final confirm = await _confirmDelete(context, multiple: true);
                if (confirm == true) {
                  final idsToDelete = Set<String>.from(_selectedIds);
                  await ref.read(draftsProvider.notifier).deleteDrafts(idsToDelete);
                  _clearSelection();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Drafts deleted'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                }
              },
            ),
          ]
        ],
      ),
      body: drafts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drafts_outlined, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No drafts yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: drafts.length,
              itemBuilder: (context, index) {
                final draft = drafts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Dismissible(
                    key: Key(draft.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await _confirmDelete(context);
                    },
                    onDismissed: (_) {
                      ref.read(draftsProvider.notifier).deleteDraft(draft.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Draft deleted'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Material(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onLongPress: () {
                          _toggleSelection(draft.id);
                        },
                        onTap: () {
                          if (_isSelectionMode) {
                            _toggleSelection(draft.id);
                          } else {
                            ref.read(postCreationControllerProvider.notifier).initializeWithDraft(draft);
                            context.push(AppRoutes.createPostManual);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: _selectedIds.contains(draft.id)
                                ? Border.all(color: theme.colorScheme.primary, width: 2)
                                : null,
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Stack(
                            children: [
                              Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                draft.title.isNotEmpty ? draft.title : 'Untitled Draft',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                draft.content.isNotEmpty ? draft.content : 'No content...',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: theme.colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(draft.lastSaved),
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (_isSelectionMode)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                _selectedIds.contains(draft.id)
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: _selectedIds.contains(draft.id)
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<bool?> _confirmDelete(BuildContext context, {bool multiple = false}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(multiple ? 'Delete Drafts?' : 'Delete Draft?'),
        content: Text(multiple 
          ? 'Are you sure you want to delete these ${_selectedIds.length} drafts? This action cannot be undone.'
          : 'Are you sure you want to delete this draft? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
