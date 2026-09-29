import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameRequired;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordRequired;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get newHere;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorWrongCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get authErrorWrongCurrentPassword;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get authErrorNetwork;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, please sign out and sign in again first'**
  String get authErrorRequiresRecentLogin;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that'**
  String get permissionDenied;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greeting(String name);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @noAppointmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No appointments yet. Tap \"Book\" to make one.'**
  String get noAppointmentsYet;

  /// No description provided for @upcomingSection.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingSection;

  /// No description provided for @pastSection.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get pastSection;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel appointment'**
  String get cancelAppointment;

  /// No description provided for @confirmCancelAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this appointment?'**
  String get confirmCancelAppointmentTitle;

  /// No description provided for @confirmCancelAppointmentBody.
  ///
  /// In en, this message translates to:
  /// **'The time will be freed for other patients. This can\'t be undone.'**
  String get confirmCancelAppointmentBody;

  /// No description provided for @keepAppointment.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepAppointment;

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled'**
  String get appointmentCancelled;

  /// No description provided for @chooseProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a doctor'**
  String get chooseProviderTitle;

  /// No description provided for @noProvidersYet.
  ///
  /// In en, this message translates to:
  /// **'No doctors are available to book with yet'**
  String get noProvidersYet;

  /// No description provided for @noProvidersInDepartment.
  ///
  /// In en, this message translates to:
  /// **'No doctors in this department yet'**
  String get noProvidersInDepartment;

  /// No description provided for @unnamedProvider.
  ///
  /// In en, this message translates to:
  /// **'Unnamed doctor'**
  String get unnamedProvider;

  /// No description provided for @serviceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No services} =1{1 service} other{{count} services}}'**
  String serviceCount(int count);

  /// No description provided for @doctorCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No doctors} =1{1 doctor} other{{count} doctors}}'**
  String doctorCount(int count);

  /// No description provided for @serviceConsultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get serviceConsultation;

  /// No description provided for @serviceCheckup.
  ///
  /// In en, this message translates to:
  /// **'Check-up'**
  String get serviceCheckup;

  /// No description provided for @serviceFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get serviceFollowUp;

  /// No description provided for @bookAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Book an appointment'**
  String get bookAppointmentTitle;

  /// No description provided for @serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceLabel;

  /// No description provided for @serviceDuration.
  ///
  /// In en, this message translates to:
  /// **'{name} ({minutes} min)'**
  String serviceDuration(String name, int minutes);

  /// No description provided for @noServicesYet.
  ///
  /// In en, this message translates to:
  /// **'This doctor has no services to book yet'**
  String get noServicesYet;

  /// No description provided for @noWorkingDays.
  ///
  /// In en, this message translates to:
  /// **'This doctor has no working days set yet'**
  String get noWorkingDays;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @availableTimes.
  ///
  /// In en, this message translates to:
  /// **'Available times'**
  String get availableTimes;

  /// No description provided for @closedOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'Closed on this day'**
  String get closedOnThisDay;

  /// No description provided for @noFreeTimesOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'No free times on this day. Try another date.'**
  String get noFreeTimesOnThisDay;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note for the doctor (optional)'**
  String get noteOptional;

  /// No description provided for @requestAppointment.
  ///
  /// In en, this message translates to:
  /// **'Request appointment'**
  String get requestAppointment;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent. You\'ll be notified once it\'s confirmed.'**
  String get requestSent;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not book. That time may have just been taken.'**
  String get bookingFailed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusRejected;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get bookingsTitle;

  /// No description provided for @businessSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Schedule & services'**
  String get businessSettingsTooltip;

  /// No description provided for @requestsTab.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTab;

  /// No description provided for @calendarTab.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTab;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get reject;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline this request?'**
  String get confirmRejectTitle;

  /// No description provided for @nothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled on this day'**
  String get nothingScheduled;

  /// No description provided for @businessSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule & services'**
  String get businessSettingsTitle;

  /// No description provided for @businessNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name shown to patients'**
  String get businessNameLabel;

  /// No description provided for @businessNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get businessNameRequired;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingHours;

  /// No description provided for @opensLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get opensLabel;

  /// No description provided for @closesLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get closesLabel;

  /// No description provided for @daysClosed.
  ///
  /// In en, this message translates to:
  /// **'Days off'**
  String get daysClosed;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @servicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesLabel;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addService;

  /// No description provided for @noServicesYetAdmin.
  ///
  /// In en, this message translates to:
  /// **'No services yet. Patients can\'t book until you add one.'**
  String get noServicesYetAdmin;

  /// No description provided for @addServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get addServiceTitle;

  /// No description provided for @editServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get editServiceTitle;

  /// No description provided for @durationMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutesLabel;

  /// No description provided for @enterAName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterAName;

  /// No description provided for @enterMultipleOf30.
  ///
  /// In en, this message translates to:
  /// **'Enter a multiple of 30 (30, 60, 90…)'**
  String get enterMultipleOf30;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings'**
  String get settingsSaveFailed;

  /// No description provided for @closeAfterOpenError.
  ///
  /// In en, this message translates to:
  /// **'Closing time must be after opening time'**
  String get closeAfterOpenError;

  /// No description provided for @newBookingRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'New booking request'**
  String get newBookingRequestTitle;

  /// No description provided for @appointmentCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled'**
  String get appointmentCancelledTitle;

  /// No description provided for @appointmentConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment confirmed'**
  String get appointmentConfirmedTitle;

  /// No description provided for @appointmentDeclinedTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment declined'**
  String get appointmentDeclinedTitle;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment in 1 hour'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'{service} with {name}'**
  String reminderBody(String service, String name);

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @tabPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get tabPatient;

  /// No description provided for @tabStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get tabStaff;

  /// No description provided for @staffSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Staff accounts are created by the administrator.'**
  String get staffSignInHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If that email has an account, a reset link was sent'**
  String get resetEmailSent;

  /// No description provided for @adminHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get adminHomeTitle;

  /// No description provided for @departmentsTab.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get departmentsTab;

  /// No description provided for @staffTab.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffTab;

  /// No description provided for @addDepartmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add department'**
  String get addDepartmentTitle;

  /// No description provided for @renameDepartmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename department'**
  String get renameDepartmentTitle;

  /// No description provided for @departmentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Department name'**
  String get departmentNameLabel;

  /// No description provided for @noDepartmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No departments yet'**
  String get noDepartmentsYet;

  /// No description provided for @noStaffYet.
  ///
  /// In en, this message translates to:
  /// **'No staff accounts yet'**
  String get noStaffYet;

  /// No description provided for @addDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Add doctor'**
  String get addDoctorTitle;

  /// No description provided for @departmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get departmentLabel;

  /// No description provided for @selectDepartmentError.
  ///
  /// In en, this message translates to:
  /// **'Choose a department'**
  String get selectDepartmentError;

  /// No description provided for @doctorCreated.
  ///
  /// In en, this message translates to:
  /// **'Doctor account created. Share the email and password with them.'**
  String get doctorCreated;

  /// No description provided for @doctorCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the doctor account'**
  String get doctorCreateFailed;

  /// No description provided for @roleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get roleDoctor;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get makeAdmin;

  /// No description provided for @makeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Make doctor'**
  String get makeDoctor;

  /// No description provided for @unassignedDepartment.
  ///
  /// In en, this message translates to:
  /// **'No department'**
  String get unassignedDepartment;

  /// No description provided for @allDepartments.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allDepartments;

  /// No description provided for @addDepartmentFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a department first'**
  String get addDepartmentFirst;

  /// No description provided for @editStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit staff member'**
  String get editStaffTitle;

  /// No description provided for @staffUpdated.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get staffUpdated;

  /// No description provided for @removeStaffTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeStaffTooltip;

  /// No description provided for @confirmRemoveStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this account?'**
  String get confirmRemoveStaffTitle;

  /// No description provided for @confirmRemoveStaffBody.
  ///
  /// In en, this message translates to:
  /// **'{name} loses all doctor/admin access right away. Their login isn\'t deleted; if they sign in again, it\'s as an ordinary patient.'**
  String confirmRemoveStaffBody(String name);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get profileTitle;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personalInfoTitle;

  /// No description provided for @profileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTooltip;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get nameUpdated;

  /// No description provided for @doctorNameNote.
  ///
  /// In en, this message translates to:
  /// **'The name patients see, your hours, and your services are edited from \"Schedule & services\".'**
  String get doctorNameNote;

  /// No description provided for @emailVerifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get emailVerifiedLabel;

  /// No description provided for @emailNotVerifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get emailNotVerifiedLabel;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verificationEmailSent;

  /// No description provided for @verificationEmailSentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to {email}. Not in your inbox? Check your Spam or Junk folder.'**
  String verificationEmailSentTo(String email);

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified it'**
  String get refreshStatus;

  /// No description provided for @stillNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet. Open the link in the email first.'**
  String get stillNotVerified;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your account and personal details will be permanently deleted, and your upcoming appointments will be cancelled. This can\'t be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get deleteAccountPasswordLabel;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get accountDeleted;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Phone number updated'**
  String get phoneUpdated;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Open it to start booking appointments.'**
  String verifyEmailBody(String email);

  /// No description provided for @checkSpamHint.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? Check your spam folder.'**
  String get checkSpamHint;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign out. Check your connection.'**
  String get signOutFailed;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgainToExit;

  /// No description provided for @patientsTab.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patientsTab;

  /// No description provided for @noPatientsYet.
  ///
  /// In en, this message translates to:
  /// **'No patients yet'**
  String get noPatientsYet;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @departmentNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a department name'**
  String get departmentNameRequired;

  /// No description provided for @resetPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send password reset email'**
  String get resetPasswordTooltip;

  /// No description provided for @passwordResetSentTo.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}'**
  String passwordResetSentTo(String email);

  /// No description provided for @suspendPatientTooltip.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get suspendPatientTooltip;

  /// No description provided for @unsuspendPatientTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unsuspend'**
  String get unsuspendPatientTooltip;

  /// No description provided for @suspendedLabel.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspendedLabel;

  /// No description provided for @confirmSuspendTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspend this patient?'**
  String get confirmSuspendTitle;

  /// No description provided for @confirmSuspendBody.
  ///
  /// In en, this message translates to:
  /// **'{name} won\'t be able to book new appointments until you unsuspend them.'**
  String confirmSuspendBody(String name);

  /// No description provided for @confirmDeletePatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this patient?'**
  String get confirmDeletePatientTitle;

  /// No description provided for @confirmDeletePatientBody.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s profile will be removed. Their login isn\'t deleted, and appointments they already made are unaffected.'**
  String confirmDeletePatientBody(String name);

  /// No description provided for @patientRemoved.
  ///
  /// In en, this message translates to:
  /// **'Patient removed'**
  String get patientRemoved;

  /// No description provided for @confirmDeleteDepartmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this department?'**
  String get confirmDeleteDepartmentTitle;

  /// No description provided for @confirmDeleteDepartmentBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No doctors are assigned to it.} =1{1 doctor is assigned to it and will be left without a department.} other{{count} doctors are assigned to it and will be left without a department.}}'**
  String confirmDeleteDepartmentBody(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
