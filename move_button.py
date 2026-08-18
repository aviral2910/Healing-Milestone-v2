with open('lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart', 'r') as f:
    lines = f.readlines()

new_lines = []
button_lines = []
in_button = False
brace_count = 0

# The button starts at `if (!widget.isMine)` on line 341.
# It ends around 385.
for line in lines:
    if "if (!widget.isMine)" in line and "SizedBox(" in lines[lines.index(line) + 1]:
        in_button = True
        button_lines.append(line)
        continue
        
    if in_button:
        button_lines.append(line)
        if "]," in line and "Row" not in line and "children" not in line: # We can't rely on this.
            pass
            
# Let's use a simpler string replace.
