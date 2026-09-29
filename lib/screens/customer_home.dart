import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../state/app_scope.dart';
import '../widgets/appointment_tile.dart';
import '../widgets/async_list.dart';
import '../widgets/home_actions.dart';
import 'provider_list_screen.dart';

/// Patient home: their appointments, upcoming first, and a "Book" button.
class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final upcoming = state.upcoming;
    final past = state.past;

    Widget tile(Appointment a) => AppointmentTile(
          appointment: a,
          otherParty: a.providerName,
          actions: [
            if (a.blocksSlot && a.start.isAfter(DateTime.now()))
              TextButton(
                onPressed: () =>
                    changeAppointmentStatus(context, a, AppointmentStatus.cancelled),
                child: Text(t.cancelAppointment),
              ),
          ],
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.greeting(state.profile?.name ?? '')),
        actions: homeActions(context),
      ),
      body: AsyncList(
        loading: state.appointmentsLoading,
        emptyMessage: t.noAppointmentsYet,
        emptyIcon: Icons.event_note,
        children: [
          if (upcoming.isNotEmpty) ...[
            SectionHeader(t.upcomingSection),
            for (final a in upcoming) tile(a),
          ],
          if (past.isNotEmpty) ...[
            SectionHeader(t.pastSection),
            for (final a in past) tile(a),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProviderListScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(t.book),
      ),
    );
  }
}
