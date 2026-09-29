// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Appointments';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordTooShort => 'At least 6 characters';

  @override
  String get passwordRequired => 'Enter your password';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get newHere => 'New here? Create an account';

  @override
  String get authErrorWrongPassword => 'Wrong email or password';

  @override
  String get authErrorWrongCurrentPassword => 'Incorrect password';

  @override
  String get authErrorEmailInUse => 'This email is already registered';

  @override
  String get authErrorWeakPassword => 'Password must be at least 6 characters';

  @override
  String get authErrorInvalidEmail => 'Invalid email address';

  @override
  String get authErrorNetwork => 'No internet connection';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get authErrorRequiresRecentLogin =>
      'For your security, please sign out and sign in again first';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get permissionDenied => 'You don\'t have permission to do that';

  @override
  String greeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get noAppointmentsYet =>
      'No appointments yet. Tap \"Book\" to make one.';

  @override
  String get upcomingSection => 'Upcoming';

  @override
  String get pastSection => 'Past';

  @override
  String get cancel => 'Cancel';

  @override
  String get book => 'Book';

  @override
  String get cancelAppointment => 'Cancel appointment';

  @override
  String get confirmCancelAppointmentTitle => 'Cancel this appointment?';

  @override
  String get confirmCancelAppointmentBody =>
      'The time will be freed for other patients. This can\'t be undone.';

  @override
  String get keepAppointment => 'Keep it';

  @override
  String get appointmentCancelled => 'Appointment cancelled';

  @override
  String get chooseProviderTitle => 'Choose a doctor';

  @override
  String get noProvidersYet => 'No doctors are available to book with yet';

  @override
  String get noProvidersInDepartment => 'No doctors in this department yet';

  @override
  String get unnamedProvider => 'Unnamed doctor';

  @override
  String serviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services',
      one: '1 service',
      zero: 'No services',
    );
    return '$_temp0';
  }

  @override
  String doctorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doctors',
      one: '1 doctor',
      zero: 'No doctors',
    );
    return '$_temp0';
  }

  @override
  String get serviceConsultation => 'Consultation';

  @override
  String get serviceCheckup => 'Check-up';

  @override
  String get serviceFollowUp => 'Follow-up';

  @override
  String get bookAppointmentTitle => 'Book an appointment';

  @override
  String get serviceLabel => 'Service';

  @override
  String serviceDuration(String name, int minutes) {
    return '$name ($minutes min)';
  }

  @override
  String get noServicesYet => 'This doctor has no services to book yet';

  @override
  String get noWorkingDays => 'This doctor has no working days set yet';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get availableTimes => 'Available times';

  @override
  String get closedOnThisDay => 'Closed on this day';

  @override
  String get noFreeTimesOnThisDay =>
      'No free times on this day. Try another date.';

  @override
  String get noteOptional => 'Note for the doctor (optional)';

  @override
  String get requestAppointment => 'Request appointment';

  @override
  String get requestSent =>
      'Request sent. You\'ll be notified once it\'s confirmed.';

  @override
  String get bookingFailed =>
      'Could not book. That time may have just been taken.';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusRejected => 'Declined';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get bookingsTitle => 'Appointments';

  @override
  String get businessSettingsTooltip => 'Schedule & services';

  @override
  String get requestsTab => 'Requests';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get reject => 'Decline';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmRejectTitle => 'Decline this request?';

  @override
  String get nothingScheduled => 'Nothing scheduled on this day';

  @override
  String get businessSettingsTitle => 'Schedule & services';

  @override
  String get businessNameLabel => 'Name shown to patients';

  @override
  String get businessNameRequired => 'Enter a name';

  @override
  String get workingHours => 'Working hours';

  @override
  String get opensLabel => 'From';

  @override
  String get closesLabel => 'To';

  @override
  String get daysClosed => 'Days off';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get servicesLabel => 'Services';

  @override
  String get addService => 'Add';

  @override
  String get noServicesYetAdmin =>
      'No services yet. Patients can\'t book until you add one.';

  @override
  String get addServiceTitle => 'Add service';

  @override
  String get editServiceTitle => 'Edit service';

  @override
  String get durationMinutesLabel => 'Duration (minutes)';

  @override
  String get enterAName => 'Enter a name';

  @override
  String get enterMultipleOf30 => 'Enter a multiple of 30 (30, 60, 90…)';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsSaveFailed => 'Could not save settings';

  @override
  String get closeAfterOpenError => 'Closing time must be after opening time';

  @override
  String get newBookingRequestTitle => 'New booking request';

  @override
  String get appointmentCancelledTitle => 'Appointment cancelled';

  @override
  String get appointmentConfirmedTitle => 'Appointment confirmed';

  @override
  String get appointmentDeclinedTitle => 'Appointment declined';

  @override
  String get reminderTitle => 'Appointment in 1 hour';

  @override
  String reminderBody(String service, String name) {
    return '$service with $name';
  }

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get tabPatient => 'Patient';

  @override
  String get tabStaff => 'Staff';

  @override
  String get staffSignInHint =>
      'Staff accounts are created by the administrator.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetEmailSent =>
      'If that email has an account, a reset link was sent';

  @override
  String get adminHomeTitle => 'Administration';

  @override
  String get departmentsTab => 'Departments';

  @override
  String get staffTab => 'Staff';

  @override
  String get addDepartmentTitle => 'Add department';

  @override
  String get renameDepartmentTitle => 'Rename department';

  @override
  String get departmentNameLabel => 'Department name';

  @override
  String get noDepartmentsYet => 'No departments yet';

  @override
  String get noStaffYet => 'No staff accounts yet';

  @override
  String get addDoctorTitle => 'Add doctor';

  @override
  String get departmentLabel => 'Department';

  @override
  String get selectDepartmentError => 'Choose a department';

  @override
  String get doctorCreated =>
      'Doctor account created. Share the email and password with them.';

  @override
  String get doctorCreateFailed => 'Could not create the doctor account';

  @override
  String get roleDoctor => 'Doctor';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get makeAdmin => 'Make admin';

  @override
  String get makeDoctor => 'Make doctor';

  @override
  String get unassignedDepartment => 'No department';

  @override
  String get allDepartments => 'All';

  @override
  String get addDepartmentFirst => 'Add a department first';

  @override
  String get editStaffTitle => 'Edit staff member';

  @override
  String get staffUpdated => 'Saved';

  @override
  String get removeStaffTooltip => 'Remove';

  @override
  String get confirmRemoveStaffTitle => 'Remove this account?';

  @override
  String confirmRemoveStaffBody(String name) {
    return '$name loses all doctor/admin access right away. Their login isn\'t deleted; if they sign in again, it\'s as an ordinary patient.';
  }

  @override
  String get remove => 'Remove';

  @override
  String get profileTitle => 'My profile';

  @override
  String get personalInfoTitle => 'Personal details';

  @override
  String get profileTooltip => 'Profile';

  @override
  String get nameUpdated => 'Name updated';

  @override
  String get doctorNameNote =>
      'The name patients see, your hours, and your services are edited from \"Schedule & services\".';

  @override
  String get emailVerifiedLabel => 'Verified';

  @override
  String get emailNotVerifiedLabel => 'Not verified';

  @override
  String get resendVerificationEmail => 'Resend verification email';

  @override
  String get verificationEmailSent => 'Verification email sent';

  @override
  String verificationEmailSentTo(String email) {
    return 'Verification email sent to $email. Not in your inbox? Check your Spam or Junk folder.';
  }

  @override
  String get refreshStatus => 'I\'ve verified it';

  @override
  String get stillNotVerified =>
      'Not verified yet. Open the link in the email first.';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm new password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get updatePassword => 'Update password';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountBody =>
      'Your account and personal details will be permanently deleted, and your upcoming appointments will be cancelled. This can\'t be undone.';

  @override
  String get deleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get deleteAccountPasswordLabel => 'Enter your password to confirm';

  @override
  String get deleteAccountConfirm => 'Delete permanently';

  @override
  String get accountDeleted => 'Your account has been deleted';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneUpdated => 'Phone number updated';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailBody(String email) {
    return 'We sent a verification link to $email. Open it to start booking appointments.';
  }

  @override
  String get checkSpamHint => 'Didn\'t get it? Check your spam folder.';

  @override
  String get signOutFailed => 'Could not sign out. Check your connection.';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get patientsTab => 'Patients';

  @override
  String get noPatientsYet => 'No patients yet';

  @override
  String get phoneInvalid => 'Enter a valid phone number';

  @override
  String get departmentNameRequired => 'Enter a department name';

  @override
  String get resetPasswordTooltip => 'Send password reset email';

  @override
  String passwordResetSentTo(String email) {
    return 'Password reset email sent to $email';
  }

  @override
  String get suspendPatientTooltip => 'Suspend';

  @override
  String get unsuspendPatientTooltip => 'Unsuspend';

  @override
  String get suspendedLabel => 'Suspended';

  @override
  String get confirmSuspendTitle => 'Suspend this patient?';

  @override
  String confirmSuspendBody(String name) {
    return '$name won\'t be able to book new appointments until you unsuspend them.';
  }

  @override
  String get confirmDeletePatientTitle => 'Delete this patient?';

  @override
  String confirmDeletePatientBody(String name) {
    return '$name\'s profile will be removed. Their login isn\'t deleted, and appointments they already made are unaffected.';
  }

  @override
  String get patientRemoved => 'Patient removed';

  @override
  String get confirmDeleteDepartmentTitle => 'Delete this department?';

  @override
  String confirmDeleteDepartmentBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count doctors are assigned to it and will be left without a department.',
      one: '1 doctor is assigned to it and will be left without a department.',
      zero: 'No doctors are assigned to it.',
    );
    return '$_temp0';
  }
}
