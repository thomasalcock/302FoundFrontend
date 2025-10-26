# threeotwo_found_frontend

A concise Flutter frontend for the "302 Found" project — mobile app with background location handling, local notifications and simple user/trusted-person management.

## Key features
- Background location handler and background isolate service (see [`lib/main.dart`](lib/main.dart:1)).
- Local notifications integration for foreground/background flows.
- Trusted persons UI and account editor UI for managing contacts.
- HTTP helper services with development stubs to keep the UI responsive during local development.
- Lightweight service layer designed for easy testing and backend swap-out.

## Main libraries (from [`doc/api/index.html`](doc/api/index.html:1))
- `gui\account\account_view` — 302FoundFrontend (2025) - Account UI: view and edit current user attributes. (see [`lib/gui/account/account_view.dart`](lib/gui/account/account_view.dart:1))
- `gui\account\modifiable_attribute` — 302FoundFrontend (2025) - Small helper widget to display and edit an attribute. (see [`lib/gui/account/modifiable_attribute.dart`](lib/gui/account/modifiable_attribute.dart:1))
- `gui\app_bar` — 302FoundFrontend (2025) - AppBar widget used across the app. (see [`lib/gui/app_bar.dart`](lib/gui/app_bar.dart:1))
- `gui\trustedPersons\trusted_person_form` — 302FoundFrontend (2025) - Form widget to collect a trusted person's contact details. (see [`lib/gui/trustedPersons/trusted_person_form.dart`](lib/gui/trustedPersons/trusted_person_form.dart:1))
- `gui\trustedPersons\trusted_persons_list_view` — 302FoundFrontend (2025) - Trusted persons list UI. (see [`lib/gui/trustedPersons/trusted_persons_list_view.dart`](lib/gui/trustedPersons/trusted_persons_list_view.dart:1))
- `logic\handler\location_handler` — Background/location handler, queueing and upload logic. (see [`lib/logic/handler/location_handler.dart`](lib/logic/handler/location_handler.dart:1))
- `logic\models\location` — Location model. (see [`lib/logic/models/location.dart`](lib/logic/models/location.dart:1))
- `logic\models\trust` — Trust model. (see [`lib/logic/models/trust.dart`](lib/logic/models/trust.dart:1))
- `logic\models\user` — User model. (see [`lib/logic/models/user.dart`](lib/logic/models/user.dart:1))
- `logic\services\location_service` — 302FoundFrontend (2025) - Service: Location API helpers. (see [`lib/logic/services/location_service.dart`](lib/logic/services/location_service.dart:1))
- `logic\services\trust_service` — 302FoundFrontend (2025) - Service for Trust (trusted persons) API access. (see [`lib/logic/services/trust_service.dart`](lib/logic/services/trust_service.dart:1))
- `logic\services\user_service` — 302FoundFrontend (2025) - Service: User API helpers. (see [`lib/logic/services/user_service.dart`](lib/logic/services/user_service.dart:1))

## Quick setup & development
Prerequisites: Flutter SDK (stable), platform tooling for Android/iOS as required.

1. Fetch dependencies:
```bash
flutter pub get
```

2. Run on a device or emulator:
```bash
flutter run -d <device-id>
```
The app's entry is [`lib/main.dart`](lib/main.dart:1). Background service initialization and iOS background callback handling are implemented there.

3. Production API configuration
- In development (default) the services use `http://localhost:3000`.
- For production set the API base URL at build time:
```bash
flutter build apk --dart-define=API_URL=https://api.example.com
```
Services read `API_URL` via `const String.fromEnvironment('API_URL')` (see [`lib/logic/services/*.dart`](lib/logic/services/location_service.dart:1)).

## Running tests
Use the standard Flutter test runner:
```bash
flutter test
```
(There are no special test runners configured — add tests under `test/` as needed.)

## REST API services & caveats
- The project provides HTTP helper services for User, Location and Trust resources (`lib/logic/services/*.dart`). In development mode these services return stubbed data so the UI remains usable without a running backend.
- The API base is controlled by the environment and defaults to `http://localhost:3000` when not built for production.
- From the package docs: "The REST-API Services contain additional REST Features that are not used. Cause of the intelligent Compiler they are not reducing performance but they could be neat later or for Open Source User." Expect unused endpoints / extra helpers to remain harmless but available.
- Notable behaviour:
  - `LocationService.uploadPayload(...)` will return `true` in development to let background handlers clear queues locally; in production it POSTs JSON to the API and returns whether the HTTP status is 2xx.
  - API methods throw on non-success HTTP codes; callers should handle exceptions.

## Useful file references
- App entry / background wiring: [`lib/main.dart`](lib/main.dart:1)
- Location handler: [`lib/logic/handler/location_handler.dart`](lib/logic/handler/location_handler.dart:1)
- Services: [`lib/logic/services/location_service.dart`](lib/logic/services/location_service.dart:1), [`lib/logic/services/trust_service.dart`](lib/logic/services/trust_service.dart:1), [`lib/logic/services/user_service.dart`](lib/logic/services/user_service.dart:1)
- UI: [`lib/gui/trustedPersons/trusted_persons_list_view.dart`](lib/gui/trustedPersons/trusted_persons_list_view.dart:1), [`lib/gui/account/account_view.dart`](lib/gui/account/account_view.dart:1)

## Contributing
Contributions welcome. Please open issues or PRs. Add tests for new behaviour and follow existing code style.

## License
TBD — add a LICENSE file (e.g. MIT, Apache-2.0) and update this section.