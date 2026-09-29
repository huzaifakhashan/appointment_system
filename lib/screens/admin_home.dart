import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/department.dart';
import '../models/managed_user.dart';
import '../models/user_profile.dart';
import '../state/app_scope.dart';
import '../utils/text_direction.dart';
import '../utils/validators.dart';
import '../widgets/async_list.dart';
import '../widgets/dialogs.dart';
import '../widgets/feedback.dart';
import '../widgets/home_actions.dart';

/// Admin home: manage departments, staff (doctors/admins), and patients.
class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.adminHomeTitle),
          actions: homeActions(context),
          bottom: TabBar(tabs: [
            Tab(icon: const Icon(Icons.local_hospital), text: t.departmentsTab),
            Tab(icon: const Icon(Icons.groups), text: t.staffTab),
            Tab(icon: const Icon(Icons.people), text: t.patientsTab),
          ]),
        ),
        body: const TabBarView(children: [_DepartmentsTab(), _StaffTab(), _PatientsTab()]),
      ),
    );
  }
}

// --- Departments -------------------------------------------------------------

class _DepartmentsTab extends StatelessWidget {
  const _DepartmentsTab();

  Future<void> _add(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final state = AppScope.of(context);
    final name = await showTextInputDialog(
      context,
      title: t.addDepartmentTitle,
      label: t.departmentNameLabel,
      confirmLabel: t.save,
      validator: Validators(t).required(t.departmentNameRequired),
    );
    if (name == null || !context.mounted) return;
    await runWithFeedback(context, () => state.createDepartment(name));
  }

  Future<void> _rename(BuildContext context, Department d) async {
    final t = AppLocalizations.of(context)!;
    final state = AppScope.of(context);
    final name = await showTextInputDialog(
      context,
      title: t.renameDepartmentTitle,
      label: t.departmentNameLabel,
      confirmLabel: t.save,
      initialValue: d.name,
      validator: Validators(t).required(t.departmentNameRequired),
    );
    if (name == null || name == d.name || !context.mounted) return;
    await runWithFeedback(context, () => state.renameDepartment(d.id, name));
  }

  Future<void> _delete(BuildContext context, Department d) async {
    final t = AppLocalizations.of(context)!;
    final state = AppScope.of(context);
    final assigned = state.staff.where((s) => s.departmentId == d.id).length;
    final ok = await showConfirmDialog(
      context,
      title: t.confirmDeleteDepartmentTitle,
      body: t.confirmDeleteDepartmentBody(assigned),
      confirmLabel: t.delete,
    );
    if (!ok || !context.mounted) return;
    await runWithFeedback(context, () => state.deleteDepartment(d.id));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: AsyncList(
        loading: state.departmentsLoading,
        emptyMessage: t.noDepartmentsYet,
        emptyIcon: Icons.local_hospital_outlined,
        children: [
          for (final d in state.departments)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.local_hospital)),
                title: Text(d.name),
                subtitle: Text(
                    t.doctorCount(state.staff.where((s) => s.departmentId == d.id).length)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: t.edit,
                      icon: const Icon(Icons.edit),
                      onPressed: () => _rename(context, d),
                    ),
                    IconButton(
                      tooltip: t.delete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(context, d),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: Text(t.addDepartmentTitle),
      ),
    );
  }
}

// --- Staff -------------------------------------------------------------------

class _StaffTab extends StatelessWidget {
  const _StaffTab();

