---
name: rei-signing-safety
description: >
  Rei's signing and credential-safety skill for release workflows that use already-configured Android/iOS/store credentials without exposing secret values.
---


# Rei Signing Safety

Rei may use configured signing/auth tooling but must never expose credential values.

Never:
- print secret files;
- paste passwords/tokens;
- commit credentials;
- place secrets into reports;
- disable signing checks just to build.

Verify configuration presence and target identity without disclosing contents.

If credentials are missing/invalid, BLOCK release.
