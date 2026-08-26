import re

with open("lib/features/journey/presentation/widgets/create_journey_overlay.dart", "r") as f:
    content = f.read()

# Replace the Category TextField with the Tags logic
old_ui = """                        TextField(
                          controller: _categoryController,
                          maxLength: 25,
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'e.g. Physical Recovery, Grief, Career',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            counterStyle: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                        ),"""

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
                              hintText: _selectedCategories.isEmpty ? 'Search or add category' : 'Add another category',
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
                              filled: true,
                              fillColor: theme.colorScheme.surface,
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
"""

if old_ui in content:
    content = content.replace(old_ui, new_ui)
else:
    print("WARNING: Could not find old UI block to replace!")

with open("lib/features/journey/presentation/widgets/create_journey_overlay.dart", "w") as f:
    f.write(content)
