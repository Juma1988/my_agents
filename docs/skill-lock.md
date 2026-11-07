# Skill Lock

## Installed capabilities

| Capability | Source / version | Scope | Owners |
| --- | --- | --- | --- |
| `design-taste-frontend` | `Leonxlnx/taste-skill` | Project-local: `.agents/skills/design-taste-frontend`; loaded by `.opencode/opencode.json` | Sora; Yuna support |
| Impeccable | `impeccable` CLI v4.1.0; engine v0.1.11 | Project-local: `.opencode/skills/impeccable` | Sora; Kira support |
| Design reference | `HagiCode-org/awesome-design-md-site` | External reference documented by `sora-design-references` | Sora; Mika support |
| Playwright CLI | `@playwright/cli` v0.1.22 | Project dev dependency | Kira; Yuna support |
| `i1988-design` | Authored locally from 26 user-supplied video summaries; installed globally at `~/.config/opencode/skills/i1988-design/` | Global + repo copy in `skills/i1988-design/` | Sora primary; Yuna and Kira follow |

## Verification

- Taste Skill installer reported Safe / 0 Socket alerts / Low Snyk risk for `design-taste-frontend`.
- `npx impeccable check` completed and reported that a newer Impeccable update is available.
- `npx playwright-cli --help` succeeded from the project-local dependency.
