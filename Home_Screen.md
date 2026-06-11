# Home Screen — Widget-by-Widget Breakdown

This document explains every widget, class, and piece of logic in the Home Screen flow of the ALU Link app. It covers four files: the bottom navigation shell, the home screen itself, the event card widget, the event detail page, and the event registration page.

---

## Table of Contents

1. [Data Layer — Event Model](#1-data-layer--event-model)
2. [Main Shell — Bottom Navigation](#2-main-shell--bottom-navigation)
3. [Home Screen](#3-home-screen)
   - [HomeScreen widget](#homescreen-widget)
   - [\_HomeHeader widget](#_homeheader-widget)
   - [\_EventList widget](#_eventlist-widget)
4. [Event Card](#4-event-card)
   - [EventCard widget](#eventcard-widget)
   - [\_CardHeader widget](#_cardheader-widget)
   - [\_Badge widget](#_badge-widget)
   - [\_CardBody widget](#_cardbody-widget)
   - [\_InfoRow widget](#_inforow-widget)
   - [\_Stat widget](#_stat-widget)
5. [Event Detail Screen](#5-event-detail-screen)
   - [EventDetailScreen widget](#eventdetailscreen-widget)
   - [State variables and logic](#state-variables-and-logic)
   - [\_onLike and \_onDislike](#_onlike-and-_ondislike)
   - [\_shareToWhatsApp](#_sharetowhatsapp)
   - [\_contactOrganizer](#_contactorganizer)
   - [\_EventSliverAppBar widget](#_eventsliverappbar-widget)
   - [\_Chip widget](#_chip-widget)
   - [\_InfoCard widget](#_infocard-widget)
   - [\_DetailRow widget](#_detailrow-widget)
   - [\_ReactionRow widget](#_reactionrow-widget)
   - [\_ReactionButton widget](#_reactionbutton-widget)
   - [Action Buttons](#action-buttons)
6. [Event Registration Screen](#6-event-registration-screen)
   - [EventRegisterScreen widget](#eventregisterscreen-widget)
   - [Form state and controllers](#form-state-and-controllers)
   - [\_submit method](#_submit-method)
   - [\_SuccessDialog widget](#_successdialog-widget)
7. [Navigation Flow Summary](#7-navigation-flow-summary)

---

## 1. Data Layer — Event Model

**File:** `lib/features/home/data/models/event_model.dart`

The `Event` class is the single source of truth for what an event looks like across the entire Home flow. Every card, detail screen, and registration screen reads from this same object.

```dart
class Event {
  final String id;
  final String title;
  final String organizer;
  final String organizerEmail;
  final DateTime date;
  final String location;
  final String description;
  final bool isPaid;
  final double? price;
  final bool isOnCampus;
  final bool hasFood;
  final int likes;
  final int dislikes;
  final int comments;
  final Color headerColor;

  bool get isFree => !isPaid;
}
```

### What each field does

| Field | Type | Purpose |
|---|---|---|
| `id` | `String` | Unique identifier. Used to look up a specific event (ready for real API). |
| `title` | `String` | Event name. Shown on both card and detail page. |
| `organizer` | `String` | Name of the person or club running the event. |
| `organizerEmail` | `String` | Used by the "Contact Organizer" button to open an email draft. |
| `date` | `DateTime` | Full date and time. Formatted differently on the card vs. the detail page. |
| `location` | `String` | Venue text. Shown on card and detail page. |
| `description` | `String` | Long text shown only on the detail page under "About this Event". |
| `isPaid` | `bool` | Controls which tab the event appears in and what badge is shown. Defaults to `false`. |
| `price` | `double?` | Optional. Only shown when `isPaid` is `true`. Written in RWF. |
| `isOnCampus` | `bool` | Controls whether the event appears in the "On Campus" tab and shows that badge. |
| `hasFood` | `bool` | Controls the "With Food" tab and the food badge. |
| `likes` | `int` | Starting like count. This is the base — user actions add or subtract from it locally. |
| `dislikes` | `int` | Starting dislike count. Same pattern as likes. |
| `comments` | `int` | Comment count. Displayed only — not interactive in this version. |
| `headerColor` | `Color` | Each event has one color used for its card header and the detail page banner. |
| `isFree` (getter) | `bool` | Computed shortcut. Returns `!isPaid`. Used to filter the Free tab. |

### Tab filtering logic

An event can appear in **multiple tabs at once** because the tabs filter independently:

```dart
final paid     = mockEvents.where((e) => e.isPaid).toList();
final free     = mockEvents.where((e) => e.isFree).toList();
final onCampus = mockEvents.where((e) => e.isOnCampus).toList();
final withFood = mockEvents.where((e) => e.hasFood).toList();
```

For example, a free on-campus event with food would appear in three tabs (Free, On Campus, With Food).

---

## 2. Main Shell — Bottom Navigation

**File:** `lib/main_shell.dart`

`MainShell` is the root widget that holds the entire app's navigation structure. It is a `StatefulWidget` because it needs to track which tab is currently selected.

### `MainShell` (StatefulWidget)

```dart
class MainShell extends StatefulWidget { ... }
```

- A `StatefulWidget` is used here because we need to store `_currentIndex` — the currently active tab. When this number changes, the whole screen switches.

### `_MainShellState` (State)

```dart
int _currentIndex = 0;

final List<Widget> _screens = const [
  HomeScreen(),
  EventsScreen(),
  MyEventsScreen(),
  ProfileScreen(),
];
```

- `_currentIndex` starts at `0`, meaning the Home tab is active when the app opens.
- `_screens` is a list of all four main screens. The active one is shown by indexing into this list: `body: _screens[_currentIndex]`.

### `Scaffold`

```dart
return Scaffold(
  backgroundColor: AppColors.background,
  body: _screens[_currentIndex],
  bottomNavigationBar: NavigationBar(...),
);
```

- The `Scaffold` provides the overall page structure.
- `body` shows whichever screen matches `_currentIndex`. When you tap a nav item, `_currentIndex` changes and Flutter rebuilds — showing the new screen.
- `backgroundColor` is set to the cream color (`#FFF9EF`) from the app's theme so it matches the content of each screen.

### `NavigationBar`

```dart
NavigationBar(
  onDestinationSelected: (int index) {
    setState(() => _currentIndex = index);
  },
  indicatorColor: AppColors.accent,   // golden yellow highlight
  selectedIndex: _currentIndex,
  backgroundColor: AppColors.surface, // white bar
  surfaceTintColor: Colors.transparent,
  elevation: 8,
  destinations: [...],
)
```

- `onDestinationSelected` fires whenever a user taps a navigation item. The index (0–3) is passed in, and `setState` updates `_currentIndex`, causing a rebuild that swaps the body.
- `indicatorColor: AppColors.accent` puts a golden yellow pill behind the active icon.
- `surfaceTintColor: Colors.transparent` prevents Material 3 from tinting the nav bar with the primary color.

### `NavigationDestination` (each tab)

```dart
NavigationDestination(
  selectedIcon: Icon(Icons.home, color: AppColors.primary),
  icon: Icon(Icons.home_outlined),
  label: 'Home',
),
```

- `selectedIcon` is shown when this tab is active — a filled icon with the dark navy primary color.
- `icon` is shown when inactive — an outlined version of the same icon, which gives a subtle visual difference.
- `label` appears as text below the icon.

The four tabs are: **Home**, **Events**, **My Events**, **Profile**.

---

## 3. Home Screen

**File:** `lib/features/home/presentation/screens/home_screen.dart`

### `HomeScreen` widget

```dart
class HomeScreen extends StatelessWidget { ... }
```

`HomeScreen` is a `StatelessWidget` — it has no internal state of its own. All the data it needs (the mock events) comes from the `mockEvents` list, and the tab selection is managed by `DefaultTabController` which Flutter handles automatically.

```dart
return DefaultTabController(
  length: 4,
  child: SafeArea(
    child: Column(
      children: [
        const _HomeHeader(),
        const SizedBox(height: 4),
        TabBar(...),
        Expanded(
          child: TabBarView(
            children: [
              _EventList(events: paid),
              _EventList(events: free),
              _EventList(events: onCampus),
              _EventList(events: withFood),
            ],
          ),
        ),
      ],
    ),
  ),
);
```

- **`DefaultTabController`** wraps everything and automatically wires the `TabBar` to the `TabBarView`. You pass `length: 4` to tell it there are four tabs. You never have to manage tab switching manually — Flutter does it.
- **`SafeArea`** pushes content down below the phone's status bar and notch.
- **`Column`** stacks the header, tab bar, and tab content vertically.
- **`Expanded`** makes the `TabBarView` fill all remaining vertical space below the tab bar. Without this, the `TabBarView` has no height and would not render.

### `TabBar`

```dart
TabBar(
  isScrollable: true,
  tabAlignment: TabAlignment.start,
  labelColor: AppColors.primary,
  unselectedLabelColor: AppColors.textMuted,
  indicatorColor: AppColors.accent,
  indicatorWeight: 3,
  dividerColor: AppColors.border,
  tabs: const [
    Tab(text: 'Paid'),
    Tab(text: 'Free'),
    Tab(text: 'On Campus'),
    Tab(text: 'With Food'),
  ],
)
```

- `isScrollable: true` allows the tabs to scroll horizontally if the screen is narrow. Without this, all four labels would be compressed.
- `tabAlignment: TabAlignment.start` pins the tabs to the left instead of distributing them across the full width.
- The active tab label uses `AppColors.primary` (dark navy) and the inactive tabs use `AppColors.textMuted` (grey).
- `indicatorColor: AppColors.accent` puts a golden yellow underline on the selected tab.

### `_HomeHeader` widget

The private `_HomeHeader` class builds the top section of the home screen — the greeting row and the search bar.

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text('Good morning', ...),
              Text('Alex Johnson', ...),
            ],
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Text('AJ', ...),
          ),
        ],
      ),
      SizedBox(height: 16),
      TextField(
        decoration: InputDecoration(
          hintText: 'Search events...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    ],
  ),
)
```

- The outer `Padding` gives 20px left/right/top margins and 12px at the bottom.
- The top `Row` has `MainAxisAlignment.spaceBetween` — this pushes the greeting text to the left and the avatar to the right.
- **`CircleAvatar`** shows the user's initials ("AJ") on a dark navy background. This will eventually be replaced with a real profile image from the auth system.
- **`TextField`** is the search bar. At this stage it is visual only — it does not filter the event list yet. The `prefixIcon` adds the magnifying glass on the left of the input.

> **To connect auth:** Replace the hardcoded `'Good morning'` and `'Alex Johnson'` with data from the logged-in user object once the auth feature is built.

### `_EventList` widget

```dart
class _EventList extends StatelessWidget {
  final List<Event> events;
  const _EventList({required this.events});
  ...
}
```

This is the content of each tab. It receives a pre-filtered list of `Event` objects.

**Empty state:**
```dart
if (events.isEmpty) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.event_busy, size: 56, color: AppColors.border),
        Text('No events in this category'),
      ],
    ),
  );
}
```
- If no events match that tab's filter, a centred icon and message are shown instead of an empty white screen.

**Populated state:**
```dart
return ListView.separated(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
  itemCount: events.length,
  separatorBuilder: (_, _) => const SizedBox(height: 12),
  itemBuilder: (context, index) {
    final event = events[index];
    return EventCard(
      event: event,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(event: event),
        ),
      ),
    );
  },
);
```

- **`ListView.separated`** builds items lazily — it only creates the widgets for the cards currently visible on screen, not all of them at once. This is efficient for long lists.
- **`separatorBuilder`** inserts a 12px gap between every card.
- **`itemBuilder`** is called once per event. It creates an `EventCard` and passes the `event` object and an `onTap` callback.
- **`onTap`** calls `Navigator.push` with a `MaterialPageRoute`. This pushes `EventDetailScreen` on top of the current screen, passing the full `event` object so the detail page has all the data it needs without any extra network call.

---

## 4. Event Card

**File:** `lib/features/home/presentation/widgets/event_card.dart`

The `EventCard` is the rectangular card shown in each tab. It is split into a private header section and a private body section.

### `EventCard` widget

```dart
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _CardHeader(event: event),
            _CardBody(event: event),
          ],
        ),
      ),
    );
  }
}
```

- **`GestureDetector`** wraps the entire card and fires the `onTap` callback (which navigates to detail) when the user taps anywhere on the card.
- **`Card`** provides the white background, rounded corners, and elevation shadow as defined in `AppTheme`.
- **`clipBehavior: Clip.antiAlias`** ensures the colored header banner respects the card's rounded corners. Without this, the color would bleed outside the rounded edges.
- The card is a `Column` with two children: header on top, body below.

### `_CardHeader` widget

```dart
Container(
  height: 110,
  width: double.infinity,
  color: event.headerColor,
  padding: const EdgeInsets.all(16),
  child: Stack(
    children: [
      // 1. Background icon (decorative)
      Positioned(right: -10, bottom: -10, child: Icon(Icons.event, size: 90, ...)),
      // 2. Badges in top-right
      Align(alignment: Alignment.topRight, child: Wrap(children: [...])),
      // 3. Organizer name at bottom-left
      Align(alignment: Alignment.bottomLeft, child: Text(event.organizer, ...)),
    ],
  ),
)
```

- The `Container` is 110px tall and stretches to the full card width. Its background is `event.headerColor` — each event has its own color defined in the mock data.
- **`Stack`** allows three things to be layered on top of each other within the same space.
  - **Layer 1 (bottom):** A large, faint `Icons.event` icon positioned at the bottom-right corner. The `alpha: 0.12` makes it 12% opaque — visible but subtle, purely decorative.
  - **Layer 2 (middle):** A `Wrap` of `_Badge` widgets aligned to the top-right. `Wrap` automatically moves badges to a new line if they don't all fit horizontally.
  - **Layer 3 (top):** The organizer's name at the bottom-left, in white70 (semi-transparent white text).

### `_Badge` widget

```dart
class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: Colors.white, ...)),
    );
  }
}
```

A small pill-shaped label. The background color is the full badge color (solid, not transparent like on the detail page). Three badges can appear:

| Badge | Color | Condition |
|---|---|---|
| `Free` or `RWF 15000` | Green / Red-orange | Always shown — green if free, orange if paid |
| `On Campus` | Secondary blue | Only if `event.isOnCampus == true` |
| `Food Provided` | Brown | Only if `event.hasFood == true` |

### `_CardBody` widget

```dart
final dateStr = DateFormat('EEE, MMM d - h:mm a').format(event.date);
// Example output: "Tue, Jul 15 - 9:00 AM"

return Padding(
  padding: const EdgeInsets.all(14),
  child: Column(
    children: [
      Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      SizedBox(height: 8),
      _InfoRow(icon: Icons.calendar_today_outlined, text: dateStr),
      SizedBox(height: 4),
      _InfoRow(icon: Icons.location_on_outlined, text: event.location),
      Divider(height: 20),
      Row(
        children: [
          _Stat(icon: Icons.thumb_up_outlined, count: event.likes),
          _Stat(icon: Icons.thumb_down_outlined, count: event.dislikes),
          _Stat(icon: Icons.chat_bubble_outline, count: event.comments),
          Spacer(),
          Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    ],
  ),
);
```

- The `intl` package's `DateFormat` formats the `DateTime` into a readable string. The format string `'EEE, MMM d - h:mm a'` means: short weekday, short month, day number, hour, minutes, AM/PM.
- `maxLines: 2` and `TextOverflow.ellipsis` prevent long event titles from breaking the card layout — they truncate with `...` after two lines.
- **`Divider`** draws a subtle horizontal line separating the info rows from the stats footer.
- **`Spacer()`** pushes the arrow icon to the far right, giving a "tap to open" visual hint.

### `_InfoRow` widget

```dart
Row(
  children: [
    Icon(icon, size: 14, color: AppColors.textMuted),
    SizedBox(width: 6),
    Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)),
  ],
)
```

A reusable one-line row with an icon on the left and text on the right. `Expanded` ensures the text fills available space and truncates with `...` if it is too long — preventing overflow on narrow screens.

### `_Stat` widget

```dart
Row(
  children: [
    Icon(icon, size: 15),
    SizedBox(width: 4),
    Text(count.toString()),
  ],
)
```

A mini icon + number pair. Used three times in the card footer: once for likes, once for dislikes, once for comments. The count comes directly from the `Event` object (it is not interactive on the card — only on the detail screen).

---

## 5. Event Detail Screen

**File:** `lib/features/home/presentation/screens/event_detail_screen.dart`

### `EventDetailScreen` widget

```dart
class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});
}
```

This is a `StatefulWidget` because the like and dislike counts change when the user taps them — that is local UI state that needs to trigger a rebuild.

The screen uses a `CustomScrollView` with `SliverAppBar` + `SliverToBoxAdapter`. This is what allows the coloured banner at the top to collapse into a normal app bar as the user scrolls down.

### State variables and logic

```dart
late int _likes;
late int _dislikes;
bool _likedByUser = false;
bool _dislikedByUser = false;

@override
void initState() {
  super.initState();
  _likes = widget.event.likes;
  _dislikes = widget.event.dislikes;
}
```

- `_likes` and `_dislikes` are initialised from the event data in `initState`. They are declared as `late` because they cannot be assigned a value before `widget` is available.
- `_likedByUser` and `_dislikedByUser` track whether the current user has reacted. They start as `false`.
- These are **local state only** — they reset if you leave and come back to the screen. When connected to a backend, you would load the user's existing reaction from an API.

### `_onLike` and `_onDislike`

```dart
void _onLike() {
  setState(() {
    if (_likedByUser) {
      // User already liked — undo it
      _likes--;
      _likedByUser = false;
    } else {
      // New like
      _likes++;
      _likedByUser = true;
      // Remove dislike if one was active
      if (_dislikedByUser) {
        _dislikes--;
        _dislikedByUser = false;
      }
    }
  });
}
```

This implements a **toggle-with-switch** pattern:
- If the user has not liked yet → add a like.
- If the user has already liked → remove the like (toggle off).
- If the user had disliked and then likes → the dislike is removed automatically. You cannot have both reactions at the same time.

`_onDislike` is the exact mirror of this logic for dislikes.

`setState(...)` is called so Flutter knows the numbers changed and re-renders the `_ReactionRow` widget.

### `_shareToWhatsApp`

```dart
Future<void> _shareToWhatsApp() async {
  final message = '🎉 *${event.title}*\n $dateStr\n ${event.location}\nOrganized by: ...\n\nCheck it out on ALU Link!';
  final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WhatsApp is not installed on this device.')),
    );
  }
}
```

- **`whatsapp://send?text=...`** is the deep link scheme that opens the WhatsApp app's sharing sheet with the message pre-filled. The user can then choose which contact or group to share to.
- **`Uri.encodeComponent`** converts special characters (spaces, emojis, newlines) into URL-safe format so the deep link is valid.
- **`canLaunchUrl`** checks first whether WhatsApp is installed. If it is not (e.g., running on an emulator or a device without WhatsApp), the SnackBar shows an error message instead of crashing.
- The `*text*` markdown syntax in the message renders as **bold** inside WhatsApp.

> **Android note:** For `canLaunchUrl` to detect WhatsApp on Android, you must add to `android/app/src/main/AndroidManifest.xml`:
> ```xml
> <queries>
>   <package android:name="com.whatsapp" />
> </queries>
> ```

### `_contactOrganizer`

```dart
Future<void> _contactOrganizer() async {
  final uri = Uri(
    scheme: 'mailto',
    path: widget.event.organizerEmail,
    query: 'subject=Question about ${Uri.encodeComponent(widget.event.title)}',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
```

- **`mailto:`** is a standard URI scheme that opens the device's default email app.
- The `path` sets the recipient email and `query` pre-fills the subject line.
- `canLaunchUrl` checks if an email app is available before trying to open it.

### `_EventSliverAppBar` widget

```dart
SliverAppBar(
  expandedHeight: 200,
  pinned: true,
  backgroundColor: event.headerColor,
  foregroundColor: Colors.white,
  flexibleSpace: FlexibleSpaceBar(
    background: Container(
      color: event.headerColor,
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Icon(Icons.event, size: 180, color: Colors.white.withValues(alpha: 0.1)),
          ),
        ],
      ),
    ),
  ),
)
```

- **`SliverAppBar`** is a special app bar that works inside a `CustomScrollView`. It collapses as the user scrolls down.
- `expandedHeight: 200` means the banner is 200px tall when fully expanded (at the top of the page).
- `pinned: true` keeps the collapsed app bar visible at the top with the back button as you scroll — without this it would scroll off screen.
- **`FlexibleSpaceBar`** holds the large banner content that shrinks as you scroll.
- The same faint large icon used in the card header is reused here at a larger size (180px).

### `_Chip` widget

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withValues(alpha: 0.4)),
  ),
  child: Text(label, style: TextStyle(color: color, ...)),
)
```

The detail page uses a different style of badge than the card — here the background is a **tinted transparent version** of the badge color (12% opacity fill, 40% opacity border, full-color text). This is more subtle and appropriate for a detail view. The card uses fully solid badges because they are small and need to stand out on a colored background.

### `_InfoCard` widget

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.surface,       // white
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border),
  ),
  child: Column(children: children),
)
```

A white rounded container that groups related info rows (organizer, date, time, location) together visually. `children` is a `List<Widget>` passed in from the parent — it holds the `_DetailRow` items and `Divider` separators between them.

### `_DetailRow` widget

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Icon(icon, size: 18, color: AppColors.primary),
    SizedBox(width: 12),
    Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    ),
  ],
)
```

Each detail row has three parts: a primary-colored icon on the left, a small grey label above (`'Organizer'`, `'Date'`, etc.), and the actual value in larger text below. `CrossAxisAlignment.start` aligns everything to the top.

### `_ReactionRow` widget

```dart
Container(
  padding: ...,
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _ReactionButton(icon: ..., count: likes, active: likedByUser, activeColor: AppColors.success, onTap: onLike),
      Container(width: 1, height: 28, color: AppColors.border),  // vertical divider
      _ReactionButton(icon: ..., count: dislikes, active: dislikedByUser, activeColor: AppColors.alert, onTap: onDislike),
      Container(width: 1, height: 28, color: AppColors.border),  // vertical divider
      Row(children: [Icon(Icons.chat_bubble_outline), Text('$comments comments')]),
    ],
  ),
)
```

- A white pill-shaped container that holds all three reaction elements side by side.
- The `Container(width: 1, height: 28)` widgets are manual vertical dividers drawn as thin lines between the three sections.
- `MainAxisAlignment.spaceAround` distributes the three sections evenly.
- The comments section is read-only (no `onTap`) — tapping comments is not implemented in this version.

### `_ReactionButton` widget

```dart
GestureDetector(
  onTap: onTap,
  child: Row(
    children: [
      Icon(icon, size: 20, color: color),
      SizedBox(width: 6),
      Text(count.toString(), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    ],
  ),
)
```

- `color` is computed as: `active ? activeColor : AppColors.textMuted`. When active (user has reacted), both the icon and the count text switch to the active color (green for like, orange-red for dislike). When inactive, both are grey.
- The icon itself also changes: `likedByUser ? Icons.thumb_up : Icons.thumb_up_outlined` — a filled icon when active, outlined when inactive.
- `GestureDetector` fires the `onTap` callback, which calls `_onLike` or `_onDislike` in the parent state.

### Action Buttons

The detail screen has three action buttons at the bottom:

#### Contact Organizer button
```dart
OutlinedButton.icon(
  onPressed: _contactOrganizer,
  icon: Icon(Icons.mail_outline),
  label: Text('Contact Organizer'),
  style: OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    foregroundColor: AppColors.primary,
    side: BorderSide(color: AppColors.border),
    ...
  ),
)
```
- `OutlinedButton` — a button with no fill, just a border. Used for secondary actions.
- `minimumSize: Size.fromHeight(48)` makes the button stretch to full width and be at least 48px tall.
- Tapping calls `_contactOrganizer` which opens the mail app.

#### Share to WhatsApp button
```dart
OutlinedButton.icon(
  onPressed: _shareToWhatsApp,
  icon: Icon(Icons.share_outlined),
  label: Text('Share to WhatsApp'),
  style: OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF25D366),   // WhatsApp green
    side: BorderSide(color: Color(0xFF25D366)),
    ...
  ),
)
```
- `#25D366` is WhatsApp's official brand green, used for both the border and icon/text color.
- Tapping calls `_shareToWhatsApp` which opens WhatsApp with a pre-filled message.

