with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

old_container = """    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),"""

new_container = """    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),"""

content = content.replace(old_container, new_container)

with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
