part of 'post_settings_screen.dart';

extension PostSettingsHashtags on _PostSettingsScreenState {
  Widget _buildHashtagsSection(BuildContext context, ThemeData theme) {
    return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tags',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Selected Tags Chips
                  if (_selectedTags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedTags.map((tag) {
                        return Chip(
                          label: Text(
                            '#$tag',
                            style: TextStyle(
                              color:
                                  theme.colorScheme.primary.computeLuminance() >
                                      0.25
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: theme.primaryColor,
                          deleteIconColor:
                              theme.colorScheme.primary.computeLuminance() >
                                  0.25
                              ? Colors.black
                              : Colors.white,
                          onDeleted: () {
                            setState(() {
                              _selectedTags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Tag Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      controller: _tagController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9]'),
                        ),
                        _LowerCaseTextFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Add a tag (e.g. cancerfree)',
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        prefixText: '# ',
                        prefixStyle: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        suffixIcon: _isSearchingTags
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      onChanged: _onTagChanged,
                      onSubmitted: _addTag,
                    ),
                  ),
                  // Suggestions Dropdown
                  if (_suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        children: _suggestions.map((suggestion) {
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              dense: true,
                              title: Text(
                                '#$suggestion',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              onTap: () {
                                _addTag(suggestion);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
  }
}