#### Register button
```dart
ElevatedButton.icon(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EventRegisterScreen(event: event),
    ),
  ),
  icon: Icon(Icons.how_to_reg_outlined),
  label: Text('Register for This Event'),
  style: ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    backgroundColor: AppColors.accent,    // golden yellow
    foregroundColor: AppColors.primary,   // dark navy text
    ...
  ),
)
```
- `ElevatedButton` — a filled button. Used for the primary call-to-action.
- Tapping pushes `EventRegisterScreen` onto the navigation stack, passing the same `event` object.
- The golden yellow background with dark navy text is the app's primary action style as defined in `AppTheme`.

---

## 6. Event Registration Screen

**File:** `lib/features/home/presentation/screens/event_register_screen.dart`

### `EventRegisterScreen` widget

```dart
class EventRegisterScreen extends StatefulWidget {
  final Event event;
  ...
}
```

A `StatefulWidget` because it manages three `TextEditingController`s and a `_isSubmitting` boolean that controls the loading state of the submit button.

The screen structure:
1. **AppBar** — title "Register for Event" with a border at the bottom
2. **Event summary card** — reminds the user which event they are registering for
3. **Paid warning banner** — only shown if the event is paid
4. **Form** — three fields + submit button

### Form state and controllers

```dart
final _formKey = GlobalKey<FormState>();
final _nameController = TextEditingController(text: 'Alex Johnson');
final _emailController = TextEditingController(text: 'alex.johnson@alueducation.com');
final _phoneController = TextEditingController();
bool _isSubmitting = false;
```

