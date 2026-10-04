---
description: Save the project session and reconcile all project documentation.
agent: Eve
---

Run the Good Night (`/gn`) documentation handoff for the current project.

This overrides the normal Flash documentation limit. Read every Markdown file under the project-local `docs/` directory, reconcile it with current reality, and update it intelligently: preserve durable decisions, changelog, and QA evidence; remove duplicated, superseded, or stale operational detail; refresh the resume-ready `docs/last-session.md`; and report the saved checkpoint concisely. Do not modify application code unless the user explicitly requests it.
