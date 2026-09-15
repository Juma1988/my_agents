---
name: kira-security-verification
description: >
  Kira's independent security-verification skill for validating auth, authorization, sensitive storage/logging, permissions, session expiry, deep links, and security-sensitive regressions.
---


# Kira Security Verification

Verify security behavior independently from Yuna's implementation intent.

Test realistic failure/abuse cases:
- expired/invalid session;
- unauthorized ownership/action;
- permission denied;
- sensitive values in logs;
- logout clearing;
- deep-link validation;
- client-side checks not treated as server authorization;
- destructive action confirmation.

Do not claim penetration testing or a full security audit unless actually performed.

Return exact evidence and unresolved attack surface.
