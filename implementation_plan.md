# Comprehensive Professional Squircle Avatar Plan

This plan details how to implement the "square avatar" (squircle) for Professional and Organization users universally across the entire application frontend.

## The Logic Standard
We will tie the avatar shape explicitly to the **User Role** (Identity) rather than the content type. 
If `role == 'healthcareProfessional'` or `role.toLowerCase().contains('organi')`, the avatar will render as a Squircle (`BoxShape.rectangle` with rounded corners). Otherwise, it renders as a standard `BoxShape.circle`.

## Targeted Files & Widgets

### 1. The Core Data Models
For widgets like `WalkingWithScreen` and `CommentsThread` to render the squircle correctly, their backing models need to expose the author's role.
- **`lib/features/journey/data/models/journey_models.dart`**
  - Add `authorRole` to `JourneyModel`. (Wait, I need to check if the backend actually sends this. If not, I'll add it to the backend too).
- **`lib/features/milestone/data/models/comment_model.dart`**
  - Verify/add `authorRole`.

### 2. Milestone/Feed Views (Some already partially done)
- **`lib/features/journey/presentation/widgets/together_feed_card.dart`** (Already done, using `authorRole`)
- **`lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart`** (Already done, using `authorRole`)
- **`lib/shared/widgets/story_card.dart` & `swipe_story_card.dart`** 
  - Update `CircleAvatar` to use the squircle `Container` logic based on `milestone.authorRole`.
- **`lib/features/milestone/presentation/screens/story_detail_screen.dart`**
  - Update the author profile row at the top to use squircle.

### 3. Profile & User Lists
- **`lib/features/profile/presentation/screens/public_profile_screen.dart`**
  - Main profile picture at the top. Uses `targetUser.role`.
- **`lib/features/profile/presentation/screens/profile_screen.dart`** (Current user profile)
  - Uses `currentUser.role`.
- **`lib/features/profile/presentation/screens/edit_profile_screen.dart`**
  - Uses `currentUser.role`.
- **`lib/features/search/presentation/widgets/user_profile_card.dart`** & **`lib/features/profile/presentation/screens/user_list_screen.dart`**
  - Follower/following lists. Uses `user.role`.

### 4. Walking With Lists (Refactor)
- **`lib/features/journey/presentation/widgets/walking_with_carousel.dart`** & **`walking_with_screen.dart`**
  - Switch the condition from `journey.type != JourneyType.personal` to `journey.authorRole` (once added).

### 5. Comments & Chat
- **`lib/features/milestone/presentation/widgets/comments_thread.dart`**
  - Update comment avatars.
- **`lib/features/support_chat/presentation/screens/messages_screen.dart`** & **`chat_screen.dart`**
  - Update chat avatars in lists and message bubbles.

## Technical Implementation Details
Since writing the squircle `Container` logic repeatedly is extremely verbose and prone to duplication, I will create a reusable widget: `AppAvatar`.

```dart
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? role; // To determine shape
  final bool isAnonymous;
  final bool showRing;
  // ...
}
```
Replacing `CircleAvatar` with `AppAvatar` across the app will guarantee 100% universal consistency!
