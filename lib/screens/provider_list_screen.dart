import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_scope.dart';
import '../widgets/async_list.dart';
import 'book_screen.dart';

/// The doctors a patient can book with, filterable by department.
class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  String? _departmentId; // null = all

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final providers = [
      for (final p in state.providers)
        if (_departmentId == null || p.departmentId == _departmentId) p,
    ];

    Widget chip(String label, String? id) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: _departmentId == id,
            onSelected: (_) => setState(() => _departmentId = id),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(t.chooseProviderTitle)),
      body: Column(
        children: [
          if (state.departments.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  chip(t.allDepartments, null),
                  for (final d in state.departments) chip(d.name, d.id),
                ],
              ),
            ),
          Expanded(
            child: AsyncList(
              loading: state.providersLoading,
              emptyIcon: Icons.medical_services_outlined,
              emptyMessage:
                  _departmentId == null ? t.noProvidersYet : t.noProvidersInDepartment,
              children: [
                for (final p in providers)
                  Card(
                    child: ListTile(
                      enabled: p.settings.services.isNotEmpty,
                      leading: const CircleAvatar(child: Icon(Icons.medical_services)),
                      title: Text(p.name.isEmpty ? t.unnamedProvider : p.name),
                      subtitle: Text([
                        if (p.departmentName?.isNotEmpty == true) p.departmentName!,
                        t.serviceCount(p.settings.services.length),
                      ].join(' · ')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BookScreen(provider: p)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
