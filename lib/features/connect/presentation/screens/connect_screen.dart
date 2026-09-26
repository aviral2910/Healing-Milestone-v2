import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  bool _isLoading = true;
  List<dynamic> _rosterItems = [];
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRoster();
  }

  Future<void> _fetchRoster() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.get('/api/connect/roster?limit=100&search=$_searchQuery');
      setState(() {
        _rosterItems = response.data['items'] ?? response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load patient roster.';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromRoster(String id) async {
    try {
      final dio = ref.read(apiClientProvider).dio;
      await dio.delete('/api/connect/roster/$id');
      setState(() {
        _rosterItems.removeWhere((item) => item['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from roster')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove from roster')),
      );
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _fetchRoster();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('HM Connect', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Roster',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage and monitor your saved patient health snapshots.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by patient name or alias...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)))
                : _rosterItems.isEmpty
                  ? Center(
                      child: Text(
                        'No patients found in your roster.',
                        style: TextStyle(color: theme.textTheme.bodySmall?.color),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _rosterItems.length,
                      itemBuilder: (context, index) {
                        final item = _rosterItems[index];
                        final addedAt = item['added_at'] != null ? DateTime.parse(item['added_at']) : null;
                        final expiresAt = item['expires_at'] != null ? DateTime.parse(item['expires_at']) : null;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/snapshot/${item['mix_view_id']}'),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    foregroundColor: theme.colorScheme.primary,
                                    radius: 24,
                                    child: Text(
                                      (item['patient_alias'] ?? item['author_name'] ?? '?').substring(0, 1).toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['patient_alias'] ?? item['author_name'] ?? 'Unknown Patient',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.insert_drive_file_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['snapshot_title'] ?? 'Snapshot',
                                                style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        if (addedAt != null)
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 14, color: theme.textTheme.bodySmall?.color),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Added ${DateFormat('MM/dd/yyyy').format(addedAt)}',
                                                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 8),
                                        if (expiresAt != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.access_time, size: 12, color: theme.colorScheme.primary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Valid until: ${DateFormat('MM/dd/yyyy').format(expiresAt)}',
                                                  style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error.withValues(alpha: 0.7)),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Remove Patient'),
                                          content: const Text('Are you sure you want to remove this patient snapshot from your roster?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                _removeFromRoster(item['id']);
                                              },
                                              child: Text('Remove', style: TextStyle(color: theme.colorScheme.error)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
