import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../models/business_settings.dart';

/// The name to show for a service, in the current language.
///
/// Every new doctor starts with the default services (see
/// [BusinessSettings.fallback]), stored in English. Those are translated by
/// their id — but only while the doctor hasn't renamed them; a name a doctor
/// typed themselves is shown exactly as written.
String serviceDisplayName(AppLocalizations t, String id, String storedName) {
  final isUntouchedDefault =
      BusinessSettings.fallback.services.any((s) => s.id == id && s.name == storedName);
  if (!isUntouchedDefault) return storedName;
  return switch (id) {
    'consult' => t.serviceConsultation,
    'checkup' => t.serviceCheckup,
    'followup' => t.serviceFollowUp,
    _ => storedName,
  };
}

extension ServiceDisplayName on Service {
  String displayName(AppLocalizations t) => serviceDisplayName(t, id, name);
}

extension AppointmentServiceName on Appointment {
  String serviceDisplay(AppLocalizations t) => serviceDisplayName(t, serviceId, serviceName);
}
