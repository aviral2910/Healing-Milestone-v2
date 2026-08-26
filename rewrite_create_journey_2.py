import re

with open("lib/features/journey/presentation/widgets/create_journey_overlay.dart", "r") as f:
    content = f.read()

# I need to match the entire TextField for category and replace it with the new Tags widget
# We can find it by searching from 'TextField(\n                          controller: _categoryController,' down to the next 'const SizedBox(height: 32),'

pattern = r"TextField\(\n                          controller: _categoryController,[\s\S]*?const SizedBox\(height: 32\),"

new_ui = """
                        // Selected Tags Chips
                        if (_selectedCategories.isNotEmpty) ...[
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _selectedCategories.map((tag) {
                              return Chip(
                                label: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary.computeLuminance() > 0.25 ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: theme.primaryColor,
                                deleteIconColor: theme.colorScheme.primary.computeLuminance() > 0.25 ? Colors.black : Colors.white,
                                onDeleted: () {
                                  setState(() {
                                    _selectedCategories.remove(tag);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Tag Input
                        if (_selectedCategories.length < 3)
                          TextField(
                            controller: _categoryController,
                            style: theme.textTheme.bodyLarge,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                            ],
                            decoration: InputDecoration(
                              hintText: _selectedCategories.isEmpty ? 'Add up to 3 categories (e.g. cancerfree)' : 'Add another category',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              prefixText: '# ',
                              prefixStyle: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              suffixIcon: _isSearchingCategories
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: AppLoader.small(),
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: _onCategoryChanged,
                            onSubmitted: _addCategory,
                          ),
                          
                        // Suggestions Dropdown
                        if (_suggestions.isNotEmpty && _selectedCategories.length < 3)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Column(
                              children: _suggestions.map((suggestion) {
                                return Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      '#$suggestion',
                                      style: TextStyle(color: theme.colorScheme.onSurface),
                                    ),
                                    onTap: () {
                                      _addCategory(suggestion);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          
                        const SizedBox(height: 32),
"""

content = re.sub(pattern, new_ui, content)

# I also need to update the save logic at the bottom
# Look for: _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim(),
save_pattern = r"_categoryController\.text\n\s*\.trim\(\)\n\s*\.isEmpty\n\s*\? 'General'\n\s*: _categoryController\.text\n\s*\.trim\(\),"
# actually, just replace "_categoryController.text..." with "_selectedCategories,"
# Let's do it manually

old_edit_repo = """                                            await repo.updateJourney(
                                              widget.initialJourney!.id,
                                              _titleController.text.trim(),
                                              _categoryController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? 'General'
                                                  : _categoryController.text
                                                        .trim(),
                                              _visibility,
                                            );"""
new_edit_repo = """                                            await repo.updateJourney(
                                              widget.initialJourney!.id,
                                              _titleController.text.trim(),
                                              _selectedCategories.isEmpty ? ['General'] : _selectedCategories,
                                              _visibility,
                                            );"""
content = content.replace(old_edit_repo, new_edit_repo)

old_create_repo = """                                            await repo.createJourney(
                                              _titleController.text.trim(),
                                              _categoryController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? 'General'
                                                  : _categoryController.text
                                                        .trim(),
                                              _visibility,
                                            );"""
new_create_repo = """                                            await repo.createJourney(
                                              _titleController.text.trim(),
                                              _selectedCategories.isEmpty ? ['General'] : _selectedCategories,
                                              _visibility,
                                            );"""
content = content.replace(old_create_repo, new_create_repo)

with open("lib/features/journey/presentation/widgets/create_journey_overlay.dart", "w") as f:
    f.write(content)

