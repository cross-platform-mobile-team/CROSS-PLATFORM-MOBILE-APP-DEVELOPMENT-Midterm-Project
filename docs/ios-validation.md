# iOS validation handoff

The iOS runner was generated with Flutter 3.47.1 on 14 September 2026.
This is configuration work, not evidence of an iOS build or runtime pass.
Windows cannot run Xcode or Apple's iOS Simulator.

On a Mac with Xcode and the matching Flutter SDK:

```sh
flutter doctor -v
flutter pub get
flutter build ios --simulator --debug
open -a Simulator
flutter devices
flutter test integration_test/independent_scenarios_test.dart -d <simulator-id>
flutter test integration_test/persisted_scenarios_test.dart -d <simulator-id>
flutter test integration_test/windows_workflow_test.dart -d <simulator-id>
flutter test integration_test/quick_create_exit_test.dart -d <simulator-id>
flutter run -d <simulator-id>
```

The windows_workflow_test filename is historical; its Flutter/preference
workflows are candidates for native verification, not Windows API calls.
Record any platform-specific test limitation rather than assuming these pass.
Verify keyboard appearance, safe areas, portrait/landscape, large text, CRUD,
search/filter/sort, relaunch persistence and VoiceOver on the actual simulator.

Account mode needs a running backend. Use --dart-define=API_BASE_URL=https://...
with an authorized reachable HTTPS endpoint. The default loopback address only
works with a backend on the appropriate host; a physical iPhone's loopback is
the phone itself. No broad App Transport Security exception has been enabled.
Physical-device release requires the team's signing identity in Xcode. Do not
commit signing secrets. Current iOS build, install and E2E status: NOT RUN.

Reference: https://docs.flutter.dev/platform-integration (accessed 2026-09-14).
