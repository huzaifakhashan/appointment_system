import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../state/app_scope.dart';
import '../widgets/appointment_tile.dart';
import '../widgets/async_list.dart';
import '../widgets/home_actions.dart';
import 'provider_settings_screen.dart';

/// Doctor home: incoming requests and a calendar of their schedule.
class ProviderHome extends StatelessWidget {
  const ProviderHome({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final pendingCount = state.pending.length;
    final name = state.myProvider?.name ?? '';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name.isNotEmpty ? name : t.bookingsTitle),
          actions: homeActions(context, extra: [
            IconButton(
              tooltip: t.businessSettingsTooltip,
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProviderSettingsScreen()),
              ),
            ),
          ]),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.inbox),
                ),
                text: t.requestsTab,
              ),
              Tab(icon: const Icon(Icons.calendar_month), text: t.calendarTab),
            ],
          ),
        ),
        body: const TabBarView(children: [_RequestsTab(), _CalendarTab()]),
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    return AsyncList(
      loading: state.appointmentsLoading,
      emptyMessage: t.noPendingRequests,
      children: [
        for (final a in state.pending)
          AppointmentTile(
            appointment: a,
            otherParty: a.customerName,
            actions: [
              TextButton(
                onPressed: () => changeAppointmentStatus(context, a, AppointmentStatus.rejected),
                child: Text(t.reject),
              ),
              FilledButton(
                onPressed: () => changeAppointmentStatus(context, a, AppointmentStatus.confirmed),
                child: Text(t.confirm),
              ),
            ],
          ),
      ],
    );
  }
}

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Column(
      children: [
        TableCalendar<Appointment>(
          locale: locale,
          firstDay: now.subtract(const Duration(days: 365)),
          lastDay: now.add(const Duration(days: 365)),
          focusedDay: _focused,
          selectedDayPredicate: (d) => isSameDay(d, _selected),
          eventLoader: state.onDay,
          calendarFormat: CalendarFormat.month,
          // Arabic calendars usually start the week on Saturday.
          startingDayOfWeek: locale.startsWith('ar')
              ? StartingDayOfWeek.saturday
              : StartingDayOfWeek.sunday,
          daysOfWeekHeight: 28,
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.labelSmall!,
            weekendStyle: theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.outline),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          availableCalendarFormats: {CalendarFormat.month: t.calendarTab},
          onDaySelected: (selected, focused) => setState(() {
            _selected = selected;
            _focused = focused;
          }),
          onPageChanged: (focused) => _focused = focused,
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(DateFormat.MMMMEEEEd(locale).format(_selected),
                style: theme.textTheme.titleMedium),
          ),
        ),
        Expanded(
          child: AsyncList(
            loading: state.appointmentsLoading,
            emptyMessage: t.nothingScheduled,
            emptyIcon: Icons.event_available,
            children: [
              for (final a in state.onDay(_selected))
                AppointmentTile(
                  appointment: a,
                  otherParty: a.customerName,
                  actions: [
                    if (a.status == AppointmentStatus.confirmed && a.start.isAfter(now))
                      TextButton(
                        onPressed: () =>
                            changeAppointmentStatus(context, a, AppointmentStatus.cancelled),
                        child: Text(t.cancelAppointment),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
