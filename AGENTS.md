# Agent Capability Map

## Installed capabilities

| Capability | Primary owner | Supporting owner | Use |
| --- | --- | --- | --- |
| Taste Skill (`design-taste-frontend`) | Sora | Yuna | Design direction and implementation guidance for visually important web frontends. Apply only the framework-appropriate guidance. |
| Impeccable | Sora | Kira | Detect UI anti-patterns and improve design quality before implementation or during visual QA. |
| awesome-design-md-site | Sora | Mika | External design-reference gallery for design-system research and pattern comparison. |
| Playwright CLI | Kira | Yuna | Project-local browser inspection and verification. Kira owns independent QA; Yuna uses it only for focused developer evidence. |
| Lana workflow controls | Lana (opt-in) | None | Prompt-level task ownership locks, durable checkpoints, approval/risk gates, bounded retries, role-scoped skills, and structured handoffs. No Paperclip service, dashboard, scheduler, or telemetry is installed. |
| Launch readiness audit | Emy | Rei, Kira | Read-only project audit with exclusive ownership of `PROJECT_READINESS.md`; inventories files, records evidence, and tracks publish/monetization readiness. |

## Ownership rules

- Sora owns design decisions and may use Taste Skill, Impeccable, and the design-reference gallery as inputs.
- Yuna implements approved designs and may use the Taste guidance or Playwright CLI only where it fits the actual stack.
- Kira independently verifies browser behavior with Playwright CLI and reports evidence; Kira does not fix production behavior.
- Mika may consult the design-reference gallery for strategy or competitive-pattern research.
- Adam remains the everyday primary agent. Lana is an opt-in primary agent for testing its documented workflow controls; it does not change specialist responsibilities or the default agent.
- Lana permits one locked spotlight specialist at a time. Advisers may answer a scoped question but do not own or edit the locked task.
- These capabilities do not change the agents' existing responsibility boundaries.
