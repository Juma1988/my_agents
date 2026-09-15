---
name: yuna-security-hardening
description: >
  Yuna's implementation-time security skill for Flutter/mobile/API-connected projects. Use when touching auth, authorization, tokens, sensitive storage, permissions, user input, network boundaries, logging, deep links, webviews, platform channels, or security-sensitive flows.
---

# Yuna Security Hardening

Use this skill while implementing security-sensitive behavior.

This is implementation guidance, not independent security certification.
Kira performs independent verification.

## Principle

Trace real data flow. Do not treat grep hits as vulnerabilities.

Ask:
- What does the attacker control?
- Where does that input go?
- What trust boundary is crossed?
- What protects the operation?
- What sensitive data could leak?

## Secrets

Never:
- hardcode secrets;
- read/report secret values;
- commit real `.env` files;
- log tokens/passwords/private data;
- embed server credentials in the mobile client.

Public client identifiers are not automatically secrets.
Server secrets must remain server-side.

## Authentication vs Authorization

Authentication answers:
> Who is this user?

Authorization answers:
> Is this user allowed to perform this operation on this resource?

Never rely only on:
- hidden buttons;
- client-side role checks;
- request-supplied user IDs/roles;
- decoded-but-unverified tokens.

Server-side ownership/role checks must protect sensitive operations.

## Token / Session Handling

Prefer secure platform storage for sensitive session material.

Define:
- token refresh behavior;
- expiration handling;
- logout clearing;
- multi-device implications;
- session restoration;
- failure recovery.

Do not expose tokens in:
- logs;
- URLs;
- analytics events;
- crash reports.

## Sensitive Local Storage

Classify data before storing it.

Ask:
- Is it sensitive?
- Does it need encryption/secure storage?
- Should it survive logout?
- Should it survive uninstall?
- Is it cached longer than necessary?

Do not store secrets in plain preferences when secure storage is appropriate.

## Input Validation

Validate at the trust boundary.

Client validation improves UX.
Server validation protects the system.

Never assume client validation is sufficient for:
- money;
- permissions;
- ownership;
- quotas;
- destructive operations;
- identity;
- business rules.

## Network Boundaries

Use HTTPS.
Avoid disabling certificate validation.

Do not log full request/response payloads if they can contain sensitive data.

Be deliberate about:
- retries;
- auth refresh;
- idempotency;
- timeout behavior;
- error mapping.

## URLs / Deep Links

Treat incoming links as untrusted input.

Validate:
- scheme;
- host;
- path;
- parameters;
- required auth state.

Avoid executing sensitive operations directly from an unverified link.

## WebViews

Minimize use.

If required:
- restrict navigation;
- avoid unnecessary JS bridges;
- validate origins;
- do not expose privileged native methods broadly;
- avoid loading untrusted content with powerful bridges.

## Platform Channels

Treat native/platform-channel input as an external boundary.

Validate types and assumptions.
Do not trust data merely because it comes from native code.

## File / Media Handling

Validate:
- file type;
- size;
- path;
- extension vs actual content where relevant;
- storage destination.

Avoid trusting filenames or user-provided paths.

## Permissions

Request only what is needed.

Prefer contextual permission prompts.
Handle denied/permanently-denied states.
Do not block unrelated app functionality unnecessarily.

## Logging

Never log:
- access tokens;
- refresh tokens;
- passwords;
- private keys;
- payment details;
- sensitive PII.

Prefer redacted diagnostics.

## Flutter-Specific Risks

Watch for:
- debug flags accidentally shipped;
- secrets in Dart constants/assets;
- sensitive values in analytics;
- insecure local persistence;
- overly broad deep links;
- unvalidated platform-channel input;
- release builds using development endpoints.

## Security Change Contract

When changing sensitive behavior, report:

```text
SECURITY_CHANGE:
THREAT:
PROTECTION:
FAILURE_MODE:
USER_IMPACT:
TEST_EVIDENCE:
KIRA_VERIFY:
```

## Stop / Escalate to Adam

Escalate when:
- a security fix changes product behavior;
- credentials may already be exposed;
- server-side changes are required outside current scope;
- encryption/key-management choices are architectural;
- sensitive data retention policy is unclear.
