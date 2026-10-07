# Password Vault — Antigravity Master Project Brief

## 1. Project Overview

### Project name
**Password Vault**

### Project type
A local-first Flutter mobile application for storing personal login credentials in one organized place.

### Primary goal
The first version (V1) should be simple, clean, fast, and easy to use. The user wants to store:

- App / Website name
- ID / Username / Email
- Password

The app should display saved credentials as a list and allow the user to add a new credential through a centered popup dialog.

### Important scope decision

This is a **V1 prototype / personal storage app**, not a production-grade password manager yet.

For V1, prioritize:
1. Correct functionality
2. Professional UI
3. Local persistence
4. Simple architecture
5. Easy future migration to stronger security

Do **not** over-engineer V1 with cloud accounts, backend APIs, synchronization, subscriptions, or complicated authentication unless explicitly requested later.

However, passwords are inherently sensitive. The implementation should avoid unnecessary exposure even in V1, and the architecture must leave a clean path toward secure storage in V2.

---

# 2. Core User Problem

The user frequently forgets credentials for different applications and websites.

The app solves this by providing one local vault where the user can save:

| Field | Example |
|---|---|
| App / Website | GitHub |
| ID | jeel@example.com |
| Password | MyPassword123 |

The user opens the app, sees all saved credentials, and can quickly add another credential.

---

# 3. V1 Functional Requirements

## 3.1 Home Screen

When the application opens, show a professional dark-gray interface inspired by the visual simplicity of ChatGPT.

The home screen must contain:

### App Bar
- App title: **Password Vault**
- One prominent **Add Credential** button
- The add button can use a plus icon
- The app bar should remain visually clean

Example:

```text
┌──────────────────────────────────────────────┐
│  Password Vault                         +    │
└──────────────────────────────────────────────┘
```

### Body

Display all stored credentials in a vertically scrollable list.

Each credential should show:

- App / Website name
- ID / Username / Email
- Password

Passwords should preferably be masked in the list:

```text
GitHub
jeel@example.com
••••••••••
```

The password can have a visibility control if implemented in V1.

Example card:

```text
┌─────────────────────────────────────────────┐
│  🔐  GitHub                            👁   │
│      jeel@example.com                       │
│      ••••••••••••                           │
└─────────────────────────────────────────────┘
```

---

# 4. Add Credential Flow

When the user clicks the Add button in the AppBar, show a centered modal popup/dialog.

The popup must ask for:

1. App / Website Name
2. ID / Username / Email
3. Password

Example:

```text
┌─────────────────────────────────────┐
│        Add Credential               │
│                                     │
│ App / Website Name                  │
│ [ GitHub                         ]  │
│                                     │
│ ID / Username / Email               │
│ [ jeel@example.com               ]  │
│                                     │
│ Password                            │
│ [ •••••••••••••                  ]  │
│                                     │
│              Cancel     Save        │
└─────────────────────────────────────┘
```

### Dialog requirements

- Centered on screen
- Rounded corners
- Dark-gray surface
- Clear labels
- Password field uses obscured text
- Save button is visually prominent
- Cancel button closes the dialog
- Validate required fields
- Do not save an incomplete credential
- Clear controllers after successful save

---

# 5. V1 Credential Operations

Required:

### Create
Add a new credential.

### Read
Display saved credentials.

### View password
Allow the user to temporarily reveal the password.

### Delete
Allow the user to delete a credential.

Recommended:
- Ask for confirmation before deletion.

Optional for V1:
- Edit credential
- Search credentials
- Copy username
- Copy password

These can be added after the basic application works.

---

# 6. Empty State

If there are no credentials, do not show a blank screen.

Show a professional empty state:

```text
             🔐

       No credentials yet

Store your first app or website
credential to get started.

       + Add Credential
```

This makes the application feel complete.

---

# 7. Suggested Project Architecture

Use a simple separation of concerns.

```text
lib/
├── main.dart
├── models/
│   └── password_item.dart
├── pages/
│   └── home_page.dart
├── services/
│   └── storage_service.dart
└── widgets/
    ├── credential_card.dart
    ├── add_credential_dialog.dart
    └── empty_state.dart
```

If Antigravity determines that widgets would be unnecessary for a very small V1, it may initially keep the dialog/card inside `home_page.dart`, but the architecture should remain easy to refactor.

---

# 8. Data Model

Recommended model:

```dart
class PasswordItem {
  String appName;
  String username;
  String password;

  PasswordItem({
    required this.appName,
    required this.username,
    required this.password,
  });
}
```

Serialization should support local persistence.

Recommended fields for future expansion:

