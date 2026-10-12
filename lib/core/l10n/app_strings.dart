import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef MoneyFormatter = String Function(num amount);

/// Every piece of text in the app, in English and Arabic side by side.
/// Read it with `context.s.someText`. To add a language later, add a branch
/// to `_t` (or switch it to a map) — screens don't change.
class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  bool get isArabic => locale.languageCode == 'ar';

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ??
      const AppStrings(Locale('en'));

  String _t(String en, String ar) => isArabic ? ar : en;

  // ───────────────────────── general ─────────────────────────
  String get appName => _t('Masroufi', 'مصروفي');
  String get tagline => _t(
    'Track every expense. Reach every goal.',
    'تابع كل مصروف، وحقق كل هدف.',
  );
  String get cancel => _t('Cancel', 'إلغاء');
  String get save => _t('Save', 'حفظ');
  String get add => _t('Add', 'إضافة');
  String get delete => _t('Delete', 'حذف');
  String get amount => _t('Amount', 'المبلغ');
  String get total => _t('TOTAL', 'الإجمالي');
  String get today => _t('Today', 'اليوم');
  String get yesterday => _t('Yesterday', 'أمس');

  // ───────────────────────── navigation ─────────────────────────
  String get navHome => _t('Home', 'الرئيسية');
  String get navHistory => _t('History', 'السجل');
  String get navReports => _t('Reports', 'التقارير');
  String get navBudget => _t('Budget', 'الميزانية');
  String get navSavings => _t('Savings', 'المدخرات');

  // ───────────────────────── dates ─────────────────────────
  String monthShort(int month) =>
      (isArabic ? _monthsAr : _monthsShortEn)[month - 1];

  String monthFull(int month) =>
      (isArabic ? _monthsAr : _monthsFullEn)[month - 1];

  /// [weekday] follows DateTime.weekday: 1 = Monday ... 7 = Sunday.
  String weekdayShort(int weekday) =>
      (isArabic ? _weekdaysShortAr : _weekdaysShortEn)[weekday - 1];

  /// [index] 0 = Monday ... 6 = Sunday.
  String weekdayFull(int index) =>
      (isArabic ? _weekdaysFullAr : _weekdaysFullEn)[index];

  String compactAmount(double value) {
    String trim(double number) => number == number.roundToDouble()
        ? number.round().toString()
        : number.toStringAsFixed(1).replaceAll('.', isArabic ? '٫' : '.');
    if (value >= 1000000) {
      final amount = trim(value / 1000000);
      return isArabic ? '$amount مليون' : '${amount}M';
    }
    if (value >= 1000) {
      final amount = trim(value / 1000);
      return isArabic ? '$amount ألف' : '${amount}k';
    }
    return value.round().toString();
  }

  /// "Sun, Nov 11, 2026" / "الأحد 11 نوفمبر 2026"
  String dateLong(DateTime d) => isArabic
      ? '${_weekdaysFullAr[d.weekday - 1]} ${d.day} ${_monthsAr[d.month - 1]} ${d.year}'
      : '${_weekdaysShortEn[d.weekday - 1]}, ${_monthsShortEn[d.month - 1]} ${d.day}, ${d.year}';

  /// "Today, 3:05 PM" / "اليوم، 3:05 م"
  String dateTime(DateTime date) {
    final now = DateTime.now();
    bool same(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    final day = same(date, now)
        ? today
        : same(date, now.subtract(const Duration(days: 1)))
        ? yesterday
        : '${date.day}/${date.month}/${date.year}';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? _t('AM', 'ص') : _t('PM', 'م');
    return isArabic
        ? '$day، $hour:$minute $period'
        : '$day, $hour:$minute $period';
  }

  /// "3 days" / "3 أيام" (Arabic has special forms for 1, 2, 3-10, 11+).
  /// [genitive] is the form used after words like "بعد" (2 becomes يومين).
  String days(int n, {bool genitive = false}) {
    if (!isArabic) return n == 1 ? '1 day' : '$n days';
    if (n == 1) return 'يوم واحد';
    if (n == 2) return genitive ? 'يومين' : 'يومان';
    if (n >= 3 && n <= 10) return '$n أيام';
    return '$n يومًا';
  }

  static const _monthsShortEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _monthsFullEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _monthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  static const _weekdaysShortEn = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const _weekdaysFullEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _weekdaysPluralEn = [
    'Mondays',
    'Tuesdays',
    'Wednesdays',
    'Thursdays',
    'Fridays',
    'Saturdays',
    'Sundays',
  ];
  static const _weekdaysShortAr = [
    'اثن',
    'ثلا',
    'أرب',
    'خمي',
    'جمع',
    'سبت',
    'أحد',
  ];
  static const _weekdaysFullAr = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  // ───────────────────────── categories ─────────────────────────
  /// Default categories are stored in English in the database and translated
  /// here. A custom category name is shown as the user typed it.
  String categoryName(String stored) {
    if (!isArabic) return stored;
    return switch (stored) {
      'Transport' => 'المواصلات',
      'Bills' => 'الفواتير',
      'Shopping' => 'التسوق',
      'Entertainment' => 'الترفيه',
      'Groceries' => 'البقالة',
      'Other' => 'أخرى',
      _ => stored,
    };
  }

  // ───────────────────────── auth ─────────────────────────
  String get welcomeBack => _t('Welcome back', 'مرحبًا بعودتك');
  String get loginSubtitle =>
      _t('Log in to see your expenses.', 'سجّل الدخول لعرض مصروفاتك.');
  String get email => _t('Email', 'البريد الإلكتروني');
  String get password => _t('Password', 'كلمة المرور');
  String get passwordMin =>
      _t('Password (min. 6 characters)', 'كلمة المرور (6 أحرف على الأقل)');
  String get confirmPassword => _t('Confirm password', 'تأكيد كلمة المرور');
  String get name => _t('Name', 'الاسم');
  String get incomeOptional =>
      _t('Monthly income (optional)', 'الدخل الشهري (اختياري)');
  String get incomeHelper => _t(
    'Used to suggest your starting budgets',
    'يُستخدم لاقتراح ميزانيتك الأولية',
  );
  String get paydayField =>
      _t('Payday (day of the month)', 'يوم الراتب (من الشهر)');
  String dayN(int n) => _t('Day $n', 'اليوم $n');
  String get logIn => _t('Log in', 'تسجيل الدخول');
  String get createAccount => _t('Create account', 'إنشاء حساب');
  String get noAccount =>
      _t("Don't have an account? Create one", 'ليس لديك حساب؟ أنشئ حسابًا');
  String get haveAccount =>
      _t('Already have an account? Log in', 'لديك حساب بالفعل؟ سجّل الدخول');
  String get createYourAccount => _t('Create your account', 'أنشئ حسابك');
  String get dataStaysOnPhone =>
      _t('Your data stays on this phone.', 'بياناتك تبقى على هذا الهاتف.');
  String get showPassword => _t('Show password', 'إظهار كلمة المرور');
  String get hidePassword => _t('Hide password', 'إخفاء كلمة المرور');
  String get enterValidEmail =>
      _t('Enter a valid email', 'أدخل بريدًا إلكترونيًا صحيحًا');
  String get enterPassword => _t('Enter your password', 'أدخل كلمة المرور');
  String get enterName => _t('Enter your name', 'أدخل اسمك');
  String get passwordTooShort =>
      _t('Use at least 6 characters', 'استخدم 6 أحرف على الأقل');
  String get passwordsDontMatch =>
      _t("Passwords don't match", 'كلمتا المرور غير متطابقتين');
  String get enterValidAmount =>
      _t('Enter a valid amount', 'أدخل مبلغًا صحيحًا');
  String get errorBadCredentials => _t(
    'Incorrect email or password.',
    'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
  );
  String get errorEmailTaken => _t(
    'An account with this email already exists.',
    'يوجد حساب بهذا البريد الإلكتروني بالفعل.',
  );

  // ───────────────────────── dashboard ─────────────────────────
  String greeting(DateTime now) {
    if (now.hour < 12) return _t('Good morning', 'صباح الخير');
    if (now.hour < 17) return _t('Good afternoon', 'طاب يومك');
    return _t('Good evening', 'مساء الخير');
  }

  String greetingWithName(DateTime now, String name) =>
      isArabic ? '${greeting(now)}، $name' : '${greeting(now)}, $name';

  String get paydayToday => _t('Payday is today!', 'يوم الراتب اليوم!');
  String paydayCountdown(int n) =>
      _t('${days(n)} until payday', 'باقي ${days(n)} على الراتب');
  String get monthlySpend => _t('Monthly spend', 'مصروف الشهر');
  String get thisWeek => _t('This week', 'هذا الأسبوع');
  String get recentTransactions => _t('Recent transactions', 'آخر المعاملات');
  String get seeAll => _t('See all', 'عرض الكل');
  String get noExpensesYet => _t(
    'No expenses yet — tap + to add your first one',
    'لا توجد مصروفات بعد — اضغط + لإضافة أول مصروف',
  );
  String get setBudgetHint => _t(
    'Set a monthly budget in the Budget tab',
    'حدّد ميزانية شهرية من تبويب الميزانية',
  );

  // ───────────────────────── history ─────────────────────────
  String get history => _t('History', 'السجل');
  String get rangeDay => _t('Day', 'يوم');
  String get rangeWeek => _t('Week', 'أسبوع');
  String get rangeMonth => _t('Month', 'شهر');
  String get swipeToDelete => _t('Swipe to delete', 'اسحب للحذف');
  String get noExpensesPeriod =>
      _t('No expenses for this period', 'لا توجد مصروفات في هذه الفترة');
  String get deleteExpenseQ => _t('Delete expense?', 'حذف المصروف؟');
  String get cantUndo =>
      _t("This can't be undone.", 'لا يمكن التراجع عن هذا الإجراء.');

  // ───────────────────────── add expense ─────────────────────────
  String get addExpense => _t('Add expense', 'إضافة مصروف');
  String get expenseName => _t('Expense name', 'اسم المصروف');
  String get merchantOrNote => _t('Merchant or note', 'المتجر أو ملاحظة');
  String get category => _t('Category', 'الفئة');
  String get enterExpenseName =>
      _t('Enter an expense name', 'أدخل اسم المصروف');
  String get chooseCategory => _t('Choose a category', 'اختر فئة');
  String get enterAmountGtZero =>
      _t('Enter an amount greater than zero', 'أدخل مبلغًا أكبر من صفر');
  String get expenseAdded => _t('Expense added', 'تمت إضافة المصروف');

  // ───────────────────────── budget ─────────────────────────
  String get budgetAndGoals => _t('Budget & Goals', 'الميزانية والأهداف');
  String get tapToChange =>
      _t('Tap a budget to change its limit', 'اضغط على ميزانية لتغيير حدها');
  String get monthlyBudget => _t('Monthly Budget', 'الميزانية الشهرية');
  String budgetOf(String categoryName) =>
      _t('$categoryName budget', 'ميزانية $categoryName');

  // ───────────────────────── savings ─────────────────────────
  String get savingsGoal => _t('Savings Goal', 'هدف الادخار');
  String get milestoneStart => _t('Start your jar', 'ابدأ حصّالتك');
  String get milestoneSmall => _t('Small steps', 'خطوات صغيرة');
  String get milestoneNice => _t('Nice progress', 'تقدّم جيد');
  String get milestoneHalf => _t('Halfway there!', 'أنت في المنتصف!');
  String get milestoneAlmost => _t('Almost there!', 'اقتربت!');
  String get milestoneDone => _t('Goal reached!', 'تحقق الهدف!');
  String percentComplete(int p) => _t('$p% complete', 'اكتمل $p%');
  String toGo(String amount) => _t('$amount to go', 'متبقي $amount');
  String get addToSavings => _t('Add to savings', 'أضف إلى المدخرات');
  String get changeGoal => _t('Change goal', 'تغيير الهدف');

  // ───────────────────────── reports ─────────────────────────
  String get reportsTitle => _t('Trends & Reports', 'الاتجاهات والتقارير');
  String get previousMonth => _t('Previous month', 'الشهر السابق');
  String get nextMonth => _t('Next month', 'الشهر التالي');
  String get summary => _t('Summary', 'الملخص');
  String totalSpentIn(String month) =>
      _t('Total spent in $month', 'إجمالي الإنفاق في $month');
  String get dailyAverage => _t('Daily average', 'المتوسط اليومي');
  String get transactions => _t('Transactions', 'المعاملات');
  String get biggestExpense => _t('Biggest expense', 'أكبر مصروف');
  String get budgetUsed => _t('Budget used', 'الميزانية المستخدمة');
  String get noBudgetSet => _t('No budget set', 'لا توجد ميزانية');
  String get insights => _t('Insights', 'رؤى');
  String get monthlyTrend => _t('Monthly trend', 'الاتجاه الشهري');
  String trendRange(int months) => switch (months) {
    6 => _t('6M', '٦ أشهر'),
    12 => _t('12M', '١٢ شهرًا'),
    _ => _t('$months months', '$months شهرًا'),
  };
  String get tapBarHint =>
      _t('Tap a bar to open that month', 'اضغط على عمود لفتح ذلك الشهر');
  String get spendingThroughMonth =>
      _t('Spending through the month', 'الإنفاق خلال الشهر');
  String get budgetLegend => _t('Budget', 'الميزانية');
  String get addExpensesToSeeChart =>
      _t('Add expenses to see this chart', 'أضف مصروفات لعرض هذا الرسم');
  String spendByCategory(String month, int year) => _t(
    'Spend by category · $month $year',
    'الإنفاق حسب الفئة · $month $year',
  );
  String get noExpensesThisMonth =>
      _t('No expenses this month', 'لا توجد مصروفات هذا الشهر');
  String get spendingByWeekday =>
      _t('Spending by weekday', 'الإنفاق حسب يوم الأسبوع');

  // ───────────────────────── insights ─────────────────────────
  String insightNoExpenses(String month) =>
      _t('No expenses in $month yet.', 'لا توجد مصروفات في $month بعد.');
  String insightSame(String prev) => _t(
    'Spending is about the same as in $prev.',
    'إنفاقك مماثل تقريبًا لشهر $prev.',
  );
  String insightMore(int pct, String prev) => _t(
    'You spent $pct% more than in $prev.',
    'أنفقت أكثر بنسبة $pct% من شهر $prev.',
  );
  String insightLess(int pct, String prev) => _t(
    'You spent $pct% less than in $prev.',
    'أنفقت أقل بنسبة $pct% من شهر $prev.',
  );
  String insightOverBudget(String amount) =>
      _t('You are over budget by $amount.', 'تجاوزت الميزانية بمقدار $amount.');
  String insightLeftOfBudget(String left, String budget) => _t(
    '$left left of your $budget budget.',
    'تبقّى $left من ميزانيتك البالغة $budget.',
  );
  String insightProjection(
    String projected, {
    String? overBy,
    bool within = false,
  }) {
    if (isArabic) {
      final tail = overBy != null
          ? '، أي أكثر من الميزانية بنحو $overBy.'
          : within
          ? '، وهو ضمن ميزانيتك.'
          : '.';
      return 'بهذا المعدل ستنفق حوالي $projected بنهاية الشهر$tail';
    }
    final tail = overBy != null
        ? ', about $overBy over budget.'
        : within
        ? ', within your budget.'
        : '.';
    return "At this pace you'll spend $projected by month end$tail";
  }

  String insightTopCategory(String name, int share) => _t(
    'Top category: $name, $share% of your spending.',
    'أعلى فئة: $name، بنسبة $share% من إنفاقك.',
  );
  String insightUp(String name, int pct, String prev) => _t(
    '$name is up $pct% vs $prev.',
    'ارتفع إنفاق $name بنسبة $pct% مقارنة بـ$prev.',
  );
  String insightDown(String name, int pct, String prev) => _t(
    '$name is down $pct% vs $prev.',
    'انخفض إنفاق $name بنسبة $pct% مقارنة بـ$prev.',
  );
  String insightWeekday(int index) => _t(
    'You spend the most on ${_weekdaysPluralEn[index]}.',
    'أكثر يوم تنفق فيه هو يوم ${_weekdaysFullAr[index]}.',
  );
  String insightBiggest(String title, String amount) => _t(
    'Biggest expense: $title, $amount.',
    'أكبر مصروف: $title بقيمة $amount.',
  );

  // ───────────────────────── settings ─────────────────────────
  String get settings => _t('Settings', 'الإعدادات');
  String get sectionProfile => _t('Profile', 'الملف الشخصي');
  String get sectionAppearance => _t('Appearance', 'المظهر');
  String get sectionMoney => _t('Money', 'المال');
  String get sectionAccount => _t('Account', 'الحساب');
  String get yourName => _t('Your name', 'اسمك');
  String get cantBeEmpty =>
      _t("This can't be empty", 'لا يمكن ترك هذا الحقل فارغًا');
  String get monthlyIncome => _t('Monthly income', 'الدخل الشهري');
  String get notSet => _t('Not set', 'غير محدد');
  String get payday => _t('Payday', 'يوم الراتب');
  String paydayValue(int day) =>
      _t('Day $day of every month', 'اليوم $day من كل شهر');
  String nextPaydayLine(DateTime date, int daysLeft) {
    if (daysLeft == 0) return _t('Next payday: today', 'الراتب القادم: اليوم');
    return _t(
      'Next payday: ${dateLong(date)} · in ${days(daysLeft)}',
      'الراتب القادم: ${dateLong(date)} · بعد ${days(daysLeft, genitive: true)}',
    );
  }

  String get logout => _t('Log out', 'تسجيل الخروج');
  String get logoutQ => _t('Log out?', 'تسجيل الخروج؟');
  String get dataStaysSaved => _t(
    'Your data stays saved on this phone.',
    'بياناتك تبقى محفوظة على هذا الهاتف.',
  );
  String get theme => _t('Theme', 'السمة');
  String get themeSystem => _t('System default', 'حسب النظام');
  String get themeLight => _t('Light', 'فاتح');
  String get themeDark => _t('Dark', 'داكن');
  String get language => _t('Language', 'اللغة');
  String get languageSystem => _t('System default', 'حسب النظام');
  String get languageEnglish => 'English';
  String get languageArabic => 'العربية';
  String get currency => _t('Currency', 'العملة');
  String get currencyNote => _t(
    'Only the symbol changes; amounts are not converted.',
    'يتغير الرمز فقط ولا يتم تحويل المبالغ.',
  );

  // payday picker
  String get whenGetPaid => _t('When do you get paid?', 'متى تستلم راتبك؟');
  String get pickPaydayDay => _t(
    'Pick the day of the month your salary arrives.',
    'اختر يوم الشهر الذي يصلك فيه الراتب.',
  );
  String nextPaydayPreview(DateTime date, int daysLeft) {
    if (daysLeft == 0) {
      return _t(
        'Next payday: ${dateLong(date)} (today)',
        'الراتب القادم: ${dateLong(date)} (اليوم)',
      );
    }
    return nextPaydayLine(date, daysLeft);
  }

  String get shortMonthNote => _t(
    'In shorter months, payday falls on the last day of the month.',
    'في الشهور الأقصر، يكون الراتب في آخر يوم من الشهر.',
  );
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture<AppStrings>(AppStrings(locale));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
