# To-Do List App (Flutter)

A simple Flutter app to organize daily tasks. Tasks are saved on the device, so they are still there after you close and reopen the app.

## Features

- Add a task (empty titles are rejected)
- Edit a task (tap on it)
- Delete a task (trash icon)
- Mark tasks complete/incomplete (checkbox, completed tasks are crossed out and grey)
- Priorities: Low (green), Medium (orange), High (red)
- Progress counter in the top bar (e.g. "2/5 done")
- Light / dark mode toggle (the choice is also saved)
- Local storage using `shared_preferences`

## How to Run

1. Install [Flutter](https://docs.flutter.dev/get-started/install)
2. Clone this repository and open the folder
3. In a terminal, run:

```bash
flutter pub get
flutter run
```

## Dependencies

- [shared_preferences](https://pub.dev/packages/shared_preferences): saves tasks and theme as small key-value data

## Project Structure

```
lib/
  main.dart   # Task model, theme handling, and the home screen
```

## Screenshots

Add your screenshots here:

| Light mode | Dark mode | Add/Edit dialog |
|---|---|---|
| ![light](screenshots/light.png) | ![dark](screenshots/dark.png) | ![dialog](screenshots/dialog.png) |

## Demo Video

[Watch the demo](PASTE_YOUR_VIDEO_LINK_HERE)