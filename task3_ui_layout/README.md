# Task 3 - UI Layout

> Design a layout with three UI elements: a label, an EditText, and a button.
> When the button is pressed, the label should display the content of the
> EditText.

One screen with the three elements. Pressing **Show on label** (or the keyboard's
done key) copies the text field into the label. An empty field shows a hint
instead.

Flutter equivalents of the Android widgets named in the task: `EditText` is a
`TextField` and the label (`TextView`) is a `Text`.

- **Code:** [`lib/main.dart`](lib/main.dart)
- **Tests:** [`test/widget_test.dart`](test/widget_test.dart)
- **APK:** [`apk/task3_ui_layout.apk`](../apk/task3_ui_layout.apk)

## Run

```
flutter pub get
flutter run
```

## Test

```
flutter test
```

Requirements and screenshots are in the [repository README](../README.md).
