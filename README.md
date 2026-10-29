# Dotfiles Management with Chezmoi

## Overview

This setup allows syncing configs across personal and work machines while maintaining machine-specific settings.

## Machine Setup

### On This Machine (Personal Mac)
Already configured in `~/.config/chezmoi/chezmoi.toml`:
```toml
[data]
    hostname = "personal-mac"
    is_work = false

[data.git]
    name = "Ricardo"
    email = "ricardo@yonkolevel.com"
```

### On Work Laptop
Create `~/.config/chezmoi/chezmoi.toml` with:
```toml
[data]
    hostname = "work-mac"
    is_work = true

[data.git]
    name = "Ricardo"
    email = "ricardo@company.com"  # Your work email

[data.work]
    email = "ricardo@company.com"
    proxy = "http://proxy.company.com:8080"  # If needed
```

## How It Works

### Templated Files (`.tmpl`)
Files ending in `.tmpl` use Go templates to insert machine-specific values:

- **`.gitconfig.tmpl`** - Uses different email based on `is_work` flag
- **`.zshrc.tmpl`** - Keeps shared shell config and branches on `is_work`

### Local-only Secrets

Keep secrets and machine-only exports out of the repo in:

```bash
~/.zshrc.local
```

This file is sourced by `.zshrc` if it exists.

### Laptop Migration

Current migration inventory, explicit non-migration rules, encrypted archive manifest/helper, setup check, and replacement-Mac resetup plan live under `docs/migration/` and `docs/plans/`.

On the old Mac:

1. Review `docs/migration/secret-archive-manifest.txt` and rotate exposed tokens.
2. Run `docs/migration/check-reproducible-setup.sh`; this includes custom Pi/agent skills.
3. Run `docs/migration/create-encrypted-archive.sh`; enter GPG passphrase stored in password manager.
4. Upload archive and checksum only to approved company storage.
5. Push Chezmoi source and validate the replacement Mac with `docs/plans/2026-06-22-new-machine-resetup-plan.md`.

Keep archive allow-listed. Never copy Keychain, Apple signing, VPN/MDM material, Google Cloud SDK state, caches, or build outputs. The reproducibility check validates current managed content and package declarations; it does not certify signing, credentials, mobile builds, or every extension's runtime behaviour.

### Template Variables Available

- `{{ .chezmoi.hostname }}` - Machine hostname
- `{{ .chezmoi.homeDir }}` - Home directory path
- `{{ .is_work }}` - Boolean: true on work machines
- `{{ .git.name }}` - Git user name
- `{{ .git.email }}` - Git email
- `{{ .work.email }}` - Work email (if is_work)
- `{{ .work.proxy }}` - Work proxy (if is_work)

### Conditional Sections

```go
{{- if .is_work }}
# Work-specific config here
{{- else }}
# Personal config here
{{- end }}
```

## Managing Nvim Config

Neovim configs can be synced too:

### Option 1: Full Sync
```bash
chezmoi add ~/.config/nvim
```

### Option 2: Separate Configs
```bash
# Personal plugins/settings
chezmoi add ~/.config/nvim/lua/personal/

# Keep work-specific in separate file
# Add to .chezmoiignore: .config/nvim/lua/work/
```

## Obsidian plugin sync

The helper is managed as `~/.local/bin/obsidian-sync-plugins`:

```sh
chezmoi apply ~/.local/bin/obsidian-sync-plugins
obsidian-sync-plugins          # preview
obsidian-sync-plugins --apply  # quit Obsidian first
```

It synchronises the union of enabled plugins across the parent Documents vault and its Trainline, Ricardo, Yonko Level Docs, and ai child vaults. It chooses the newest complete installed version, rejects conflicting builds of the same version, and backs up overwritten files under the vault's `.vault-tools/backups/`. It preserves per-vault settings and layouts. Sync is on demand, not automatic; disable a plugin in every vault before syncing to disable it everywhere.

The default root is `~/Library/Mobile Documents/iCloud~md~obsidian/Documents`. Override with `OBSIDIAN_VAULT_ROOT` or `--root PATH`, and override the child vault list with repeated `--vault NAME` flags. Plugin binaries, settings, and backups stay out of this repository.

Tests: `python3 -m unittest discover -s docs/tests -v`.

## Existing checkout location

If the checkout is in `~/Developer/dotfiles` rather than Chezmoi's default directory, set this **top-level** value before any `[data]` section in `~/.config/chezmoi/chezmoi.toml`:

```toml
sourceDir = "/absolute/path/to/Developer/dotfiles"
```

`chezmoi source-path` must point to an existing checkout. Avoid a blanket apply when adopting an existing machine: inspect local changes first. `chezmoi status` also reports permission differences; the reproducibility check accepts stricter local permissions while checking content and rejecting group/world-writable files.

## Pi configuration

Install Pi using its official standalone installer, then reconcile packages declared in `settings.json` with `pi update --extensions`. Extensions are Pi-managed packages, not global npm installs. `docs/migration/npm-global.Brewfile` is a historical snapshot, not a current dependency check. The local `~/Developer/pi-staff-workflow` package must be checked out before starting Pi on a new machine.

The active MCP configuration is `~/.pi/agent/mcp-adapter.json`, managed by the adapter; the old `mcp.json` is no longer deployed. OAuth tokens, authentication stores, sessions, caches, and local state must never be added to dotfiles.

Optional machine-only data belongs in `~/.config/chezmoi/chezmoi.toml`, not Git:

```toml
[data.pi_memory]
repo_url = "<private memory repository URL>"
local_path = "/absolute/path/to/local/memory"

[data.pi_local]
firebase_project_dir = "/absolute/path/to/firebase/project"
```

Without these sections, the generated settings omit the private memory configuration and Firebase server. MCP sign-in remains a separate step. Check `chezmoi cat ~/.pi/agent/settings.json` locally before applying; its rendered output can include private machine values, so do not publish it.

## Common Patterns

### Company-Agnostic Tools
These should sync across all machines:
- Shell aliases (common ones)
- Vim/Nvim basic settings
- Git aliases and core settings
- Tool configs (fzf, ripgrep, etc.)

### Machine-Specific
Keep separate or use templates:
- Git email/username
- SSH configs
- Company VPN scripts
- Work-specific environment variables

## Example: Templated .zshrc

Convert `.zshrc` to `.zshrc.tmpl`:
```bash
cd ~/.local/share/chezmoi
mv dot_zshrc dot_zshrc.tmpl
```

Add machine-specific sections:
```zsh
# Common aliases (sync everywhere)
alias zshconfig="code ~/.zshrc"
alias ll="ls -la"

{{- if .is_work }}
# Work-specific aliases
alias vpn="connect-to-work-vpn"
export WORK_ENV="production"
{{- else }}
# Personal aliases
alias mc-dev="ssh root@134.209.183.3"
{{- end }}
```

## Commands

```bash
# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Add new file to chezmoi
chezmoi add ~/.config/newfile

# Edit a managed file
chezmoi edit ~/.zshrc

# Check chezmoi data variables
chezmoi data
```

## Initial Setup on New Machine

```bash
# 1. Install chezmoi
brew install chezmoi

# 2. Clone your dotfiles
chezmoi init git@github.com:txbrown/dotfiles.git

# 3. Create machine-specific config
# Edit ~/.config/chezmoi/chezmoi.toml

# 4. Preview changes
chezmoi diff

# 5. Apply dotfiles
chezmoi apply
```
