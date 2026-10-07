# Replacement Mac Resetup Plan

## Intent

Rebuild replacement company Mac from committed Chezmoi configuration, non-secret manifests, and source repositories. Secrets and project-local credentials are regenerated or re-entered through approved company systems. Do not retire old Mac until validation passes.

## Inputs

- Chezmoi repository: `https://github.com/txbrown/dotfiles.git`
- Managed Homebrew manifest: `docs/migration/Brewfile`
- Global npm manifest: `docs/migration/npm-global.Brewfile`
- Version snapshots: `docs/migration/*-versions.txt`
- Setup check: `docs/migration/check-reproducible-setup.sh`
- Non-migration rules: `docs/migration/non-migrating.md`

## Ordered execution

### 1. Complete managed laptop setup

- Complete company enrollment, MDM, FileVault, VPN, and required Apple tooling.
- Confirm managed Keychain, certificates, provisioning profiles, VPN certificates, and signing material are provisioned by company systems.
- Install Xcodes.app if required.

### 2. Install bootstrap tools

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git chezmoi
```

Configure GitHub access using company-approved authentication. Do not copy managed Keychain material manually.

### 3. Restore Chezmoi configuration

```bash
chezmoi init https://github.com/txbrown/dotfiles.git
mkdir -p ~/.config/chezmoi
$EDITOR ~/.config/chezmoi/chezmoi.toml
chezmoi diff
chezmoi apply
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

```bash
nvm install 22.19.0
nvm alias default 22.19.0
nvm use 22.19.0
brew bundle --file npm-global.Brewfile --no-upgrade
```

Then:

- Install/select Tuist `4.29.0` with mise.
- Install Java 17 (Azul Zulu 17 or approved equivalent) and confirm `/usr/libexec/java_home -v 17`.
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

### 6. Clone active repositories

Clone repositories from their remotes, then restore or regenerate project-local files through approved company/project systems. Before wiping old Mac, review its local-only `docs/migration/repository-status.txt` to recover branch names and identify unpushed work; this file is intentionally not committed to public Chezmoi repository. Resolve or intentionally discard old-machine working changes before retirement.

For TOCS, obtain approved current values for:

- `.npmrc`
- `.env`
- `android/secrets.properties`
- `android/app/google-services.json`
- `ios/GoogleService-Info.plist`

Do not copy `node_modules`, Pods, build outputs, DerivedData, generated package data, or `android/app/debug.keystore` unless repository policy later requires regeneration.

### 7. Re-authenticate services

Re-authenticate GitHub, Artifactory/npm, AWS, Jira, MCP, Copilot, Pi, and other services. Use fresh tokens when old tokens were exposed or expired. Confirm company policy for SSH/AWS credential issuance. Keep Pi auth and MCP auth outside Chezmoi source files.

### 8. Validate before old-machine retirement

```bash
chezmoi verify
"$(chezmoi source-path)/docs/migration/check-reproducible-setup.sh"
node --version
npm --version
java -version
xcode-select -p
xcodebuild -version
```

Then validate:

- New shell loads without errors.
- Git identity and credential helper are correct.
- Pi starts with expected extensions/configuration.
- Neovim Lazy lock, LSP, formatter, debugger, and Treesitter work.
- Xcode, `xcodebuild`, Tuist, Fastlane, Android SDK, Java 17, and TOCS builds work.
- Every required project secret was obtained from approved systems and is absent from Git.
- All active repositories have pushed commits and no required uncommitted work remains.

Only after all checks pass: revoke old-machine access where required and wipe/return old Mac according to company process.

## Explicit non-goals

- Creating or transferring an encrypted migration bundle.
- Copying all of `~/Library` or all of `$HOME`.
- Copying company-managed Keychain, signing, VPN, MDM, or provisioning material.
- Copying Google Cloud SDK/configuration.
- Preserving caches, build artefacts, emulator/simulator state, or generated dependency trees.
