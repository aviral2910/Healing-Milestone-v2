with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "r") as f:
    content = f.read()

old_action = "if (widget.visibility != MilestoneVisibility.private &&\n                        widget.visibility != MilestoneVisibility.anonymous)"
new_action = "if (widget.visibility != MilestoneVisibility.private)"

content = content.replace(old_action, new_action)

# Wait, if there are different whitespaces, just do regex or a simpler replace
import re
content = re.sub(r'if \(widget\.visibility != MilestoneVisibility\.private &&\s*widget\.visibility != MilestoneVisibility\.anonymous\)', 
                 r'if (widget.visibility != MilestoneVisibility.private)', 
                 content)

with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "w") as f:
    f.write(content)