```text
id
appName
username
password
websiteUrl
notes
category
createdAt
updatedAt
favorite
```

Do not add all future fields to the UI unless they are required.

---

# 9. V1 Storage Strategy

For the initial prototype, local persistence is required so credentials remain after the app closes and reopens.

Possible V1 approach:
- Local application storage
- A simple serializable list
- `shared_preferences` can be used for a basic prototype

But this is a deliberate **V1 convenience decision**, not the final security architecture.

### Important security limitation

Passwords should NOT remain in plaintext storage in the production version.

OWASP identifies storing sensitive data such as passwords unencrypted in private storage as a security weakness. OWASP also recommends protecting cryptographic keys with platform secure storage such as Android Keystore and iOS Keychain.

Therefore:

**V1 = functionality/prototype**
**V2 = secure vault**

Do not falsely describe the V1 app as a secure password manager.

---

# 10. Security Research and V2 Roadmap

Passwords are highly sensitive data.

OWASP's Mobile Application Security Verification Standard has a dedicated storage category, MASVS-STORAGE, covering secure storage and prevention of sensitive-data leakage.

Important security principles:

### 10.1 Never hardcode passwords or encryption keys

Credentials must never be placed in source code.

Do not do:

```dart
const password = "MyPassword123";
```

Do not hardcode encryption keys into Dart source.

### 10.2 Avoid plaintext storage

Do not use ordinary preferences as the final production storage mechanism for passwords.

A prototype may use simple local persistence temporarily, but V2 should migrate sensitive secrets to secure storage/encrypted storage.

### 10.3 Protect encryption keys

If the application encrypts its database, the encryption key must not simply be stored next to the encrypted database.

Use platform secure key management:
- Android Keystore
- iOS Keychain

### 10.4 Avoid password logging

Never print passwords:

```dart
print(password);
debugPrint(password);
```

Do not log the complete credential object.

### 10.5 Protect UI exposure

Future versions should consider:
- Screenshot protection where appropriate
- Clipboard timeout/clearing
- Password auto-hide
- Biometric authentication
- App lock
- Lock after inactivity
- Secure keyboard/input handling where appropriate
- Backup considerations
- No sensitive information in analytics/crash logs

### 10.6 Secure V2 architecture

A stronger version could use:

```text
Flutter UI
    ↓
Vault Controller / Repository
    ↓
Encrypted Local Database
    ↓
Encryption Key
    ↓
Android Keystore / iOS Keychain
```

For a mature implementation, use envelope encryption or an equivalent well-designed approach rather than inventing custom cryptography.

### 10.7 Authentication

Future versions may add:

- Master password
- PIN
- Fingerprint
- Face unlock
- Device authentication

The application should never store the master password in plaintext.

### 10.8 Cloud synchronization

Cloud sync should NOT be added just because it is convenient.

If sync is added later, the preferred architecture is:

```text
Device A
   ↓
Encrypt locally
   ↓
Encrypted data
   ↓
Cloud
   ↓
Encrypted data
   ↓
Device B
   ↓
Decrypt locally
```

The server should not need to know the user's plaintext passwords.

---

# 11. UI / UX Direction

## Design language

Use a modern dark-gray interface inspired by ChatGPT.

The goal is **not** to copy ChatGPT's branding or UI exactly.

Use the following characteristics:

- Dark gray background
- Slightly lighter gray cards
- High-contrast text
- Subtle borders
- Rounded corners
- Comfortable spacing
- Clean typography
- Minimal visual noise
- Material 3 principles
- Smooth but restrained animations
- Professional developer-tool feel

Suggested palette direction:

```text
Background       #212121 / similar dark gray
Surface          #2B2B2B
Elevated Surface #303030
Primary Text     #F5F5F5
Secondary Text   #AFAFAF
Border           #3A3A3A
Accent           restrained blue/green/white
```

Do not blindly use these exact values if the design system can produce a better accessible result.

---

# 12. UI Components

## AppBar

Contains:

```text
Password Vault                         +
```

The Add action should be easy to reach.

## Credential Card

Each card should contain:

```text
App/Website
ID
Password
```

Optional actions:

```text
View
Copy
Edit
Delete
```

Do not overload the card with too many icons.

## Password Display

Default:

```text
••••••••••••
```

When visibility is enabled:

```text
MyPassword123
```

The revealed state should be temporary or easily reversible.

---

# 13. Responsive Design

The application is primarily a mobile Flutter application.

It should still behave correctly on:
- Small Android phones
- Large Android phones
- Tablets
- Desktop Flutter preview if tested

Avoid fixed-width dialogs that overflow.

Use:
- SafeArea
- SingleChildScrollView where necessary
- Flexible/Expanded carefully
- Responsive dialog constraints

