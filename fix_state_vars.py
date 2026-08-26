import re

with open("lib/features/journey/presentation/widgets/create_journey_overlay.dart", "r") as f:
    content = f.read()

# I need to add imports as well since they probably failed too
if "import 'dart:async';" not in content:
    content = content.replace("import 'dart:ui';", "import 'dart:ui';\nimport 'dart:async';\nimport 'package:flutter/services.dart';\nimport '../../../../features/posts/data/api_hashtag_repository.dart';\nimport '../../../../features/posts/data/hashtag_repository.dart';")

vars_to_add = """  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  List<String> _selectedCategories = [];
  List<String> _suggestions = [];
  bool _isSearchingCategories = false;
  Timer? _debounce;"""
content = content.replace("  final _titleController = TextEditingController();\n  final _categoryController = TextEditingController();", vars_to_add)

# Update initState to set selectedCategories
old_init = """    if (widget.initialJourney != null) {
      _titleController.text = widget.initialJourney!.title;
      
      _visibility = widget.initialJourney!.visibility;
    }"""
new_init = """    if (widget.initialJourney != null) {
      _titleController.text = widget.initialJourney!.title;
      _selectedCategories = List.from(widget.initialJourney!.categories);
      _visibility = widget.initialJourney!.visibility;
    }"""
content = content.replace(old_init, new_init)

# Update dispose
content = content.replace("super.dispose();", "_debounce?.cancel();\n    super.dispose();")

# Add the missing functions if they are missing
if "_onCategoryChanged" not in content:
    content = content.replace("JourneyType _selectedType = JourneyType.personal;", """  void _onCategoryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final cleanQuery = query.toLowerCase().trim();

    if (cleanQuery.isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearchingCategories = false;
      });
      return;
    }

    final trendingAsync = ref.read(trendingHashtagsProvider);
    List<String> localMatches = [];
    if (trendingAsync.hasValue && trendingAsync.value != null) {
      localMatches = trendingAsync.value!
          .where(
            (tag) => tag.startsWith(cleanQuery) && !_selectedCategories.contains(tag),
          )
          .take(4)
          .toList();
    }

    if (localMatches.isNotEmpty) {
      setState(() {
        _suggestions = localMatches;
        _isSearchingCategories = false;
      });
      return;
    }

    setState(() => _isSearchingCategories = true);

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final apiRepo = ref.read(apiHashtagRepositoryProvider);
        final results = await apiRepo.searchHashtags(cleanQuery);
        
        if (mounted) {
          setState(() {
            _suggestions = results.where((tag) => !_selectedCategories.contains(tag)).toList();
            _isSearchingCategories = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingCategories = false);
        }
      }
    });
  }

  void _addCategory(String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isNotEmpty && !_selectedCategories.contains(cleanQuery) && _selectedCategories.length < 3) {
      setState(() {
        _selectedCategories.add(cleanQuery);
        _categoryController.clear();
        _suggestions = [];
        _isSearchingCategories = false;
      });
    } else {
        _categoryController.clear();
        setState(() {
            _suggestions = [];
        });
    }
  }

  JourneyType _selectedType = JourneyType.personal;""")

with open("lib/features/journey/presentation/widgets/create_journey_overlay.dart", "w") as f:
    f.write(content)
