[OPEN] Debug Session: proact-ai-not-working

## Symptom
- “ProAct AI” feature is not working.

## Expected
- User can open ProAct AI and get a valid response from the AI backend (Gemini).

## Hypotheses (falsifiable)
1) API request is failing due to invalid/blocked Gemini API key (401/403) or exceeded quota (429).
2) Request payload format is wrong for the Gemini endpoint used, causing 400 errors.
3) Network/CORS/HTTPS restrictions (especially on Web) block the request.
4) UI flow is not calling the request method (state/controller bug), so no request is made.
5) Response parsing fails (unexpected JSON shape), causing runtime exception.

## Evidence to Collect
- The exact HTTP status code + response body (sanitized) from the Gemini call.
- Whether the request is attempted (timestamped “request:start” log).
- The endpoint URL used + selected model name.
- Any exceptions + stack traces from the AI screen.

## Repro Steps
1) Open ProAct AI screen
2) Enter prompt / tap send
3) Observe error / no response

## Notes
- Abort option: reply “Abort debugging” to stop the debug server and remove instrumentation.