  Future<void> _addDoctor(BuildContext context) async {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    if (state.departments.isEmpty) {
      showSnack(context, t.addDepartmentFirst);
      return;
    }
    final result = await showDialog<_NewDoctor>(
      context: context,
      builder: (_) => _AddDoctorDialog(departments: state.departments),
    );
    if (result == null || !context.mounted) return;
    await runWithFeedback(
      context,
      () => state.createDoctor(
        name: result.name,
        email: result.email,
        password: result.password,
        department: result.department,
      ),
      success: t.doctorCreated,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: AsyncList(
        loading: state.staffLoading,
        emptyMessage: t.noStaffYet,
        emptyIcon: Icons.groups_outlined,
        children: [for (final u in state.staff) _StaffTile(user: u)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addDoctor(context),
        icon: const Icon(Icons.person_add),
        label: Text(t.addDoctorTitle),
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.user});
  final ManagedUser user;

  Future<void> _edit(BuildContext context) async {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final result = await showDialog<_EditedStaff>(
      context: context,
      builder: (_) => _EditStaffDialog(user: user, departments: state.departments),
    );
    if (result == null || !context.mounted) return;
    await runWithFeedback(context, () async {
      if (result.name != user.name) await state.renameStaff(user.uid, result.name);
      final department = result.department;
      if (department != null && department.id != user.departmentId) {
        await state.setDoctorDepartment(user.uid, department);
      }
    }, success: t.staffUpdated);
  }

  Future<void> _remove(BuildContext context) async {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: t.confirmRemoveStaffTitle,
      body: t.confirmRemoveStaffBody(user.displayName),
      confirmLabel: t.remove,
    );
    if (!ok || !context.mounted) return;
    await runWithFeedback(context, () => state.deleteStaff(user.uid));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final isSelf = user.uid == state.profile?.uid;
    final isAdmin = user.role == Role.admin;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.medical_services),
        ),
        title: Text(user.displayName),
        // Role/department on the first line, contact details on their own
        // lines, so a long email never wraps into the middle of the first.
        subtitle: Text([
          [
            isAdmin ? t.roleAdmin : t.roleDoctor,
            if (!isAdmin)
              user.departmentName?.isNotEmpty == true
                  ? user.departmentName!
                  : t.unassignedDepartment,
          ].join(' · '),
          if (user.email.isNotEmpty) ltr(user.email),
          if (user.phone.isNotEmpty) ltr(user.phone),
        ].join('\n')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: t.edit,
              icon: const Icon(Icons.edit),
              onPressed: () => _edit(context),
            ),
            // An admin can't demote, reset, or remove themselves from here.
            if (!isSelf)
              PopupMenuButton<VoidCallback>(
                onSelected: (action) => action(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: () => runWithFeedback(
                      context,
                      () => state.setStaffRole(user.uid, isAdmin ? Role.provider : Role.admin),
                    ),
                    child: Text(isAdmin ? t.makeDoctor : t.makeAdmin),
                  ),
                  PopupMenuItem(
                    value: () => runWithFeedback(
                      context,
                      () => state.sendStaffPasswordReset(user.email),
                      success: t.passwordResetSentTo(user.email),
                    ),
                    child: Text(t.resetPasswordTooltip),
                  ),
                  PopupMenuItem(
                    value: () => _remove(context),
                    child: Text(t.removeStaffTooltip),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EditedStaff {
  const _EditedStaff(this.name, this.department);
  final String name;
  final Department? department;
}

class _EditStaffDialog extends StatefulWidget {
  const _EditStaffDialog({required this.user, required this.departments});
  final ManagedUser user;
  final List<Department> departments;

  @override
  State<_EditStaffDialog> createState() => _EditStaffDialogState();
}

class _EditStaffDialogState extends State<_EditStaffDialog> {
  late final _name = TextEditingController(text: widget.user.name);
  final _form = GlobalKey<FormState>();
  late Department? _department = [
    for (final d in widget.departments)
      if (d.id == widget.user.departmentId) d,
  ].firstOrNull;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(_EditedStaff(_name.text.trim(), _department));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.editStaffTitle),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: t.nameLabel),
              validator: Validators(t).required(),
            ),
            if (widget.user.role == Role.provider) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<Department>(
                isExpanded: true,
                initialValue: _department,
                decoration: InputDecoration(labelText: t.departmentLabel),
                items: [
                  for (final d in widget.departments)
                    DropdownMenuItem(value: d, child: Text(d.name)),
                ],
                onChanged: (d) => setState(() => _department = d),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.cancel)),
        FilledButton(onPressed: _submit, child: Text(t.save)),
      ],
    );
  }
}

class _NewDoctor {
  const _NewDoctor(this.name, this.email, this.password, this.department);
  final String name;
  final String email;
  final String password;
  final Department department;
}

class _AddDoctorDialog extends StatefulWidget {
  const _AddDoctorDialog({required this.departments});
  final List<Department> departments;

  @override
  State<_AddDoctorDialog> createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<_AddDoctorDialog> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  late Department _department = widget.departments.first;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context)
        .pop(_NewDoctor(_name.text.trim(), _email.text.trim(), _password.text, _department));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final v = Validators(t);
    return AlertDialog(
      title: Text(t.addDoctorTitle),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: t.nameLabel),
                validator: v.required(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: t.emailLabel),
                validator: v.email,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(labelText: t.passwordLabel),
                validator: v.newPassword,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Department>(
                isExpanded: true,
                initialValue: _department,
                decoration: InputDecoration(labelText: t.departmentLabel),
                items: [
                  for (final d in widget.departments)
                    DropdownMenuItem(value: d, child: Text(d.name)),
                ],
                onChanged: (d) => setState(() => _department = d!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.cancel)),
        FilledButton(onPressed: _submit, child: Text(t.save)),
      ],
    );
  }
}

// --- Patients ----------------------------------------------------------------

class _PatientsTab extends StatelessWidget {
  const _PatientsTab();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    return AsyncList(
      loading: state.patientsLoading,
      emptyMessage: t.noPatientsYet,
      emptyIcon: Icons.people_outline,
      children: [for (final p in state.patients) _PatientTile(patient: p)],
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient});
  final ManagedUser patient;

  Future<void> _toggleSuspend(BuildContext context) async {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    if (!patient.suspended) {
      final ok = await showConfirmDialog(
        context,
        title: t.confirmSuspendTitle,
        body: t.confirmSuspendBody(patient.displayName),
        confirmLabel: t.suspendPatientTooltip,
      );
      if (!ok || !context.mounted) return;
    }
    await runWithFeedback(
        context, () => state.setPatientSuspended(patient.uid, !patient.suspended));
  }

  Future<void> _remove(BuildContext context) async {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: t.confirmDeletePatientTitle,
      body: t.confirmDeletePatientBody(patient.displayName),
      confirmLabel: t.delete,
    );
    if (!ok || !context.mounted) return;
    await runWithFeedback(context, () => state.deletePatient(patient.uid),
        success: t.patientRemoved);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: patient.suspended ? theme.colorScheme.errorContainer : null,
          child: Icon(patient.suspended ? Icons.block : Icons.person),
        ),
        title: Text(patient.displayName),
        subtitle: Text([
          if (patient.suspended) t.suspendedLabel,
          if (patient.email.isNotEmpty) ltr(patient.email),
          if (patient.phone.isNotEmpty) ltr(patient.phone),
        ].join('\n')),
        // One menu instead of two buttons leaves room for long emails.
        trailing: PopupMenuButton<VoidCallback>(
          onSelected: (action) => action(),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: () => _toggleSuspend(context),
              child: ListTile(
                leading: Icon(patient.suspended ? Icons.check_circle_outline : Icons.block),
                title: Text(
                    patient.suspended ? t.unsuspendPatientTooltip : t.suspendPatientTooltip),
              ),
            ),
            PopupMenuItem(
              value: () => _remove(context),
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(t.delete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
