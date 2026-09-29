# My Agents

> **A disciplined AI development team for [OpenCode](https://opencode.ai).**

Turn one OpenCode session into a coordinated team that can take work from product thinking to verified release—without letting multiple agents compete for the same task.

**One interface. Five specialists. One accountable orchestrator.**

---

## Why My Agents?

Most multi-agent setups add more voices. My Agents adds **clear ownership**.

Eve is your only normal point of contact. She understands the outcome, keeps the plan and progress visible, assigns exactly one specialist to own the active work, and requires evidence before calling it complete.

```text
You → Eve → Spotlight specialist (+ optional advisers) → Verified result → You
```

> **One spotlight. Optional advisers. Eve owns the orchestra.**

That means less agent churn, fewer scope surprises, and a clear answer to: *what changed, what was verified, and what happens next?*

## Meet the team

| Agent | Owns | Brings |
| :-- | :-- | :-- |
| 🎯 **Eve** | Orchestration | Planning, routing, durable project context, progress visibility, evidence gates, and scope protection. |
| 🧠 **Mika** | Strategy | Product thinking, research, trade-offs, competitor analysis, and ideation. |
| 🎨 **Sora** | UI/UX | User flows, design systems, accessibility, localization, UX writing, and visual review. |
| ⚙️ **Yuna** | Implementation | Production code, state, APIs, persistence, architecture, and focused developer tests. |
| 🧪 **Kira** | Independent QA | Regression, runtime evidence, edge cases, accessibility, and security verification. |
| 🚀 **Rei** | Release readiness | Build/version checks, signing safety, rollback readiness, dead-code gates, and authorized publishing. |

## How it works

Eve routes dynamically instead of forcing every request through the same pipeline.

| Your request | Typical route |
| :-- | :-- |
| New product or feature idea | Mika → Sora → Yuna → Kira |
| UI change | Sora → Yuna → Kira |
| Existing bug | Yuna → Kira |
| Architecture or data work | Yuna, with advisers only when needed |
| “Ship it” | Kira (exact revision) → Rei |

Specialists that do not materially improve the outcome are skipped. Advisers can inform the work, but they do not take ownership away from the spotlight specialist.

## What you get

- **Visible execution** — clear TODOs, progress, blockers, and scope deltas instead of hidden work.
- **Evidence, not confidence** — completion claims are checked against concrete evidence; critical paths require runtime proof.
- **Scope discipline** — useful discoveries are classified as required work, a small safe cleanup, radar items, or ignored noise.
- **Decision memory** — meaningful choices are recorded once and applied consistently later.
- **Loop protection** — repeated failures trigger a root-cause checkpoint instead of endless retries.
- **Release control** — publication requires explicit authorization, matching QA evidence, and rollback awareness.
- **Skill-aware workflows** — agents can discover and apply project-local skills without blurring responsibility boundaries.

## Install

### Prerequisites

- [OpenCode](https://opencode.ai) installed
- An OpenCode model provider configured

### Add the team to a project

Clone this repository, then copy the agents and bundled skills into the project where you use OpenCode.

<details>
<summary><strong>macOS / Linux</strong></summary>

```bash
git clone https://github.com/Juma1988/my_agents.git
mkdir -p /path/to/your-project/.opencode/{agents,skills}
cp my_agents/*.md /path/to/your-project/.opencode/agents/
cp -R my_agents/skills/. /path/to/your-project/.opencode/skills/
```

</details>

<details>
<summary><strong>Windows PowerShell</strong></summary>

```powershell
git clone https://github.com/Juma1988/my_agents.git
New-Item -ItemType Directory -Force -Path "C:\path\to\your-project\.opencode\agents", "C:\path\to\your-project\.opencode\skills"
Copy-Item .\my_agents\*.md "C:\path\to\your-project\.opencode\agents\"
Copy-Item .\my_agents\skills\* "C:\path\to\your-project\.opencode\skills\" -Recurse
```

</details>

Your project should look like this:

```text
your-project/
└── .opencode/
    ├── agents/
    │   ├── eve.md
    │   ├── mika.md
    │   ├── sora.md
    │   ├── yuna.md
    │   ├── kira.md
    │   └── rei.md
    └── skills/
        └── <bundled skills>
```

Restart OpenCode after adding or changing agents or skills so it reloads the configuration. Then select **Eve** as your primary agent and describe what you want to achieve.

## Start with a real request

Use outcome-focused prompts. Eve will turn them into a plan, keep you informed, and bring in only the expertise that helps.

```text
“Add a dark-mode preference that persists across app restarts.”
“The profile save action fails while offline. Find and fix it.”
“Review this onboarding flow before we build it.”
“Ship the verified release to the production channel.”
```

## Customize for your environment

### Personal details

Update the **User Information** section in `eve.md` with your name, email, and application-ID convention.

### Permissions

The agents include deliberate guardrails: secret files are denied, destructive Git operations require confirmation, and each specialist is constrained to its responsibility. Review the frontmatter in each agent file and adapt permissions to your environment before using the team in a sensitive project.

### Skills

This repository bundles focused skills for Flutter implementation, UI/UX, QA, release readiness, and device-aware Flutter runs. OpenCode discovers project-local skills from:

```text
.opencode/skills/<skill-name>/SKILL.md
```

Skills extend expertise. They do not replace ownership: Eve still decides who should do the work and when.

## Operating principles

| Principle | In practice |
| :-- | :-- |
| **One owner at a time** | Exactly one spotlight specialist owns active specialist work. |
| **Evidence before done** | Required checks, known scope, honest risks, and runtime proof for critical paths. |
| **The user decides meaningful trade-offs** | Agents recommend; you retain product and architecture authority. |
| **Change narrowly** | Safe tiny cleanups are allowed; unrelated work stays on the improvement radar. |
| **Release is intentional** | No publishing without your explicit authorization and matching QA provenance. |

## Included capabilities

The bundled skill set covers:

- Flutter architecture, performance, dependencies, data/API boundaries, security hardening, and developer testing
- Design systems, accessibility, localization/RTL, motion, UX writing, and visual review
- Widget, integration, regression, runtime-debugging, accessibility, and security QA
- Release readiness, version/build validation, signing safety, rollback recovery, store publishing, and dead-code gates

## Safety by design

- Secrets and credentials are protected by agent permissions.
- Force-pushes and destructive Git operations are never treated as routine.
- Specialist handoffs have explicit completion evidence.
- Repeated unsuccessful approaches stop for a root-cause decision instead of looping.
- Release work is separated from normal feature completion.

## Contributing

This is a personal agent configuration, built to be forked and tailored. Issues and improvements are welcome—especially changes that make the team clearer, safer, or more useful in real projects.

## License

Licensed under the [Apache License 2.0](LICENSE).

---

<div align="center">

Built by <a href="https://github.com/Juma1988">Ibrahim Juma</a> for developers who want AI assistance with ownership, evidence, and momentum.

</div>
