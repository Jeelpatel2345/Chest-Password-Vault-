# Chest — Password Vault 🔐

A local-first, privacy-focused Flutter mobile application designed for storing and managing personal credentials with a modern, ChatGPT-inspired dark-gray interface.

---

## ✨ Features

- **Local-First & Offline Storage:** Credentials are saved locally on your device without third-party cloud accounts, tracking, or telemetry.
- **ChatGPT-Inspired Dark Theme:** Refined dark-gray Material 3 palette (`#212121` background, `#2B2B2B` surfaces, `#303030` dialogs, and `#3A3A3A` subtle borders).
- **Password Obfuscation & Toggle:** Passwords are kept masked (`••••••••••••`) by default with an eye toggle to temporarily reveal them.
- **In-Place Credential Editing:** Long-press any credential (or tap options) to edit website name, username, or password without having to delete and re-create.
- **Swipe-to-Bin (Soft Delete):** Swipe left on any card to move it to the Bin, complete with an instant **Undo** SnackBar.
- **Multi-Select & Batch Binning:** Switch to selection mode to select multiple credentials and move them to the Bin in one tap.
- **Dedicated Bin Screen:** View deleted items, restore them back to the active vault anytime, or permanently purge them.
- **One-Tap Clipboard Copy:** Quick-copy buttons for username and password with toast feedback.
- **Zero-Overflow Responsive UI:** Fully scrollable modal dialogs and constrained text layouts that adapt smoothly across small screens and open virtual keyboards.
- **Zero Password Logging:** Passwords are masked as `[PROTECTED]` in internal string representations to prevent exposure in logs.

---

## 📱 Screenshots & Design

The app includes a custom pixel-art **Chest** application launcher icon and a clean single-screen vault interface:
- **Home Screen:** Scrollable list of active credentials with search, add, selection mode, and Bin navigation.
- **Add / Edit Modal Dialog:** Centered form with full validation and obscured password input.
- **Bin / Recycle Screen:** Dedicated interface for managing soft-deleted credentials with restore & permanent delete options.

---

## 🛠️ Project Architecture

Built following clean layered architecture (Service-Repository pattern):

```text
lib/
├── main.dart                      # App entry point, MaterialApp setup, and theme injection
├── models/
│   └── password_item.dart         # Credential entity, JSON serialization, copyWith, & safe toString
├── services/
│   ├── storage_service.dart       # Abstract interface decoupling UI from storage
│   └── local_storage_service.dart # SharedPreferences local persistence implementation
├── theme/
│   └── app_theme.dart             # Material 3 dark-gray design tokens & widget themes
├── widgets/
│   ├── add_credential_dialog.dart # Modal dialog supporting both Add and Edit modes
│   ├── credential_card.dart       # Card with password reveal, copy, long-press options, & multi-select
│   └── empty_state.dart           # Polished zero-data illustration & action button
└── pages/
    ├── home_page.dart             # Main screen, swipe-to-bin, multi-select toolbar, and coordination
    └── bin_page.dart              # Deleted items screen with restore and permanent delete
```

---

## 🧪 Testing & Code Quality

The project includes unit, service, and widget tests:

```bash
# Run all unit and widget tests
flutter test

# Run static analysis
flutter analyze

# Verify code formatting
dart format --output=none --set-exit-if-changed .
```

All 15 automated tests pass with 0 analyzer issues.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.19+ / Dart 3.3+)
- Android Studio / VS Code with Flutter extension
- Android device or emulator (API 21+)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Jeelpatel2345/Chest-Password-Vault-.git
   cd Chest-Password-Vault-
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🛡️ Security & V2 Roadmap

- **V1 (Current Prototype):** Fast, offline local persistence using `SharedPreferences`. In accordance with OWASP MASVS-STORAGE guidelines, V1 is a personal functional prototype.
- **V2 Roadmap:**
  - AES-256 local database encryption (SQLCipher / `flutter_secure_storage`).
  - Hardware-backed key management via Android Keystore & iOS Keychain.
  - Biometric unlock (Fingerprint / Face ID) via `local_auth`.
  - Auto-lock on app backgrounding and inactive timeouts.
  - Screen protection (`FLAG_SECURE`) to prevent OS-level screenshots and app switcher previews.
  - Automated clipboard clearing after 30 seconds.

---

## 📄 License

This project is licensed under the MIT License.