---

# 14. Accessibility

Use:
- Readable font sizes
- Strong contrast
- Large enough touch targets
- Meaningful labels
- Tooltips for icon-only actions
- Semantic labels where useful

Do not depend only on color to communicate state.

---

# 15. Validation

When adding a credential:

### App/Website Name
Required.

### ID
Required.

### Password
Required.

If a field is empty:

```text
Please enter the App / Website name.
```

Similar validation should exist for ID and password.

Avoid displaying passwords inside validation errors.

---

# 16. Error Handling

The app should gracefully handle:
- Storage read failure
- Storage write failure
- Invalid/corrupt saved data
- Empty input
- Dialog cancellation

Show user-friendly messages.

Never expose technical stack traces or sensitive values in the UI.

---

# 17. State Management

V1 does not require a heavy state-management framework.

For a small app, Flutter's:
- `StatefulWidget`
- `setState`
- repository/service abstraction

is sufficient.

If the project grows, it can migrate to:
- Riverpod
- Bloc
- Provider

Do not add complexity without a reason.

---

# 18. Recommended Development Phases

## Phase 1 — Foundation

- Create Flutter project
- Configure Material 3
- Set dark theme
- Create folder structure
- Create model
- Create storage service

## Phase 2 — Home Screen

- AppBar
- Add button
- Credential list
- Empty state
- Credential card

## Phase 3 — Add Credential

- Center dialog
- App/Website field
- ID field
- Password field
- Validation
- Save action

## Phase 4 — Credential Actions

- Reveal/hide password
- Delete
- Delete confirmation
- Optional edit

## Phase 5 — Persistence Testing

Test:
1. Add credential
2. Close app
3. Reopen app
4. Verify credential remains
5. Delete credential
6. Reopen app
7. Verify deletion remains

## Phase 6 — UI Polish

- Spacing
- Typography
- Icons
- Animations
- Empty state
- Loading state
- Error state
- Responsive dialog

## Phase 7 — V2 Security

After V1 is stable:
- Secure storage
- Encryption
- Platform keystore
- Biometric unlock
- App lock
- Clipboard controls
- Screenshot/privacy controls
- Backup strategy
- Secure deletion
- Security testing

---

# 19. Testing Checklist

## Functional

- [ ] App launches
- [ ] Empty state appears
- [ ] Add button opens dialog
- [ ] Dialog is centered
- [ ] All three fields work
- [ ] Password is obscured
- [ ] Required validation works
- [ ] Save creates credential
- [ ] Credential appears immediately
- [ ] Credential survives restart
- [ ] Password can be revealed
- [ ] Delete works
- [ ] Delete confirmation works

## UI

- [ ] Dark-gray theme
- [ ] No overflow
- [ ] No clipped text
- [ ] Keyboard does not cover fields
- [ ] Dialog scrolls on small screens
- [ ] Touch targets are usable
- [ ] Empty state looks intentional
- [ ] Cards are visually consistent

## Security baseline for V1

- [ ] No password in debug logs
- [ ] No password hardcoded in source
- [ ] No credentials sent to a server
- [ ] No unnecessary permissions
- [ ] No public/external file storage for credentials
- [ ] V1 documentation clearly says plaintext prototype storage is not production secure

---

# 20. Future Feature Roadmap

After V1 works correctly:

### V1.1
- Search
- Edit
- Copy ID
- Copy password
- Favorites
- Categories

### V1.2
- Secure storage
- Password encryption
- Biometric unlock
- Auto-lock

### V1.3
- Password generator
- Password strength indicator
- Notes
- Website URL
- Credential icons

### V2
- Encrypted database
- Hardware-backed key protection
- Secure backup
- Encrypted export/import
- Optional encrypted cloud synchronization

### V3
- Multi-device synchronization
- Browser integration
- Autofill
- Advanced security auditing

---

# 21. Suggested Final V1 Folder Structure

```text
lib/
├── main.dart
├── models/
│   └── password_item.dart
├── pages/
│   └── home_page.dart
├── services/
│   └── storage_service.dart
├── widgets/
│   ├── credential_card.dart
│   ├── add_credential_dialog.dart
│   └── empty_state.dart
└── theme/
    └── app_theme.dart
```

---

# 22. Antigravity Prompt 1 — Analyze and Create Implementation Plan

Copy the following prompt into Antigravity first:

