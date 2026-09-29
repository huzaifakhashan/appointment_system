import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../models/provider.dart';
import '../state/app_scope.dart';
import '../widgets/async_list.dart';
import '../widgets/feedback.dart';
import '../utils/service_names.dart';

/// Pick a service, a day, and a free time with one doctor, then request it.
class BookScreen extends StatefulWidget {
  const BookScreen({super.key, required this.provider});
  final Provider provider;

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  static const _bookingWindow = Duration(days: 90);

  late Service? _service =
      widget.provider.settings.services.isEmpty ? null : widget.provider.settings.services.first;
  late DateTime? _day = _firstOpenDay();
  DateTime? _slot;
  bool _busy = false;
  final _note = TextEditingController();
  late final Stream<Set<String>> _busySlots =
      AppScope.of(context).watchBusySlots(widget.provider.uid);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool _isOpen(DateTime d) => !widget.provider.settings.closedWeekdays.contains(d.weekday);

  /// Today, or the next day the doctor works. The date picker requires its
  /// starting day to be selectable, so it can't just start on today.
  DateTime? _firstOpenDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var i = 0; i < 7; i++) {
      final d = today.add(Duration(days: i));
      if (_isOpen(d)) return d;
    }
    return null; // closed every day of the week
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(_bookingWindow),
      selectableDayPredicate: _isOpen,
    );
    if (d != null) {
      setState(() {
        _day = d;
        _slot = null;
      });
    }
  }

  Future<void> _submit() async {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await state.book(widget.provider, _service!, _slot!, _note.text);
      nav.pop();
      if (mounted) showSnack(context, t.requestSent);
    } catch (_) {
      // Someone else took the time in the meantime, or we're offline.
      if (!mounted) return;
      setState(() => _slot = null);
      showSnack(context, t.bookingFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final settings = widget.provider.settings;
    final service = _service;
    final day = _day;

    return Scaffold(
      appBar: AppBar(title: Text(widget.provider.name)),
      body: switch ((service, day)) {
        (null, _) => EmptyState(icon: Icons.medical_services, message: t.noServicesYet),
        (_, null) => EmptyState(icon: Icons.event_busy, message: t.noWorkingDays),
        (final service?, final day?) => StreamBuilder<Set<String>>(
            stream: _busySlots,
            builder: (context, snap) {
              final slots = settings.freeSlotsOn(day, service, snap.data ?? const {});
              // Someone else may take the selected time while it's on screen.
              final canSubmit = _slot != null && slots.contains(_slot);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<Service>(
                    isExpanded: true,
                    initialValue: service,
                    decoration: InputDecoration(labelText: t.serviceLabel),
                    items: [
                      for (final s in settings.services)
                        DropdownMenuItem(
                            value: s, child: Text(t.serviceDuration(s.displayName(t), s.minutes))),
                    ],
                    onChanged: (s) => setState(() {
                      _service = s;
                      _slot = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDay,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: t.dateLabel,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormat.yMMMMEEEEd(locale).format(day)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(t.availableTimes, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (!_isOpen(day))
                    Text(t.closedOnThisDay)
                  else if (!snap.hasData)
                    const Center(child: CircularProgressIndicator())
                  else if (slots.isEmpty)
                    Text(t.noFreeTimesOnThisDay)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final slot in slots)
                          ChoiceChip(
                            label: Text(DateFormat.Hm(locale).format(slot)),
                            selected: _slot == slot,
                            onSelected: (_) => setState(() => _slot = slot),
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _note,
                    maxLines: 2,
                    maxLength: 300,
                    decoration: InputDecoration(labelText: t.noteOptional),
                  ),
                  const SizedBox(height: 8),
                  BusyButton(
                    busy: _busy,
                    onPressed: canSubmit ? _submit : null,
                    label: t.requestAppointment,
                  ),
                ],
              );
            },
          ),
      },
    );
  }
}