- **`GlobalKey<FormState>`** is how Flutter identifies the `Form` widget so you can call `.validate()` on it programmatically.
- **`TextEditingController`** holds the current text in each field. The name and email are pre-filled with mock user data — when auth is added, these will come from the logged-in user's profile.
- **`dispose()`** is overridden to call `.dispose()` on all three controllers when the screen is removed from the stack. This releases the memory they held. Not disposing controllers is a common Flutter memory leak.

### `_submit` method

```dart
Future<void> _submit() async {
  // 1. Validate all form fields
  if (!_formKey.currentState!.validate()) return;

  // 2. Show loading spinner on button
  setState(() => _isSubmitting = true);

  // 3. Simulate an API call (1 second delay)
  await Future.delayed(const Duration(seconds: 1));

  // 4. Hide spinner
  setState(() => _isSubmitting = false);

  // 5. Safety check — screen might have been closed during the await
  if (!mounted) return;

  // 6. Show success dialog
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _SuccessDialog(event: widget.event),
  );

  // 7. After dialog is dismissed — pop the register screen
  if (mounted) {
    Navigator.of(context).pop();
  }
}
```

Step-by-step:
1. **Validate** — Flutter calls the `validator` function of each `TextFormField`. If any returns an error string, the form shows inline errors and `validate()` returns `false`, stopping submission.
2. **Loading state** — `_isSubmitting = true` triggers a rebuild. The button's `onPressed` is `null` when `_isSubmitting` is true, disabling it so the user cannot tap twice.
3. **Simulated API call** — `Future.delayed` mimics a network request. Replace with a real API call here.
4. **Reset loading** — re-enable the button.
5. **`if (!mounted)`** — after any `await`, the widget might have been disposed (user navigated away). This guard prevents calling `setState` or `context` on a dead widget.
6. **`barrierDismissible: false`** — the user cannot dismiss the success dialog by tapping outside it. They must press the "Done" button.
7. **Pop** — returns the user to the Event Detail screen after they dismiss the dialog.

