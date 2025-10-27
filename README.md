# StoryWeaver (Joyce's.ink)

A Flutter app for journaling and AI-assisted story creation. It uses Supabase for auth/storage and an LLM provider (OpenAI-compatible or Gemini) for story generation with structured Markdown output.

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Setup

1) Install dependencies

```bash
flutter pub get
```

2) Configure environment variables (env.json)

Create an `env.json` in the project root (already included locally). Do NOT commit real secrets. Example:

{
"SUPABASE_URL": "https://YOUR_PROJECT.supabase.co",
"SUPABASE_ANON_KEY": "YOUR_SUPABASE_ANON_KEY",

// LLM provider selection: "gpt" uses an OpenAI-compatible endpoint; "gemini" uses Google Gemini APIs
"PROVIDER": "gpt",

// For Gemini provider
"GEMINI_API_KEY": "YOUR_GEMINI_API_KEY",

// Optional: LLM debugging (prints redacted request/response info)
"LLM_DEBUG": "false",

// Optional: HTTP proxy
"PROXY_ENABLED": "false",
"PROXY_HOST": "",
"PROXY_PORT": "7890",
"PROXY_ALLOW_BAD_CERT": "false",

// Optional: OAuth/Payments (only if wiring is enabled in your build)
"GOOGLE_WEB_CLIENT_ID": "",
"STRIPE_PUBLISHABLE_KEY": ""
}

3) Run the app with env.json

To run the app with environment variables defined in an env.json file, follow the steps mentioned below:

CLI

```bash
flutter run --dart-define-from-file=env.json
```

VS Code

- Open .vscode/launch.json (create it if it doesn't exist).
- Add or modify your launch configuration to include --dart-define-from-file:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define-from-file", "env.json"]
    }
  ]
}
```

IntelliJ / Android Studio

- Go to Run > Edit Configurations.
- Select your Flutter configuration or create a new one.
- Add the following to the "Additional arguments" field:

```
--dart-define-from-file=env.json
```

## 📁 Project Structure

```
storyweaver/
├── android/            # Android config and deep links
├── ios/                # iOS config (Info.plist, URL schemes)
├── lib/
│   ├── core/           # App exports
│   ├── presentation/   # Screens and widgets
│   │   ├── login_screen/ (forgot + reset password screens)
│   │   ├── story_generation_screen/
│   │   ├── story_library_screen/
│   │   ├── user_profile_screen/ (avatar upload, logout)
│   │   └── journal_home_screen/
│   ├── routes/         # Route definitions (with navigatorKey)
│   ├── services/       # Auth, LLM, storage, payments
│   ├── theme/          # App theme
│   ├── widgets/        # Reusable components
│   └── main.dart       # App entry; listens for Supabase recovery
├── assets/             # Images and other assets
├── env.json            # Local env vars (do not commit secrets)
├── pubspec.yaml        # Dependencies and config
└── README.md           # This file
```

## 🔐 Authentication & Deep Links

- Auth: Supabase email/password (login, register, change password, logout)
- Forgot/Reset password:
  - The app listens to auth recovery events and navigates in-app to the Reset Password screen.
  - Supabase redirect should be set to `io.supabase.flutter://reset-callback`.
- Deep link configuration:
  - iOS: `ios/Runner/Info.plist` has `CFBundleURLTypes` scheme `io.supabase.flutter`.
  - Android: Intent filter added in `android/app/src/main/AndroidManifest.xml` for the same scheme.

## 🧠 Story Generation

- Providers: OpenAI-compatible (via OhMyGPT) or Gemini.
- Model configured via env: `OHMYGPT_MODEL` for "gpt" provider or the default Gemini model in code.
- Structured output: stories are generated between explicit markers and rendered as Markdown.
- Optional proxy support and debug logging for LLM requests.

## 👤 Profile

- Shows real user name and email from Supabase.
- Avatar upload on tap (stored in Supabase Storage, updates `avatar_url`).
- Logout icon in the profile header.
- Removed: Delete Account and Change Email UI.

## 🧾 Notes on Privacy Permissions (iOS)

`Info.plist` includes these usage descriptions:

- `NSPhotoLibraryUsageDescription`: access to select a profile picture
- `NSCameraUsageDescription`: access to take a profile picture

If you customize the avatar capture flow, ensure these remain accurate.

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

See `lib/routes/app_routes.dart` for route constants and the global `navigatorKey` used for deep-link-driven navigation.

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:

- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```

## 📦 Build & Deployment

Build the application for production:

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## ⚠️ Security

- Never commit real API keys or secrets. Use `env.json` locally and your CI/CD’s secure variables for builds.
- Rotate keys if they were accidentally exposed.

## ❓ Troubleshooting

- If stories fail to save, ensure Supabase enums/UUIDs are valid and that you’re authenticated.
- If LLM calls fail, check `PROVIDER`, base URL, API key, and network/proxy settings. Enable `LLM_DEBUG=true` to troubleshoot.
- For password reset links not opening in-app, verify:
  - Supabase redirect URL is `io.supabase.flutter://reset-callback`.
  - Android manifest and iOS Info.plist deep-link settings.

## 🙏 Acknowledgments

- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design
