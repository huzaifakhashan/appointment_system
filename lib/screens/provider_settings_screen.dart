import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../models/business_settings.dart';
import '../state/app_scope.dart';
import '../utils/validators.dart';
import '../widgets/feedback.dart';
import '../utils/service_names.dart';

/// Doctor only: the name patients see, working hours, days off, services.
class ProviderSettingsScreen extends StatelessWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = AppScope.of(context);
    // Wait for the real settings before building the form — seeding it with
    // defaults would silently overwrite them on the next save.
    if (state.myProviderLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(t.businessSettingsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return _SettingsForm(
      initialName: state.myProvider?.name ?? state.profile?.name ?? '',
      initialSettings: state.myProvider?.settings ?? BusinessSettings.fallback,
      department: state.myProvider?.departmentName,
    );
  }
}

class _SettingsForm extends StatefulWidget {
  const _SettingsForm({
    required this.initialName,
    required this.initialSettings,
    this.department,
  });

  final String initialName;
  final BusinessSettings initialSettings;
  final String? department;

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  late BusinessSettings _draft = widget.initialSettings;
  late final _name = TextEditingController(text: widget.initialName);
  final _form = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Map<int, String> _weekdayNames(AppLocalizations t) => {
        DateTime.saturday: t.weekdaySat,
        DateTime.sunday: t.weekdaySun,
        DateTime.monday: t.weekdayMon,
        DateTime.tuesday: t.weekdayTue,
        DateTime.wednesday: t.weekdayWed,
        DateTime.thursday: t.weekdayThu,
        DateTime.friday: t.weekdayFri,
      };

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    if (!_form.currentState!.validate()) return;
    if (_draft.closeHour <= _draft.openHour) {
      showSnack(context, t.closeAfterOpenError);
      return;
    }
    setState(() => _saving = true);
    await runWithFeedback(
      context,
      () => AppScope.of(context).saveMySettings(_name.text, _draft),
      success: t.settingsSaved,
    );
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _editService([Service? existing]) async {
    final result = await showDialog<Service>(
      context: context,
      builder: (_) => _ServiceDialog(existing: existing),
    );
    if (result == null) return;
    setState(() {
      final list = [..._draft.services];
      final i = list.indexWhere((s) => s.id == result.id);
      if (i >= 0) {
        list[i] = result;
      } else {
        list.add(result);
      }
      _draft = _draft.copyWith(services: list);
    });
  }

  void _removeService(Service s) => setState(() => _draft =
      _draft.copyWith(services: [..._draft.services.where((x) => x.id != s.id)]));

  String _hourLabel(int h) => TimeOfDay(hour: h % 24, minute: 0).format(context);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final department = widget.department;
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(text, style: theme.textTheme.titleMedium),
        );

    return Scaffold(
      appBar: AppBar(title: Text(t.businessSettingsTitle)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: t.businessNameLabel),
              validator: Validators(t).required(t.businessNameRequired),
            ),
            if (department != null && department.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.local_hospital, size: 16, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text('${t.departmentLabel}: $department', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            heading(t.workingHours),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _draft.openHour,
                    decoration: InputDecoration(labelText: t.opensLabel),
                    items: [
                      for (var h = 0; h < 24; h++)
                        DropdownMenuItem(value: h, child: Text(_hourLabel(h))),
                    ],
                    onChanged: (h) => setState(() => _draft = _draft.copyWith(openHour: h)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _draft.closeHour,
                    decoration: InputDecoration(labelText: t.closesLabel),
                    items: [
                      for (var h = 1; h <= 24; h++)
                        DropdownMenuItem(value: h, child: Text(_hourLabel(h))),
                    ],
                    onChanged: (h) => setState(() => _draft = _draft.copyWith(closeHour: h)),
                  ),
                ),
              ],
            ),
            heading(t.daysClosed),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final MapEntry(key: day, value: label) in _weekdayNames(t).entries)
                  FilterChip(
                    label: Text(label),
                    selected: _draft.closedWeekdays.contains(day),
                    onSelected: (closed) => setState(() {
                      final days = {..._draft.closedWeekdays};
                      closed ? days.add(day) : days.remove(day);
                      _draft = _draft.copyWith(closedWeekdays: days);
                    }),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(child: Text(t.servicesLabel, style: theme.textTheme.titleMedium)),
                  TextButton.icon(
                    onPressed: _editService,
                    icon: const Icon(Icons.add),
                    label: Text(t.addService),
                  ),
                ],
              ),
            ),
            if (_draft.services.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(t.noServicesYetAdmin),
              )
            else
              for (final s in _draft.services)
                Card(
                  child: ListTile(
                    title: Text(s.displayName(t)),
                    subtitle: Text(t.minutesShort(s.minutes)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: t.edit,
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editService(s),
                        ),
                        IconButton(
                          tooltip: t.delete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeService(s),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 24),
            BusyButton(busy: _saving, onPressed: _save, label: t.save),
          ],
        ),
      ),
    );
  }
}

class _ServiceDialog extends StatefulWidget {
  const _ServiceDialog({this.existing});
  final Service? existing;

  @override
  State<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  // Shows a default service's name in the current language (created on
  // first build, when localizations are available).
  late final _shownName = widget.existing?.displayName(AppLocalizations.of(context)!) ?? '';
  late final _name = TextEditingController(text: _shownName);
  late final _minutes = TextEditingController(text: '${widget.existing?.minutes ?? 30}');
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final existing = widget.existing;
    final typed = _name.text.trim();
    // Name left as shown: keep the stored one, so a default service stays
    // translated in both languages instead of being frozen in this one.
    final name = existing != null && typed == _shownName ? existing.name : typed;
    final id = existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    Navigator.of(context).pop(Service(id, name, int.parse(_minutes.text.trim())));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.existing == null ? t.addServiceTitle : t.editServiceTitle),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: t.nameLabel),
              validator: Validators(t).required(t.enterAName),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minutes,
              decoration: InputDecoration(labelText: t.durationMinutesLabel),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                // Bookings are reserved in 30-minute blocks.
                return n == null || n <= 0 || n % 30 != 0 ? t.enterMultipleOf30 : null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(t.save)),
      ],
    );
  }
}
