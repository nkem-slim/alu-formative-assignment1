import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock_events.dart';
import '../../data/models/event_model.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paid = mockEvents.where((e) => e.isPaid).toList();
    final free = mockEvents.where((e) => e.isFree).toList();
    final onCampus = mockEvents.where((e) => e.isOnCampus).toList();
    final withFood = mockEvents.where((e) => e.hasFood).toList();

    return DefaultTabController(
      length: 4,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HomeHeader(),
            const SizedBox(height: 4),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              dividerColor: AppColors.border,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(text: 'Paid'),
                Tab(text: 'Free'),
                Tab(text: 'On Campus'),
                Tab(text: 'With Food'),
              ],
            ),
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
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Alex Johnson',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: const Text(
                  'AJ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search events...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<Event> events;
  const _EventList({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 56, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              'No events in this category',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

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
  }
}