### Submit button — loading vs normal state

```dart
ElevatedButton(
  onPressed: _isSubmitting ? null : _submit,
  child: _isSubmitting
      ? const SizedBox(
          height: 20, width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        )
      : const Text('Confirm Registration'),
)
```

- `onPressed: null` is Flutter's way of making a button appear and act as disabled.
- When `_isSubmitting` is `true`, the button label is replaced by a small `CircularProgressIndicator` (a spinner). When `false`, the normal text is shown.

### `_SuccessDialog` widget

```dart
AlertDialog(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_circle, color: AppColors.success, size: 40),
      ),
      Text('You\'re registered!'),
      Text('Your spot for ${event.title} has been confirmed...'),
      ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Done'),
      ),
    ],
  ),
)
```

- **`AlertDialog`** is Flutter's built-in modal dialog widget. It automatically dims the background.
- `mainAxisSize: MainAxisSize.min` makes the dialog only as tall as its content rather than full screen height.
- The green circle icon is a `BoxShape.circle` container with a tinted background and a filled check icon in the center.
- The "Done" button calls `Navigator.of(context).pop()` which closes only the dialog. The `_submit` method then pops the register screen as well, returning the user to the event detail page.

---

## 7. Navigation Flow Summary

```
App Launch
└── MainShell (Scaffold + NavigationBar)
    └── HomeScreen [Tab 0]  ← default screen
        ├── _HomeHeader
        │   ├── Greeting text + avatar
        │   └── Search TextField
        ├── TabBar (Paid / Free / On Campus / With Food)
        └── TabBarView
            └── _EventList (filtered per tab)
                └── EventCard (per event)
                    ├── _CardHeader (colored banner + badges)
                    └── _CardBody (title, date, location, stats)
                        └── onTap → Navigator.push
                                    └── EventDetailScreen
                                        ├── _EventSliverAppBar (collapsing banner)
                                        ├── _Chip badges
                                        ├── Event title
                                        ├── _InfoCard
                                        │   ├── _DetailRow: Organizer
                                        │   ├── _DetailRow: Date
                                        │   ├── _DetailRow: Time
                                        │   └── _DetailRow: Location
                                        ├── Description text
                                        ├── _ReactionRow
                                        │   ├── _ReactionButton (Like)   ← toggles with state
                                        │   ├── _ReactionButton (Dislike) ← toggles with state
                                        │   └── Comment count (read-only)
                                        ├── Contact Organizer button → mailto: URI
                                        ├── Share to WhatsApp button → whatsapp:// URI
                                        └── Register button → Navigator.push
                                                              └── EventRegisterScreen
                                                                  ├── Event summary card
                                                                  ├── Paid warning (conditional)
                                                                  ├── Form (Name, Email, Phone)
                                                                  └── Submit button
                                                                      └── _SuccessDialog → pop → pop
```

### Key patterns used throughout

| Pattern | Where used | Why |
|---|---|---|
| `StatelessWidget` | `HomeScreen`, `EventCard`, all sub-widgets | No state to manage — rebuilds only when parent changes |
| `StatefulWidget` | `MainShell`, `EventDetailScreen`, `EventRegisterScreen` | Needs local state: tab index, like counts, form state |
| `Navigator.push` | `_EventList` → Detail, Detail → Register | Adds a new screen on top of the stack with a back button automatically |
| `Navigator.pop` | After dialog dismiss in `_submit` | Removes the current screen and returns to the previous one |
| `DefaultTabController` | `HomeScreen` | Automatically wires a `TabBar` to a `TabBarView` without manual index tracking |
| `CustomScrollView` + `SliverAppBar` | `EventDetailScreen` | Makes the header banner collapse into a regular app bar as user scrolls |
| `ListView.separated` | `_EventList` | Lazy rendering — only builds visible cards, not all at once |
| `Future.delayed` | `_submit` | Placeholder for a real API call — replace with HTTP request |
| `if (!mounted)` guard | `_submit` | Prevents setState on a widget that was removed during an async operation |
| `TextEditingController.dispose()` | `EventRegisterScreen` | Memory management — releases resources when screen is removed |
