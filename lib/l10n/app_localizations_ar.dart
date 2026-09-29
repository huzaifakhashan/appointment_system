// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'المواعيد';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get nameRequired => 'أدخل الاسم';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailInvalid => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordTooShort => '٦ أحرف على الأقل';

  @override
  String get passwordRequired => 'أدخل كلمة المرور';

  @override
  String get alreadyHaveAccount => 'لديك حساب؟ سجّل الدخول';

  @override
  String get newHere => 'مستخدم جديد؟ أنشئ حساباً';

  @override
  String get authErrorWrongPassword =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get authErrorWrongCurrentPassword => 'كلمة المرور غير صحيحة';

  @override
  String get authErrorEmailInUse => 'هذا البريد الإلكتروني مسجّل مسبقاً';

  @override
  String get authErrorWeakPassword =>
      'يجب أن تتكون كلمة المرور من ٦ أحرف على الأقل';

  @override
  String get authErrorInvalidEmail => 'البريد الإلكتروني غير صالح';

  @override
  String get authErrorNetwork => 'لا يوجد اتصال بالإنترنت';

  @override
  String get authErrorTooManyRequests =>
      'محاولات كثيرة. انتظر قليلاً ثم حاول مجدداً.';

  @override
  String get authErrorRequiresRecentLogin =>
      'لحماية حسابك، سجّل الخروج ثم ادخل مجدداً قبل تنفيذ هذا الإجراء';

  @override
  String get authErrorGeneric => 'حدث خطأ ما. حاول مجدداً.';

  @override
  String get permissionDenied => 'لا تملك صلاحية تنفيذ هذا الإجراء';

  @override
  String greeting(String name) {
    return 'أهلاً، $name';
  }

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get noAppointmentsYet => 'لا توجد مواعيد بعد. اضغط \"حجز\" لحجز موعد.';

  @override
  String get upcomingSection => 'القادمة';

  @override
  String get pastSection => 'السابقة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get book => 'حجز';

  @override
  String get cancelAppointment => 'إلغاء الموعد';

  @override
  String get confirmCancelAppointmentTitle => 'إلغاء هذا الموعد؟';

  @override
  String get confirmCancelAppointmentBody =>
      'سيصبح هذا الوقت متاحاً لمرضى آخرين. لا يمكن التراجع عن ذلك.';

  @override
  String get keepAppointment => 'إبقاء الموعد';

  @override
  String get appointmentCancelled => 'تم إلغاء الموعد';

  @override
  String get chooseProviderTitle => 'اختر الطبيب';

  @override
  String get noProvidersYet => 'لا يوجد أطباء متاحون للحجز بعد';

  @override
  String get noProvidersInDepartment => 'لا يوجد أطباء في هذا القسم بعد';

  @override
  String get unnamedProvider => 'طبيب بدون اسم';

  @override
  String serviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خدمة',
      many: '$count خدمة',
      few: '$count خدمات',
      two: 'خدمتان',
      one: 'خدمة واحدة',
      zero: 'لا توجد خدمات',
    );
    return '$_temp0';
  }

  @override
  String doctorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طبيب',
      many: '$count طبيباً',
      few: '$count أطباء',
      two: 'طبيبان',
      one: 'طبيب واحد',
      zero: 'لا يوجد أطباء',
    );
    return '$_temp0';
  }

  @override
  String get serviceConsultation => 'استشارة';

  @override
  String get serviceCheckup => 'فحص عام';

  @override
  String get serviceFollowUp => 'مراجعة';

  @override
  String get bookAppointmentTitle => 'حجز موعد';

  @override
  String get serviceLabel => 'الخدمة';

  @override
  String serviceDuration(String name, int minutes) {
    return '$name ($minutes دقيقة)';
  }

  @override
  String get noServicesYet => 'لا توجد لدى هذا الطبيب خدمات متاحة للحجز بعد';

  @override
  String get noWorkingDays => 'لم يحدد هذا الطبيب أيام عمله بعد';

  @override
  String minutesShort(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get availableTimes => 'الأوقات المتاحة';

  @override
  String get closedOnThisDay => 'لا يوجد دوام في هذا اليوم';

  @override
  String get noFreeTimesOnThisDay =>
      'لا توجد أوقات متاحة في هذا اليوم. جرّب تاريخاً آخر.';

  @override
  String get noteOptional => 'ملاحظة للطبيب (اختياري)';

  @override
  String get requestAppointment => 'طلب الموعد';

  @override
  String get requestSent => 'تم إرسال الطلب. سيصلك إشعار عند تأكيده.';

  @override
  String get bookingFailed => 'تعذّر الحجز. ربما حُجز هذا الوقت للتو.';

  @override
  String get statusPending => 'بانتظار التأكيد';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get bookingsTitle => 'المواعيد';

  @override
  String get businessSettingsTooltip => 'الدوام والخدمات';

  @override
  String get requestsTab => 'الطلبات';

  @override
  String get calendarTab => 'التقويم';

  @override
  String get noPendingRequests => 'لا توجد طلبات بانتظار الرد';

  @override
  String get reject => 'رفض';

  @override
  String get confirm => 'تأكيد';

  @override
  String get confirmRejectTitle => 'رفض هذا الطلب؟';

  @override
  String get nothingScheduled => 'لا توجد مواعيد في هذا اليوم';

  @override
  String get businessSettingsTitle => 'الدوام والخدمات';

  @override
  String get businessNameLabel => 'الاسم الظاهر للمرضى';

  @override
  String get businessNameRequired => 'أدخل الاسم';

  @override
  String get workingHours => 'ساعات الدوام';

  @override
  String get opensLabel => 'من';

  @override
  String get closesLabel => 'إلى';

  @override
  String get daysClosed => 'أيام العطلة';

  @override
  String get weekdayMon => 'الإثنين';

  @override
  String get weekdayTue => 'الثلاثاء';

  @override
  String get weekdayWed => 'الأربعاء';

  @override
  String get weekdayThu => 'الخميس';

  @override
  String get weekdayFri => 'الجمعة';

  @override
  String get weekdaySat => 'السبت';

  @override
  String get weekdaySun => 'الأحد';

  @override
  String get servicesLabel => 'الخدمات';

  @override
  String get addService => 'إضافة';

  @override
  String get noServicesYetAdmin =>
      'لا توجد خدمات بعد. لن يتمكن المرضى من الحجز حتى تضيف خدمة.';

  @override
  String get addServiceTitle => 'إضافة خدمة';

  @override
  String get editServiceTitle => 'تعديل الخدمة';

  @override
  String get durationMinutesLabel => 'المدة (بالدقائق)';

  @override
  String get enterAName => 'أدخل اسماً';

  @override
  String get enterMultipleOf30 => 'أدخل مضاعفاً للرقم ٣٠ (٣٠، ٦٠، ٩٠…)';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String get settingsSaveFailed => 'تعذّر حفظ الإعدادات';

  @override
  String get closeAfterOpenError => 'يجب أن يكون وقت الانتهاء بعد وقت البدء';

  @override
  String get newBookingRequestTitle => 'طلب حجز جديد';

  @override
  String get appointmentCancelledTitle => 'تم إلغاء موعد';

  @override
  String get appointmentConfirmedTitle => 'تم تأكيد موعدك';

  @override
  String get appointmentDeclinedTitle => 'تم رفض موعدك';

  @override
  String get reminderTitle => 'لديك موعد بعد ساعة';

  @override
  String reminderBody(String service, String name) {
    return '$service مع $name';
  }

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get tabPatient => 'مريض';

  @override
  String get tabStaff => 'الطاقم الطبي';

  @override
  String get staffSignInHint => 'حسابات الطاقم الطبي يُنشئها مدير النظام.';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get sendResetLink => 'إرسال الرابط';

  @override
  String get resetEmailSent =>
      'إن كان هذا البريد مسجّلاً، فقد أُرسل إليه رابط إعادة التعيين';

  @override
  String get adminHomeTitle => 'الإدارة';

  @override
  String get departmentsTab => 'الأقسام';

  @override
  String get staffTab => 'الطاقم الطبي';

  @override
  String get addDepartmentTitle => 'إضافة قسم';

  @override
  String get renameDepartmentTitle => 'تعديل اسم القسم';

  @override
  String get departmentNameLabel => 'اسم القسم';

  @override
  String get noDepartmentsYet => 'لا توجد أقسام بعد';

  @override
  String get noStaffYet => 'لا يوجد طاقم طبي بعد';

  @override
  String get addDoctorTitle => 'إضافة طبيب';

  @override
  String get departmentLabel => 'القسم';

  @override
  String get selectDepartmentError => 'اختر قسماً';

  @override
  String get doctorCreated =>
      'تم إنشاء حساب الطبيب. شارك معه البريد الإلكتروني وكلمة المرور.';

  @override
  String get doctorCreateFailed => 'تعذّر إنشاء حساب الطبيب';

  @override
  String get roleDoctor => 'طبيب';

  @override
  String get roleAdmin => 'مدير';

  @override
  String get makeAdmin => 'ترقية إلى مدير';

  @override
  String get makeDoctor => 'تحويل إلى طبيب';

  @override
  String get unassignedDepartment => 'بدون قسم';

  @override
  String get allDepartments => 'الكل';

  @override
  String get addDepartmentFirst => 'أضف قسماً أولاً';

  @override
  String get editStaffTitle => 'تعديل بيانات الموظف';

  @override
  String get staffUpdated => 'تم الحفظ';

  @override
  String get removeStaffTooltip => 'إزالة';

  @override
  String get confirmRemoveStaffTitle => 'إزالة هذا الحساب؟';

  @override
  String confirmRemoveStaffBody(String name) {
    return 'سيفقد $name صلاحيات الطبيب/المدير فوراً. لن يُحذف حساب الدخول الخاص به، وإذا سجّل الدخول مجدداً فسيكون حساب مريض عادياً.';
  }

  @override
  String get remove => 'إزالة';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get personalInfoTitle => 'البيانات الشخصية';

  @override
  String get profileTooltip => 'الملف الشخصي';

  @override
  String get nameUpdated => 'تم تحديث الاسم';

  @override
  String get doctorNameNote =>
      'الاسم الظاهر للمرضى وساعات الدوام والخدمات تُعدَّل من \"الدوام والخدمات\".';

  @override
  String get emailVerifiedLabel => 'موثّق';

  @override
  String get emailNotVerifiedLabel => 'غير موثّق';

  @override
  String get resendVerificationEmail => 'إعادة إرسال رسالة التحقق';

  @override
  String get verificationEmailSent => 'تم إرسال رسالة التحقق';

  @override
  String verificationEmailSentTo(String email) {
    return 'تم إرسال رسالة التحقق إلى $email. إذا لم تجدها في البريد الوارد، فابحث في مجلد الرسائل غير المرغوب فيها (Spam أو Junk).';
  }

  @override
  String get refreshStatus => 'قمت بالتوثيق';

  @override
  String get stillNotVerified =>
      'لم يتم التوثيق بعد. افتح الرابط في الرسالة أولاً.';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordsDontMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountBody =>
      'سيُحذف حسابك وبياناتك الشخصية نهائياً، وستُلغى مواعيدك القادمة. لا يمكن التراجع عن ذلك.';

  @override
  String get deleteAccountConfirmTitle => 'حذف حسابك؟';

  @override
  String get deleteAccountPasswordLabel => 'أدخل كلمة المرور للتأكيد';

  @override
  String get deleteAccountConfirm => 'حذف نهائياً';

  @override
  String get accountDeleted => 'تم حذف حسابك';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneUpdated => 'تم تحديث رقم الهاتف';

  @override
  String get verifyEmailTitle => 'وثّق بريدك الإلكتروني';

  @override
  String verifyEmailBody(String email) {
    return 'أرسلنا رابط تحقق إلى $email. افتحه لتتمكن من حجز المواعيد.';
  }

  @override
  String get checkSpamHint =>
      'لم تصلك الرسالة؟ تحقق من مجلد الرسائل غير المرغوب فيها.';

  @override
  String get signOutFailed => 'تعذّر تسجيل الخروج. تحقق من اتصالك بالإنترنت.';

  @override
  String get pressBackAgainToExit => 'اضغط رجوع مرة أخرى للخروج';

  @override
  String get patientsTab => 'المرضى';

  @override
  String get noPatientsYet => 'لا يوجد مرضى بعد';

  @override
  String get phoneInvalid => 'أدخل رقم هاتف صحيحاً';

  @override
  String get departmentNameRequired => 'أدخل اسم القسم';

  @override
  String get resetPasswordTooltip => 'إرسال رابط إعادة تعيين كلمة المرور';

  @override
  String passwordResetSentTo(String email) {
    return 'تم إرسال رابط إعادة تعيين كلمة المرور إلى $email';
  }

  @override
  String get suspendPatientTooltip => 'إيقاف';

  @override
  String get unsuspendPatientTooltip => 'رفع الإيقاف';

  @override
  String get suspendedLabel => 'موقوف';

  @override
  String get confirmSuspendTitle => 'إيقاف هذا المريض؟';

  @override
  String confirmSuspendBody(String name) {
    return 'لن يتمكن $name من حجز مواعيد جديدة حتى ترفع الإيقاف عنه.';
  }

  @override
  String get confirmDeletePatientTitle => 'حذف هذا المريض؟';

  @override
  String confirmDeletePatientBody(String name) {
    return 'سيُحذف ملف $name. لن يُحذف حساب الدخول الخاص به، وتبقى مواعيده السابقة كما هي.';
  }

  @override
  String get patientRemoved => 'تم حذف المريض';

  @override
  String get confirmDeleteDepartmentTitle => 'حذف هذا القسم؟';

  @override
  String confirmDeleteDepartmentBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يوجد $count أطباء في هذا القسم وسيصبحون بدون قسم.',
      two: 'يوجد طبيبان في هذا القسم وسيصبحان بدون قسم.',
      one: 'يوجد طبيب واحد في هذا القسم وسيصبح بدون قسم.',
      zero: 'لا يوجد أطباء في هذا القسم.',
    );
    return '$_temp0';
  }
}
