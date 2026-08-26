import re

with open("lib/features/search/presentation/screens/search_screen.dart", "r") as f:
    content = f.read()

# Make the state class a SingleTickerProviderStateMixin
if "with SingleTickerProviderStateMixin" not in content:
    content = content.replace(
        "class _SearchScreenState extends ConsumerState<SearchScreen> {",
        "class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {"
    )

# Add TabController to state
if "late final TabController _tabController;" not in content:
    content = content.replace(
        "  final FocusNode _focusNode = FocusNode();",
        "  final FocusNode _focusNode = FocusNode();\n  late final TabController _tabController;"
    )
    
    # Initialize tab controller
    init_state_block = """  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);"""
    
    content = content.replace(
        """  @override
  void initState() {
    super.initState();""",
        init_state_block
    )
    
    # Dispose tab controller
    dispose_block = """  @override
  void dispose() {
    _tabController.dispose();"""
    content = content.replace(
        """  @override
  void dispose() {""",
        dispose_block
    )

# Add TabBar to SliverAppBar
tabbar_code = """
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  tabs: const [
                    Tab(text: 'Top'),
                    Tab(text: 'People'),
                    Tab(text: 'Stories'),
                    Tab(text: 'Journeys'),
                  ],
                ),"""

if "bottom: TabBar(" not in content:
    # We need to change toolbarHeight to accommodate TabBar, or let the appbar auto-size.
    # Current code:
    #                 toolbarHeight: 72,
    #                 title: Padding(...)
    # Let's just insert the bottom property right after the title: Padding(...)
    
    # The title property ends at the end of the Padding. Let's find a safe spot.
    content = content.replace(
        "                title: Padding(",
        tabbar_code + "\n                title: Padding("
    )
    # also remove toolbarHeight: 72 to allow it to expand automatically
    content = content.replace("                toolbarHeight: 72,", "")

with open("lib/features/search/presentation/screens/search_screen.dart", "w") as f:
    f.write(content)
