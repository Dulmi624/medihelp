# MediHelp

MediQueue is a Flutter hospital appointment and queue management app with
patient, receptionist, and admin roles.

## Current Features

- Firebase email/password authentication with Firestore role validation.
- Patient appointment booking flow with doctor, date, time, and confirmation screens.
- Patient appointment, queue status, queue details, and notifications screens.
- Material 3 theme and reusable UI widgets.

## Run Locally

```bash
flutter pub get
flutter run
```

Deploy Firestore rules with:

```bash
firebase deploy --only firestore:rules
```
