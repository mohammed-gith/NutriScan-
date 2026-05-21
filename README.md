# NutriScan

NutriScan is a Flutter food transparency MVP. Users can enter a packaged food barcode, fetch product data from Open Food Facts, and view product name, brand, ingredients, allergens, calories, and Nutri-Score.

## Run

```bash
flutter pub get
flutter run
```

To run on Chrome:

```bash
flutter run -d chrome
```

To run on an Android emulator:

```bash
flutter devices
flutter run -d emulator-5554
```

Use the device id shown by `flutter devices` if yours is different.

## Current MVP Features

- Dashboard-style home screen
- Real barcode camera scanner using `mobile_scanner`
- Manual barcode entry fallback for testing
- Open Food Facts product lookup
- Product result screen with ingredients, allergens, calories, and Nutri-Score
- Healthier alternatives from Open Food Facts category/search results
- Local scan history while the app is open
- Local saved products while the app is open
- Editable local profile details
- Profile picture placeholder for the later image upload feature

Firebase is intentionally left for the next stage.

## How Healthier Alternatives Work

The MVP searches Open Food Facts for similar products. It then keeps products
that have a better Nutri-Score, lower calories, lower sugar, or lower fat than
the scanned product. This is a simple rule-based version before adding AI.

## Important Flutter SDK Note

If Flutter shows an `Operation not permitted` error inside the OneDrive folder,
move your Flutter SDK to a normal local folder such as:

```text
/Users/m1/development/flutter
```

Then update the Flutter SDK path in VS Code.
