#!/usr/bin/env bash
set -euo pipefail

for command_name in brew chezmoi nvim node npm python3 pi; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'Missing command: %s\n' "$command_name" >&2
    exit 1
  }
done
source_path=$(chezmoi source-path)
[[ -d "$source_path/.git" ]] || {
  printf 'Chezmoi source checkout does not exist: %s\n' "$source_path" >&2
  exit 1
}

# Verify rendered content without loosening restrictive local permissions.
# Pi may reformat JSON when updating settings, so compare JSON semantically.
python3 - <<'PY'
import json
from pathlib import Path
import subprocess
import sys

paths = subprocess.run(
    ['chezmoi', 'managed', '--include=files', '--path-style=absolute'],
    capture_output=True, text=True, check=True,
).stdout.splitlines()
failed = False
for name in paths:
    path = Path(name)
    expected = subprocess.run(['chezmoi', 'cat', name], capture_output=True, check=True).stdout
    if not path.is_file():
        print(f'Missing managed file: {name}', file=sys.stderr)
        failed = True
        continue
    actual = path.read_bytes()
    try:
        matches = json.loads(actual) == json.loads(expected) if path.suffix == '.json' else actual == expected
    except (ValueError, UnicodeDecodeError):
        matches = actual == expected
    if not matches:
        print(f'Managed content differs: {name}', file=sys.stderr)
        failed = True
    if path.stat().st_mode & 0o022:
        print(f'Managed file is group/world-writable: {name}', file=sys.stderr)
        failed = True
if failed:
    sys.exit(1)
print(f'Checked content and safe permissions for {len(paths)} managed files.')
PY

brew bundle check --no-upgrade --file="$source_path/docs/migration/Brewfile"
# Current VS Code bundles Copilot Chat and omits it from the CLI extension list.
python3 - <<'PY'
import json
import os
from pathlib import Path
import subprocess

app = Path(os.environ.get('VSCODE_APP', '/Applications/Visual Studio Code.app'))
manifest = app / 'Contents/Resources/app/extensions/copilot/package.json'
bundled = False
if manifest.is_file():
    data = json.loads(manifest.read_text())
    bundled = f'{data.get("publisher")}.{data.get("name")}'.lower() == 'github.copilot-chat'
if not bundled:
    result = subprocess.run(['code', '--list-extensions'], capture_output=True, text=True, check=True)
    if 'github.copilot-chat' not in result.stdout.lower().splitlines():
        raise SystemExit('Copilot Chat missing: install it with code --install-extension github.copilot-chat')
print('Copilot Chat is available (bundled or user-installed).')
PY
# Pi packages now live in Pi's managed npm/git directories, not global npm.
# npm-global.Brewfile is a historical inventory, not an installation requirement.
pi --version
pi list >/dev/null
nvim --headless '+qa'

manifest="$source_path/docs/migration/secret-archive-manifest.txt"
while IFS= read -r path || [[ -n "$path" ]]; do
  case "$path" in
    .pi/agent/skills/*|.agents/skills/*)
      [[ -f "$HOME/$path" ]] || {
        printf 'Missing archived skill file: %s\n' "$HOME/$path" >&2
        exit 1
      }
      ;;
  esac
done < "$manifest"

printf 'Managed content, Homebrew manifest, Pi package list, Node/npm, Neovim startup, and custom skill-file checks passed.\n'