```text
You are the senior Flutter software architect for this project.

I am giving you the complete project research/specification for a Flutter application called "Password Vault".

YOUR FIRST TASK IS NOT TO BUILD THE APPLICATION.

First, deeply analyze the entire project specification and create a complete implementation plan.

Project goal:
Create a local-first Flutter mobile application where the user can store credentials consisting of:
1. App / Website Name
2. ID / Username / Email
3. Password

V1 UI:
- Professional dark-gray UI inspired by the simplicity of ChatGPT
- AppBar with "Password Vault"
- Add Credential button in the AppBar
- Body contains a list of saved credentials
- Each credential displays App/Website name, ID, and masked password
- Clicking Add Credential opens a centered modal popup
- Popup asks for App/Website Name, ID, and Password
- Save adds the credential to the list and persists it locally
- Password should be hidden by default
- User should be able to reveal the password
- User should be able to delete credentials
- Empty state should be professional

Important scope:
This is V1, a functional personal/local prototype. Do not add unnecessary backend, login, cloud sync, or complex state management.

Architecture:
Use clean separation between:
- models
- pages
- services
- reusable widgets
- theme

Preferred structure:

lib/
├── main.dart
├── models/
│   └── password_item.dart
├── pages/
│   └── home_page.dart
├── services/
│   └── storage_service.dart
├── widgets/
│   ├── credential_card.dart
│   ├── add_credential_dialog.dart
│   └── empty_state.dart
└── theme/
    └── app_theme.dart

For V1, simple local persistence is acceptable. However, explicitly identify that plaintext password storage is not appropriate for a production password manager.

Analyze:
1. Functional requirements
2. Non-functional requirements
3. UI/UX requirements
4. Data model
5. Local storage strategy
6. Flutter architecture
7. State management choice
8. Folder/file responsibilities
9. Navigation requirements
10. Dialog/form behavior
11. Validation rules
12. Error handling
13. Responsive design
14. Accessibility
15. Testing strategy
16. Security risks
17. V2 security migration strategy
18. Future scalability
19. Dependency recommendations
20. Potential implementation risks

Then create a step-by-step implementation plan.

For every implementation phase, provide:
- Objective
- Files involved
- What will be implemented
- Dependencies
- Acceptance criteria
- Testing checklist
- Potential issues

Do not write the complete application yet.

At the end, provide:
A. Final recommended architecture
B. Final file tree
C. Dependency list
D. Development order
E. V1 acceptance checklist
F. V2 security roadmap

Do not change the core product requirements without explaining why.
Do not introduce unnecessary technologies.
Prioritize maintainability and clean Flutter code.
```

---

# 23. Antigravity Prompt 2 — Build the Application

After reviewing/approving the implementation plan, send this prompt:

