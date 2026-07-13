import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final bool isActiveTab;

  const SearchScreen({
    Key? key,
    this.scrollController,
    this.isActiveTab = true,
  }) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When becoming active
    if (widget.isActiveTab && !oldWidget.isActiveTab) {
      // Clear the search text
      _searchController.clear();

      // Small delay to ensure route animation finishes if applicable
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2A2A2A),
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Color(0xFF7A7A7A)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFFA1A1A6)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear,
                          color: Color(0xFFA1A1A6), size: 20),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Find stories, awareness, and people.',
                        style: TextStyle(
                          color: Color(0xFFA1A1A6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
