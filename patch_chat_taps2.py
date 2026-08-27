import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Fix the missing parenthesis at the end of _buildSharedCard
old_end_card = """            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }"""
new_end_card = """            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ));
  }"""
content = content.replace(old_end_card, new_end_card)

# Fix the missing parenthesis at the end of _buildSharedProfileCard
old_end_profile = """        },
        loading: () => _buildShimmerBox(context, double.infinity, 60, radius: 12),
        error: (_, __) => const Text('Error loading profile'),
      ),
    );
  }"""
new_end_profile = """        },
        loading: () => _buildShimmerBox(context, double.infinity, 60, radius: 12),
        error: (_, __) => const Text('Error loading profile'),
      ),
    ));
  }"""
content = content.replace(old_end_profile, new_end_profile)

# Fix JourneyDetailScreen and StoryDetailScreen arguments
old_taps = """        if (isJourney) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => JourneyDetailScreen(journeyId: id)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailScreen(storyId: id)));
        }"""
new_taps = """        if (isJourney) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => JourneyDetailScreen(journeyId: id, title: title ?? 'Shared Journey')));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailScreen(milestoneId: id)));
        }"""
content = content.replace(old_taps, new_taps)


with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
