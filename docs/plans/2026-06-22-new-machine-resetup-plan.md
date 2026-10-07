# Replacement Mac Resetup Plan

## Intent

Rebuild replacement company Mac from committed Chezmoi configuration, non-secret manifests, source repositories, and the approved encrypted migration archive. Do not retire old Mac until validation passes.

## Inputs

- Chezmoi repository: `https://github.com/txbrown/dotfiles.git`
- Managed Homebrew manifest: `docs/migration/Brewfile`
- Version snapshots: `docs/migration/*-versions.txt`
- Secret archive manifest: `docs/migration/secret-archive-manifest.txt`
- Encrypted archive and checksum: obtain from approved company storage
- Archive passphrase: retrieve from password manager

## Ordered execution

### 1. Complete managed laptop setup

- Complete company enrollment, MDM, FileVault, VPN, and required Apple tooling.
- Confirm managed Keychain, certificates, provisioning profiles, VPN certificates, and signing material are provisioned by company systems.
- Install Xcodes.app if required.

### 2. Install bootstrap tools

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install chezmoi gnupg git
```

Configure GitHub access using company-approved authentication. Do not copy managed Keychain material manually.

### 3. Restore Chezmoi configuration

```bash
chezmoi init https://github.com/txbrown/dotfiles.git
mkdir -p ~/.config/chezmoi
$EDITOR ~/.config/chezmoi/chezmoi.toml
chezmoi diff
chezmoi apply
chezmoi verify
```

Set machine-specific values before apply:

```toml
[data]
hostname = "work-mac"
is_work = true

[data.git]
name = "Ricardo"
email = "<company email>"

[data.work]
email = "<company email>"
```

### 4. Install packages and editors

```bash
cd "$(chezmoi source-path)/docs/migration"
brew bundle --file Brewfile --no-upgrade
```

Install recorded runtime versions as needed from `runtime-versions.txt`:

- Install/select Node `22.19.0` with nvm, then restore global npm packages:

```bash
nvm install 22.19.0
nvm alias default 22.19.0
nvm use 22.19.0
brew bundle --file npm-global.Brewfile --no-upgrade
```
- Install/select Tuist `4.29.0` with mise.
- Install required Python and Ruby versions with pyenv/rbenv.
- Install Swift toolchains with swiftly only when project validation requires them.
- Install recorded VS Code extensions from `vscode-extensions.txt`.
- Start Neovim, sync Lazy plugins, and install configured Mason packages.

### 5. Select Xcode and mobile tooling

Install/select Xcode version recorded in `editor-mobile-versions.txt`. Replace any broken `/Applications/Xcode.app` symlink only after confirming intended installed version:

```bash
sudo xcode-select --switch /Applications/Xcode-<version>.app/Contents/Developer
sudo xcodebuild -license accept
xcode-select -p
xcodebuild -version
```

Install only Android SDK packages, AVDs, and iOS runtimes required by project validation. Do not copy emulator/simulator state.

### 6. Restore approved encrypted files

Verify checksum before decrypting:

```bash
shasum -a 256 -c laptop-migration-<date>.tar.gpg.sha256
```

Decrypt and extract from the archive directory so paths restore relative to `$HOME`:

```bash
mkdir -p "$HOME/.migration-restore"
gpg --decrypt laptop-migration-<date>.tar.gpg > "$HOME/.migration-restore/files.tar"
tar -C "$HOME" -xf "$HOME/.migration-restore/files.tar"
rm -rf "$HOME/.migration-restore"
chmod 600 ~/.zshrc.local ~/.npmrc ~/.pi/agent/auth.json ~/.aws/credentials 2>/dev/null || true
```

Restore project-local files after cloning repositories. Confirm each path against `secret-archive-manifest.txt`; do not restore excluded managed credentials or Google Cloud SDK state.

### 7. Clone active repositories

Clone repositories from their remotes, then restore reviewed local files into expected paths. Before wiping old Mac, review its local-only `docs/migration/repository-status.txt` to recover branch names and identify unpushed work; this file is intentionally not committed to public Chezmoi repository. Resolve or intentionally discard old-machine working changes before retirement.

For TOCS, explicitly restore only approved files:

- `.npmrc`
- `.env`
- `android/secrets.properties`
- `android/app/google-services.json`
- `ios/GoogleService-Info.plist`

Do not copy `node_modules`, Pods, build outputs, DerivedData, generated package data, or `android/app/debug.keystore` unless repository policy later requires regeneration.

### 8. Re-authenticate services

Re-authenticate GitHub, Artifactory/npm, AWS, Jira, MCP, Copilot, Pi, and other services. Prefer fresh tokens when old tokens were exposed or expired. Confirm company policy before retaining copied SSH/AWS credentials.

### 9. Validate before old-machine retirement

```bash
chezmoi verify
brew bundle check --file "$(chezmoi source-path)/docs/migration/Brewfile"
nvim --headless '+qa'
node --version
npm --version
xcode-select -p
xcodebuild -version
```

Then validate:

- New shell loads without errors.
- Git identity and credential helper are correct.
- Pi starts with expected extensions/configuration.
- Neovim Lazy lock, LSP, formatter, debugger, and Treesitter work.
- Xcode, `xcodebuild`, Tuist, Fastlane, Android SDK, and TOCS builds work.
- Encrypted archive decrypts and restores expected files.
- All active repositories have pushed commits and no required uncommitted work remains.

Only after all checks pass: revoke old-machine access where required, remove old archive copies, and wipe/return old Mac according to company process.

## Explicit non-goals

- Copying all of `~/Library` or all of `$HOME`.
- Copying company-managed Keychain, signing, VPN, MDM, or provisioning material.
- Copying Google Cloud SDK/configuration.
- Preserving caches, build artefacts, emulator/simulator state, or generated dependency trees.
