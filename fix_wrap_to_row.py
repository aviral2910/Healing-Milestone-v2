import re

def fix_wrap_to_row(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # Find the Wrap block
    # Wrap(
    #   spacing: 8.0,
    #   runSpacing: 8.0,
    #   children: widget.categories!.map((cat) => Container(
    #      ...
    #   )).toList(),
    # )
    
    old_wrap = """Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: widget.categories!.map((cat) => Container("""
    new_scroll = """SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: widget.categories!.map((cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container("""
    
    content = content.replace(old_wrap, new_scroll)
    
    # We also need to add the closing tags for Padding and Row and SingleChildScrollView.
    # The original Wrap ended with:
    #       )).toList(),
    #     ),
    
    # We can just replace:
    old_end = """  )).toList(),
                            ),"""
    new_end = """  ),
                                )).toList(),
                              ),
                            ),"""
    content = content.replace(old_end, new_end)
    
    with open(filepath, "w") as f:
        f.write(content)

fix_wrap_to_row("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart")
fix_wrap_to_row("lib/features/journey/presentation/screens/journey_detail_screen.dart")

