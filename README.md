# 🤖 My Agents — Your AI Dev Team

> A complete multi-agent system for [OpenCode](https://github.com/opencode-ai/opencode) that gives you a full software development team — from strategy to shipping.

**One interface. Five specialists. Zero chaos.**

---

## 🎯 What Is This?

My Agents is a production-grade agent configuration for OpenCode. It replaces the single-agent "do everything" approach with a **specialist orchestra** — six carefully scoped agents that collaborate through a single orchestrator, each owning exactly one responsibility.

| Agent | Role | What It Does |
|-------|------|-------------|
| 🎯 **Adam** | Orchestrator | Your single point of contact. Understands requests, breaks them into work, routes to the right specialist, maintains project state, and carries work to verified completion. |
| 🧠 **Mika** | Strategy | Product thinking, research, competitor analysis, ideation. Challenges assumptions, surfaces opportunities, recommends what to build (and what not to). |
| 🎨 **Sora** | UI/UX Design | Flows, layouts, states, accessibility, localization, responsive behavior, design systems, UX writing, visual review. Turns intent into actionable design contracts. |
| ⚙️ **Yuna** | Implementation | Production code across UI, state, logic, APIs, persistence, auth, navigation. Implements in small verified slices while preventing structural decay. |
| 🧪 **Kira** | QA & Testing | Independent verification, regression, edge cases, accessibility/security checks, runtime evidence. Never trusts — always verifies. |
| 🚀 **Rei** | Release | Release readiness, dead-code gates, build/signing/versioning, rollback, publication. Ships only with explicit authorization and verified evidence. |

---

## 🏗️ How It Works

```
You → Adam → Spotlight Specialist (with optional Advisers) → Verified Result → You
```

**Core principle:** *One spotlight. Optional advisers. Adam owns the orchestra.*

At any moment, exactly **one** specialist owns the work. Others may advise — but only when their input materially helps. This prevents the chaos of multiple agents fighting over the same codebase.

### Dynamic Routing

Adam doesn't follow a fixed pipeline. He routes based on what the task actually needs:

```
New UI feature     → Mika (optional) → Sora → Yuna → Kira
Existing UI bug    → Yuna → Kira (Sora as adviser if needed)
Product idea       → Mika only (or Mika → Sora for UX direction)
Architecture work  → Yuna (Mika/Sora as advisers if decisions matter)
Release            → Kira (verified) → Rei
```

Specialists that add no value? **Skipped.**

---

## ✨ Key Features

### 🎯 Evidence-Based Gates
No agent can self-certify completion. Every stage has a **completion gate** — concrete evidence requirements that Adam evaluates before moving forward.

### 🔄 Improvement Radar
Every specialist continuously scans for issues, opportunities, and structural decay — then reports findings to Adam for prioritization. The radar catches what point-in-time reviews miss.

### 🛡️ Doom-Loop Prevention
Built-in circuit breakers prevent infinite Yuna/Kira alternation or repeated failed strategies. After two similar failures, the system stops and asks for a real decision.

### 📋 Visible TODO State
The user always sees what's planned, active, complete, and blocked. No hidden work. No surprise scope changes.

### 🔒 User Decision Authority
Meaningful product and architecture choices always route back to you. The agents recommend — you decide.

### 🧰 Skill System
Extensible skill architecture for adding specialized capabilities. Skills add expertise; agents define responsibility.

---

## 📦 Installation

### Prerequisites

- [OpenCode](https://github.com/opencode-ai/opencode) installed and configured
- Access to your preferred LLM provider

### Setup

1. **Clone this repository:**

```bash
git clone https://github.com/Juma1988/my_agents.git
```

2. **Copy agent files to your OpenCode agents directory:**

```bash
# From inside your project directory
mkdir -p .opencode/agents
cp path/to/my_agents/*.md .opencode/agents/
```

3. **Or use them as project-level agents:**

```bash
# Place directly in your project root
cp path/to/my_agents/*.md .opencode/agents/
```

4. **Open your project in OpenCode** — the agents are now available.

### File Structure

```
your-project/
├── .opencode/
│   └── agents/
│       ├── adam.md      # Orchestrator
│       ├── mika.md      # Strategy
│       ├── sora.md      # UI/UX Design
│       ├── yuna.md      # Implementation
│       ├── kira.md      # QA & Testing
│       └── rei.md       # Release
└── ...
```

---

## 🔧 Customization

### Personal Information

Edit `adam.md` to set your name, email, and company ID:

```yaml
# In adam.md frontmatter or body
- **Name:** Your Name
- **Email:** your@email.com
- **Company ID:** com.yourcompany.<project_name>
```

### Permission Boundaries

Each agent has carefully scoped permissions. Agents can read broadly but have restricted write access:

| Agent | Can Write | Cannot Write |
|-------|-----------|-------------|
| Adam | `*` (with safety guards) | `.env`, secrets, credentials |
| Mika | `docs/strategy/**`, `docs/decisions/**` | Production code, project records |
| Sora | `docs/design/**`, `docs/decisions/**` | Production code, project records |
| Yuna | `*` (with safety guards) | `.env`, secrets (within scope) |
| Kira | `test/**`, `tests/**`, `integration_test/**`, `docs/qa/**` | Production code |
| Rei | `*` (within release scope) | `.env`, secrets |

### Adding Skills

Skills extend agent capabilities without changing agent responsibility. Place skills in:

```
.opencode/skills/<skill-name>/SKILL.md
```

---

## 🧠 Agent Deep Dive

### Adam — The Orchestrator

Adam is the only agent you talk to. He:

- **Understands** what you actually want (not just what you said)
- **Breaks** work into achievable outcomes
- **Routes** to the right specialist at the right time
- **Maintains** visible TODO state and project records
- **Prevents** agent loops and ownership confusion
- **Surfaces** suggestions without hijacking scope

### Mika — Strategy & Ideation

Mika challenges assumptions before implementation begins:

- Identifies the **real problem** (not just the requested solution)
- Researches competitors and external evidence
- Generates meaningful alternatives with trade-off analysis
- Runs the Improvement Radar across inspected areas
- Recommends what to build — and what not to

### Sora — UI/UX Design

Sora turns product intent into actionable design contracts:

- Defines flows, states, hierarchy, and interaction patterns
- Enforces accessibility and localization/RTL resilience
- Identifies reusable components and design token opportunities
- Reviews screenshots against approved design contracts
- Improves UX copy where wording affects clarity

### Yuna — Implementation

Yuna produces working code in small verified slices:

- Implements approved behavior contracts
- Keeps business logic, presentation, and persistence separated
- Performs safe cleanup in touched code
- Adds focused tests for meaningful new logic
- Reports structural decay through the Improvement Radar

### Kira — QA & Testing

Kira independently verifies everything:

- Builds risk-based test plans (not equal effort on every path)
- Reproduces failures with exact evidence
- Distinguishes product defects from environment failures
- Never trusts confidence as proof
- Verifies accessibility, security, and responsive behavior

### Rei — Release & Publishing

Rei ships only when everything is verified:

- Validates Kira's evidence matches the exact revision
- Performs final dead-code sweep
- Verifies signing, versioning, and build readiness
- Confirms rollback plan before publication
- Publishes only with explicit user authorization

---

## 📋 Signal Icons

Each agent uses consistent scan markers:

| Icon | Meaning |
|------|---------|
| 🎯 | Spotlight (active specialist) |
| 👀 | Adviser |
| 📋 | TODO |
| ✅ | Done / Verified |
| ⚙️ | Working |
| 🧪 | Verify |
| 🔒 | User Decision Required |
| ⚠️ | Risk |
| 💡 | Suggestion |
| ✨ | Improvement |
| ♻️ | Health Slice |
| 🧰 | Skill |
| 🧱 | Blocked |
| 🚀 | Release |

---

## 🔄 Workflow Examples

### Feature Development

```
You: "Add a dark mode toggle to settings"

Adam → Mika (quick strategy check)
  → Sora (design the toggle, states, and persistence UX)
    → Yuna (implement in verified slices)
      → Kira (independent verification)
        → Done ✅
```

### Bug Fix

```
You: "The profile save button doesn't work offline"

Adam → Yuna (traces the save path, fixes the bug)
  → Kira (verifies fix, checks edge cases)
    → Done ✅
```

### Release

```
You: "Ship it"

Adam → Kira (full verification of exact revision)
  → Rei (preflight, build, sign, publish)
    → Done ✅
```

---

## 🛡️ Safety Features

- **Secrets Protection**: All agents deny read/write access to `.env`, `.key`, `.pem`, and credential files
- **No Force-Push**: Destructive Git operations require explicit approval
- **Scope Protection**: "While we're here" work is actively prevented
- **Doom-Loop Prevention**: Circuit breakers stop infinite retry patterns
- **Authorization Gates**: Publishing requires explicit user authorization
- **Evidence Requirements**: No self-certification — every stage needs concrete proof

---

## 📄 License

Apache License 2.0 — see [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

This is a personal agent configuration. Feel free to fork and customize for your own workflow.

If you build something cool with these agents, I'd love to hear about it.

---

## 🙏 Credits

Built for [OpenCode](https://github.com/opencode-ai/opencode) — the AI coding assistant that lets you define how it thinks.

---

<div align="center">

**Built with ☕ by [Ibrahim Juma](https://github.com/Juma1988)**

*From idea to production, with an AI team that actually works.*

</div>
