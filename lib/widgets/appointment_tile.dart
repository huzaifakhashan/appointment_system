import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../state/app_scope.dart';
import '../utils/service_names.dart';
import 'dialogs.dart';
import 'feedback.dart';

/// Changes an appointment's status, asking first for the changes that can't
/// be undone (cancelling or declining).
Future<void> changeAppointmentStatus(
    BuildContext context, Appointment a, AppointmentStatus status) async {
  final t = AppLocalizations.of(context)!;
  final state = AppScope.of(context);
  final Future<bool> ask = switch (status) {
    AppointmentStatus.cancelled => showConfirmDialog(
        context,
        title: t.confirmCancelAppointmentTitle,
        body: t.confirmCancelAppointmentBody,
        confirmLabel: t.cancelAppointment,
        cancelLabel: t.keepAppointment,
      ),
    AppointmentStatus.rejected => showConfirmDialog(
        context,
        title: t.confirmRejectTitle,
        body: '${a.customerName} · ${a.serviceDisplay(t)}',
        confirmLabel: t.reject,
      ),
    _ => Future.value(true),
  };
  if (!await ask || !context.mounted) return;
  await runWithFeedback(
    context,
    () => state.setStatus(a, status),
    success: status == AppointmentStatus.cancelled ? t.appointmentCancelled : null,
  );
}

Color statusColor(AppointmentStatus s) => switch (s) {
      AppointmentStatus.pending => Colors.orange.shade800,
      AppointmentStatus.confirmed => Colors.green.shade700,
      AppointmentStatus.rejected => Colors.red.shade700,
      AppointmentStatus.cancelled => Colors.grey.shade600,
    };

String statusLabel(AppLocalizations t, AppointmentStatus s) => switch (s) {
      AppointmentStatus.pending => t.statusPending,
      AppointmentStatus.confirmed => t.statusConfirmed,
      AppointmentStatus.rejected => t.statusRejected,
      AppointmentStatus.cancelled => t.statusCancelled,
    };

/// One appointment as a card: who/what, when, status, note, and actions.
class AppointmentTile extends StatelessWidget {
  const AppointmentTile({
    super.key,
    required this.appointment,
    required this.otherParty,
    this.actions = const [],
  });

  final Appointment appointment;
  /// The other side of the booking: the patient's name in a doctor's view,
  /// the doctor's name in a patient's view.
  final String otherParty;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = statusColor(a.status);
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMEd(locale).format(a.start);
    final time = DateFormat.Hm(locale);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(otherParty, style: theme.textTheme.titleMedium),
                      Text(a.serviceDisplay(t), style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                Chip(
                  label: Text(statusLabel(t, a.status)),
                  labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
                  backgroundColor: color.withValues(alpha: 0.10),
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.schedule, size: 16, color: theme.colorScheme.outline),
                Text('$date · ${time.format(a.start)}–${time.format(a.end)}'),
                Text('(${t.minutesShort(a.serviceMinutes)})', style: theme.textTheme.bodySmall),
              ],
            ),
            if (a.note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 16, color: theme.colorScheme.outline),
                    const SizedBox(width: 6),
                    Expanded(child: Text(a.note, style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
            if (actions.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(spacing: 8, children: actions),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