```text
Now implement the Password Vault Flutter application according to the approved implementation plan and the project specification.

Build the actual application.

CORE PRODUCT:

Application name:
Password Vault

Purpose:
A local-first Flutter application for storing personal app/website credentials.

V1 credential fields:
- App / Website Name
- ID / Username / Email
- Password

HOME SCREEN:

When the application opens:

1. Show a dark-gray professional interface inspired by the simplicity of ChatGPT.
2. Do not copy ChatGPT branding, logos, or proprietary UI.
3. Use Material 3.
4. AppBar title:
   "Password Vault"
5. AppBar contains a clear Add Credential button/icon.
6. The body displays all saved credentials.
7. Credentials must be scrollable.
8. If no credentials exist, show a professional empty state.

CREDENTIAL CARD:

Each card should clearly show:

App / Website Name
ID / Username / Email
Masked Password

Example:

GitHub
jeel@example.com
••••••••••••

Add a visibility action to reveal/hide the password.

Also provide delete functionality.

Prefer a clean card layout with:
- rounded corners
- subtle border
- dark surface
- clear typography
- good spacing
- no excessive icons

ADD CREDENTIAL:

When the user clicks the Add Credential button:

Open a centered modal dialog.

The dialog must contain:

1. App / Website Name
2. ID / Username / Email
3. Password

Password field:
- obscure text by default
- include show/hide password control

Dialog buttons:
- Cancel
- Save

Save behavior:
- validate all required fields
- reject empty fields
- create PasswordItem
- save it through the storage service
- immediately update the list
- close the dialog
- clear controllers
- do not expose the password in logs

DELETE:

When deleting a credential:
- ask for confirmation
- delete it from the list
- persist the new list
- update UI immediately

PERSISTENCE:

The V1 app must remember credentials after:
- closing the app
- restarting the app

Keep storage behind a StorageService so the storage implementation can later be replaced with encrypted storage without rewriting the UI.

IMPORTANT SECURITY LIMIT:

This is V1 and is being built primarily for functionality.

Do not falsely claim that simple local preference storage is secure password-manager storage.

Do not:
- print passwords
- hardcode passwords
- hardcode encryption keys
- send credentials to a server
- store credentials in public/external storage
- add cloud sync without explicit approval

Prepare the architecture so V2 can migrate to:
- encrypted local database/storage
- Android Keystore
- iOS Keychain
- biometric authentication
- app auto-lock
- secure clipboard handling
- screenshot/privacy protections
- encrypted backup

UI STYLE:

Create a premium dark-gray application.

Visual direction:
- ChatGPT-like dark neutral environment
- modern
- minimal
- professional
- clean
- comfortable spacing
- rounded cards
- subtle borders
- high contrast
- Material 3
- restrained animations

Suggested colors may be adjusted for accessibility:
- Background: approximately #212121
- Surface: approximately #2B2B2B
- Elevated surface: approximately #303030
- Primary text: approximately #F5F5F5
- Secondary text: approximately #AFAFAF
- Border: approximately #3A3A3A

Do not make the UI overly colorful.

RESPONSIVE BEHAVIOR:

The dialog must work on small screens and when the keyboard is open.

Prevent:
- RenderFlex overflow
- clipped text
- buttons going off-screen
- dialog content being hidden by keyboard

Use appropriate scrolling and responsive constraints.

CODE QUALITY:

Use null-safe Dart.

Use:
- meaningful names
- small reusable widgets
- clean architecture
- comments only where useful
- no unnecessary dependencies
- no dead code
- no duplicated storage logic

Recommended structure:

lib/
├── main.dart
├── models/
│   └── password_item.dart
├── pages/
│   └── home_page.dart
├── services/
│   └── storage_service.dart
├── widgets/
│   ├── credential_card.dart
│   ├── add_credential_dialog.dart
│   └── empty_state.dart
└── theme/
    └── app_theme.dart

DEPENDENCIES:

Keep V1 dependency count small.

A simple local persistence package may be used for the prototype.

Do not add Firebase, Supabase, backend APIs, authentication servers, or cloud synchronization.

TESTING:

After implementation, verify:

1. App starts successfully.
2. Home screen renders.
3. Empty state renders.
4. Add button opens centered dialog.
5. App/Website field works.
6. ID field works.
7. Password field works.
8. Password is obscured.
9. Validation works.
10. Save works.
11. New credential immediately appears.
12. Password can be revealed/hidden.
13. Delete confirmation works.
14. Delete works.
15. Data survives app restart.
16. No UI overflow occurs.
17. Keyboard does not hide the form.
18. No password is printed to logs.

IMPORTANT:

Do not stop at generating a plan.
Actually create/update the Flutter source files in the project.

Before finishing:
- run formatting
- run static analysis
- fix analyzer errors
- run available tests
- resolve compilation errors
- verify the final application flow

At the end, report:
1. Files created/modified
2. Dependencies added
3. Features implemented
4. Tests performed
5. Any remaining warnings
6. What should be done next for V1.1
7. What should be done for V2 security

Build the application professionally rather than as a basic tutorial/demo.
```

---

# 24. Research Sources

The security guidance in this document is based primarily on OWASP Mobile Application Security guidance.

### OWASP MASVS — Mobile Application Security Verification Standard
https://mas.owasp.org/MASVS/

### OWASP MASVS-STORAGE
https://mas.owasp.org/MASVS/05-MASVS-STORAGE/

### OWASP MASVS-STORAGE-1
https://mas.owasp.org/MASVS/controls/MASVS-STORAGE-1/

### OWASP — Sensitive Data Stored Unencrypted in Private Storage
https://mas.owasp.org/MASWE/MASVS-STORAGE/MASWE-0001/

### OWASP — Cryptographic Keys Stored Outside Platform Keystore
https://mas.owasp.org/MASWE/MASVS-STORAGE/MASWE-0003/

### OWASP — Sensitive Data in Logs
https://mas.owasp.org/MASWE/MASVS-STORAGE/MASWE-0005/

### OWASP — Android Data Storage Testing
https://mas.owasp.org/MASTG/0x05d-Testing-Data-Storage/

---

# 25. Final Product Definition

The final V1 application should feel like a small, polished personal password vault rather than a tutorial project.

The essential user experience is:

```text
OPEN APP
   ↓
Password Vault Home
   ↓
See saved credentials
   ↓
Tap "+"
   ↓
Centered Add Credential dialog
   ↓
Enter:
   App/Website
   ID
   Password
   ↓
Tap Save
   ↓
Credential appears in list
   ↓
Password is masked
   ↓
User can reveal or delete it
   ↓
Data remains after app restart
```

The most important principle is:

**Build V1 simple and functional, but architect it so that V2 can become a genuinely secure password vault without rewriting the entire application.**
