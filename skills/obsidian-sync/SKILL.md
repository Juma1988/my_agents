# Obsidian Sync Skill

> Bidirectional sync between OpenCode project docs and Obsidian vault.

## Purpose

Keep your Obsidian vault in sync with OpenCode's project documentation, enabling:
- **Read**: OpenCode searches/reads your vault for context
- **Write**: OpenCode syncs progress, decisions, changelogs back to Obsidian

## Vault Location

Default vault path: `{workspace}/docs/Vault/`

Override by setting `VAULT_PATH` in `.opencode/config.json` or environment variable.

## Sync Targets

### OpenCode → Vault (Write)

| Source | Destination | Description |
|--------|-------------|-------------|
| `docs/progress.md` | `docs/Vault/Progress.md` | Current session state |
| `docs/CHANGELOG.md` | `docs/Vault/Changelog.md` | Chronological changes |
| `docs/improvement_radar.md` | `docs/Vault/Improvement Radar.md` | Future ideas |
| `docs/project-memory.md` | `docs/Vault/Project Memory.md` | Project memory |
| `docs/decisions/*.md` | `docs/Vault/Decisions/*.md` | Approved decisions |

### Vault → OpenCode (Read)

OpenCode can directly read any file from the vault using the `Read` tool:
```
Read: docs/Vault/Progress.md
Read: docs/Vault/Decisions/architecture-choice.md
```

## Sync Protocol

### When to Sync

1. **End of session**: After substantial work completes
2. **On decision**: When a decision is approved
3. **Manual trigger**: User says "sync to obsidian" or "sync vault"

### Sync Commands

#### Full Sync (docs/ → docs/Vault/)
```powershell
# From workspace root
$vault = "docs/Vault"
$docs = "docs"

# Progress
Copy-Item "$docs/progress.md" "$vault/Progress.md" -Force

# Changelog
Copy-Item "$docs/CHANGELOG.md" "$vault/Changelog.md" -Force

# Improvement Radar
Copy-Item "$docs/improvement_radar.md" "$vault/Improvement Radar.md" -Force

# Project Memory
Copy-Item "$docs/project-memory.md" "$vault/Project Memory.md" -Force

# Decisions (all files)
Copy-Item "$docs/decisions/*" "$vault/Decisions/" -Recurse -Force
```

#### Add Header (optional, for Obsidian visibility)
Prepend a sync timestamp to synced files:
```powershell
$header = "---`nsynced: $(Get-Date -Format 'yyyy-MM-dd HH:mm')`nsource: opencode`n---`n`n"
$content = Get-Content "$vault/Progress.md" -Raw
Set-Content "$vault/Progress.md" "$header$content"
```

## Reading from Vault

### Search Vault
```powershell
# Find notes containing a term
Get-ChildItem "docs/Vault" -Recurse -Filter "*.md" | Select-String "architecture"
```

### Read Specific Note
```
Read: docs/Vault/Decisions/database-choice.md
```

## Usage Examples

### "Sync my progress to Obsidian"
→ Run full sync, copy docs/ → docs/Vault/

### "What notes do I have about authentication?"
→ Search docs/Vault/ for files containing "auth"

### "Read my architecture decisions"
→ Read docs/Vault/Decisions/architecture*.md

### "Save this decision to my vault"
→ Write to docs/Vault/Decisions/{topic}.md

## Configuration

### Custom Vault Path
Add to `.opencode/config.json`:
```json
{
  "obsidian": {
    "vaultPath": "docs/Vault",
    "autoSync": true,
    "syncOnDecision": true
  }
}
```

### Per-Project Override
Set in project's `.opencode/config.json`:
```json
{
  "obsidian": {
    "vaultPath": "../MyVault/Projects/CurrentProject"
  }
}
```

## Notes

- Vault is the **display layer**; OpenCode docs/ remain source of truth
- Never delete vault files from OpenCode — user manages vault manually
- Sync is additive — OpenCode writes, user organizes in Obsidian
- Graph view in Obsidian will automatically link synced notes
