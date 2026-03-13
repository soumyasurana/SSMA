# SSMA

SSMA is a Flutter desktop app for running a small shop without depending on a permanent internet connection. It keeps day-to-day records local with Isar, handles sales and purchases, tracks dues on both sides of the ledger, and generates PDF documents for invoices and statements.

This project is not a generic Flutter starter anymore. It is a compact business workflow app with screens for inventory, customers, suppliers, sales history, low-stock monitoring, and reporting.

## What The App Covers

- Customer cash and credit sales
- Supplier purchases and supplier payments
- Inventory quantity tracking
- Customer dues and supplier balances
- PDF invoice generation
- Supplier statement and report export
- Local-first persistence with Isar

## Main Screens

- `Dashboard`
- `Customers`
- `Customer Detail`
- `Inventory`
- `New Sale`
- `Sales History`
- `Supplier Records`
- `Supplier Detail`
- `New Purchase`
- `Reports`
- `Low Stock`

## Stack

- `Flutter`
- `Isar` for local database storage
- `intl` for date and currency formatting
- `pdf` and `printing` for document generation
- `shared_preferences` for lightweight local settings
- `uuid` for stable cross-device identifiers

## Project Structure

```text
lib/
  main.dart
  models/
  screens/
  services/
test/
integration_test/
assets/fonts/
```

## Data Model Notes

The app uses two kinds of identifiers:

- `isarId`
  Local primary key used by Isar internally
- `uuid`
  App-level stable identifier used across relations and sync-oriented logic

If you touch database code, keep that distinction intact. Most app logic should use `uuid` for relationships such as:

- `sale.customerUuid`
- `purchase.supplierUuid`
- `saleItem.productUuid`
- `purchaseItem.productUuid`

## Run Locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d macos
```

If you are targeting another platform, replace `macos` with the device you want to run.

## Build

```bash
flutter build macos --debug
```

## Useful Development Commands

Regenerate Isar files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run tests:

```bash
flutter test
```

Run integration tests:

```bash
flutter test integration_test
```

Analyze:

```bash
flutter analyze
```

## PDFs And Assets

The app currently depends on the bundled Roboto font files:

- `assets/fonts/Roboto-Regular.ttf`
- `assets/fonts/Roboto-Bold.ttf`

If you rename or move them, update both `pubspec.yaml` and the PDF service code.

## Current Engineering Reality

This codebase has already moved beyond prototype status, but it still benefits from careful maintenance in a few areas:

- database migrations and legacy data handling
- duplicate prevention around unique UUID indexes
- consistency in dues and balance calculations
- UI refresh after write-heavy flows

That is normal for a local-first business app. Most of the hard parts are in data correctness, not UI rendering.

## Suggested Workflow For Contributors

1. Run `flutter analyze`.
2. Regenerate Isar code if any model changed.
3. Test one full business flow end-to-end:
   sale, purchase, payment, delete, and PDF generation.
4. Only then trust the change.

## Status

SSMA is an actively iterated Flutter app for shop operations, not a template project. The README is meant to help you work on the real thing quickly: understand the screens, respect the UUID-based data model, and verify flows that affect money, stock, or dues.
