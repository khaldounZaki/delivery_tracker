# Delivery Tracker (Flutter)

A minimal Flutter app to track product deliveries by Serial Number (SN) with client details.

## Features
- Sign in (demo): `admin@example.com` / `123456` (local only).
- Add Delivery: scan or type SN, auto-detect product by SN prefix.
- Search Delivery: by client name/phone and date range.
- Search SN: see where a specific SN was delivered.
- Offline storage with SQLite (sqflite).

## Quick Start
1. Create a new Flutter app:
   ```bash
   flutter create delivery_tracker
   ```
2. Replace `pubspec.yaml` and the entire `lib/` with the ones from this project.
3. Get packages:
   ```bash
   flutter pub get
   ```
4. Run:
   ```bash
   flutter run
   ```

## SN → Product Rules
Edit `lib/data/sn_parser.dart`:
```dart
const Map<String, String> snPrefixMap = {
  'MB-700FRS': 'Single Door Freezer',
  'MB-900REF': 'Double Door Refrigerator',
  'MB-600CHL': 'Chiller Cabinet',
};
```
Add/modify prefixes to match your catalog.

## Roadmap / Next Steps
- Replace demo auth with Firebase Auth.
- Backup data to cloud (Firestore / Supabase).
- Add CSV/Excel export.
- Add client master data and address book.
- Role-based users (driver, admin).
