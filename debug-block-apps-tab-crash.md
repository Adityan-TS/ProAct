[OPEN] Debug Session: block-apps-tab-crash

## Symptom
- When user opens the Block Apps feature tab, the app crashes.

## Expected
- Block Apps tab opens without crashing (or shows a friendly “Not supported on this platform” message if unavailable).

## Environment
- OS: Windows (dev)
- Platform under test: (TBD: web / android / ios)

## Hypotheses (falsifiable)
1) A platform-only plugin (usage_stats / new_device_apps / method channel) is called on Web/iOS and throws (MissingPluginException / UnimplementedError).
2) A required permission/service initialization is missing, causing a PlatformException during Block Apps screen init.
3) Null/empty state (e.g., stored passcode / shared prefs / hive box) is accessed without checks when opening Block Apps.
4) Route wiring or arguments to the Block Apps screen are invalid, causing a runtime exception during navigation/build.
5) A background service / method channel returns unexpected data (null / wrong shape), causing parsing or casting crash.

## Evidence to Collect
- Stack trace and “where” (which route/widget) the crash occurs
- Platform + device info
- The last successful navigation event before crash

## Instrumentation Plan
- Add debug-point network logs at:
  - Block Apps tab tap handler (before navigation)
  - Block Apps screen initState/build
  - Any method-channel/plugin calls that run on open

## Repro Steps
1) Launch app
2) Navigate to Block Apps feature tab
3) Observe crash

## Notes
- Abort option: reply “Abort debugging” to stop the debug server and remove instrumentation.

