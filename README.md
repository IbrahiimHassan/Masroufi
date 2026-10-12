<img width="519" height="1067" alt="image" src="https://github.com/user-attachments/assets/66507242-4501-4c4a-ba64-95dc753649a6" /># Masroufi (مصروفي)

A bilingual personal finance app built with Flutter. Track daily expenses, set monthly budgets per category, follow a savings goal, and get spending insights, in English or Arabic, with light and dark themes.

## Screenshots

<table>
  <tr>
    <td align="center"><img src=<img width="498" height="1061" alt="image" src="https://github.com/user-attachments/assets/6b0745ba-ab80-4fe1-91f1-195a1f586df5" />
 width="240" alt="Home dashboard in dark mode"/><br/><b>Home (dark mode)</b></td>
    <td align="center"><img src=<img width="511" height="1059" alt="image" src="https://github.com/user-attachments/assets/d3ec0371-f25e-4a69-acd6-b9fba886efd1" />
 width="240" alt="Savings goal in dark mode"/><br/><b>Savings goal (dark mode)</b></td>
  </tr>
  <tr>
    <td align="center"><img src=<img width="504" height="1056" alt="image" src="https://github.com/user-attachments/assets/71ef9909-9dda-45f9-ac67-6f8293d69fa6" />
 width="240" alt="Reports and insights in light mode"/><br/><b>Reports and insights (light mode)</b></td>
    <td align="center"><img src=<img width="519" height="1067" alt="image" src="https://github.com/user-attachments/assets/d2c0d520-8f03-46ab-8c27-945700db2065" />
 width="240" alt="Budget screen in Arabic with RTL layout"/><br/><b>Budget (Arabic, RTL)</b></td>
  </tr>
</table>

## Features
- **Authentication:** login and registration with persistent sessions, and separate data for each user
- **Dashboard:** monthly spend vs. budget, today and this week totals, a payday countdown, and recent transactions
- **Expenses:** add, view, and manage expenses with categories, plus a full transaction history
- **Budgets:** a monthly budget with a per-category breakdown and progress bars
- **Reports:** monthly summary (daily average, biggest expense, budget used), generated insights, and a 6M/12M spending trend
- **Savings goal:** progress tracker with an add-to-savings flow and an editable goal
- **Localization:** English and Arabic, with full right-to-left layout support
- **Theming:** light and dark modes
- **Currency:** configurable currency with locale-aware number formatting (Arabic and English numerals)
- **Responsive UI:** adaptive navigation for phones and larger screens, with desktop support

## Tech stack
- Flutter and Dart
- Provider for state management
- SQLite for local data storage
- SharedPreferences for user settings (theme, language, currency)
- Material Design

## Architecture
The project uses a feature-based structure: shared logic lives in `core/`, and each domain has its own folder under `features/`.

```
lib/
├── main.dart              # Startup: orientation, SQLite, SharedPreferences, runApp
├── app.dart               # Global providers, MaterialApp, localization, theming, auth gate
├── user_scope.dart        # Per-user scoped state
│
├── core/                  # Shared foundation
│   ├── settings/          # Settings provider (theme, language, currency)
│   ├── database/          # SQLite access and persistence
│   ├── theme/             # Light and dark themes
│   ├── l10n/              # Localization and translated strings (English/Arabic)
│   ├── currency/          # Currency definitions and formatting
│   └── utils/             # Helpers and formatting utilities
│
└── features/              # One folder per domain
    ├── auth/              # Login, registration, auth provider and repository
    ├── home/              # Main shell and adaptive navigation
    ├── expenses/          # Add, view, and manage expenses
    ├── categories/        # Expense categories
    ├── budget/            # Budget screens and calculations
    ├── reports/           # Charts, summaries, insights
    ├── savings/           # Savings goal tracking
    ├── profile/           # Profile editing
    └── settings/          # Preferences UI

test/
└── settings_test.dart     # Unit tests (see below)
```

Platform folders (`android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`) are the standard Flutter targets.

## Testing
`test/settings_test.dart` covers:
- parsing numeric input in Arabic and English formats
- persisting theme, language, and currency
- translation correctness
- currency formatting rules

```bash
flutter test
```

## Getting started
**Prerequisites:** the [Flutter SDK](https://docs.flutter.dev/get-started/install) and an emulator or physical device.

```bash
git clone https://github.com/IbrahiimHassan/Masroufi.git
cd Masroufi
flutter pub get
flutter run
```

## Roadmap
- [ ] Recurring expenses
- [ ] Export reports to CSV/PDF
- [ ] Cloud backup and sync
- [ ] Multiple savings goals

## Author
Ibrahim Hassan | [LinkedIn](https://linkedin.com/in/ibrahim-hassan)
