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
- **`.zshrc.tmpl`** - Can have work-specific aliases/paths

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
