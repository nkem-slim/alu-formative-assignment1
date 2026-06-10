import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(event: event),
            _CardBody(event: event),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final Event event;
  const _CardHeader({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: double.infinity,
      color: event.headerColor,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Background icon
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.event,
              size: 90,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          // Badges row
          Align(
            alignment: Alignment.topRight,
            child: Wrap(
              spacing: 6,
              children: [
                _Badge(
                  label: event.isPaid ? 'RWF ${event.price?.toInt()}' : 'Free',
                  color: event.isPaid ? AppColors.alert : AppColors.success,
                ),
                if (event.isOnCampus)
                  const _Badge(label: 'On Campus', color: AppColors.secondaryBlue),
                if (event.hasFood)
                  const _Badge(label: 'Food Provided', color: Color(0xFF7C5C00)),
              ],
            ),
          ),
          // Organizer at bottom
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              event.organizer,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final Event event;
  const _CardBody({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d - h:mm a').format(event.date);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.calendar_today_outlined, text: dateStr),
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.location_on_outlined, text: event.location),
          const Divider(height: 20),
          Row(
            children: [
              _Stat(icon: Icons.thumb_up_outlined, count: event.likes),
              const SizedBox(width: 16),
              _Stat(icon: Icons.thumb_down_outlined, count: event.dislikes),
              const SizedBox(width: 16),
              _Stat(icon: Icons.chat_bubble_outline, count: event.comments),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final int count;
  const _Stat({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
        ),
      ],
    );
  }
}
