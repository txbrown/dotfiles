# Laptop Migration Plan

## Intent

Rebuild development setup on replacement company Mac with minimal manual work, while keeping secrets out of Git and Google Drive plaintext.

## Canonical sources

- **Chezmoi:** shell, Git, terminal, Pi non-secret config, Homebrew manifest, Neovim config.
- **Encrypted GPG archive:** local-only files and optional authentication state.
- **Git remotes:** committed source repositories.
- **Reinstallation:** package-manager caches, Neovim plugins, Mason packages, build outputs, and derived data.

Neovim now lives in Chezmoi. Its NvChad-based configuration and `lazy-lock.json` were imported, and the original local repository was committed as `92c2112` for history.

## Current inventory

- Homebrew: Apple Silicon Homebrew 7.0.6.
- Direct formula installs include: `act`, `aerc`, `autojump`, `awscli`, `bundletool`, `chezmoi`, `difftastic`, `dotnet@8`, `fastlane`, `gh`, `git-lfs`, `lazygit`, `mise`, `mole`, `neovim`, `nvm`, `ollama`, `podman`, `pyenv`, `rbenv`, `ripgrep`, `ruby@3.3`, `watchman`, `xcbeautify`.
- Casks: Claude Code, Codex, Copilot CLI, TrackWeight, Visual Studio Code. Lazyworktree is installed but unused and should be removed before the final inventory.
- Taps: `krishkrosh/apps`, `modem-dev/tap`. The unused `chmouel/lazyworktree` tap should be removed.
- `brew bundle dump` currently fails because the unused Lazyworktree cask comes from a third-party tap marked untrusted by Homebrew.
- Xcodes.app 2.4.2; Xcode 26.3 installed. `/Applications/Xcode.app` is a broken symlink to missing Xcode 15.4 and must be corrected.
- Neovim 0.11.4; NvChad configuration and `lazy-lock.json` imported into Chezmoi; Mason packages installed separately.
- Pi 1.0.4 installed globally under Node 22.19.0. Pi configuration is partly managed by Chezmoi; auth files are sensitive.
- Google Cloud SDK is installed under `~/Downloads/google-cloud-sdk`, but is explicitly excluded from migration. Its shell hooks were removed from `.zshrc`; current SDK files remain untouched until cleanup.

## Ordered slices

### 1. Freeze and inventory old laptop

- Commit and push Chezmoi source changes.
- Neovim changes, including `lazy-lock.json`, are committed locally as `92c2112`; push its separate repository only if that repository remains an intended remote source.
- Remove unused Lazyworktree cask and tap, then generate:
  - `Brewfile` containing intended formulae, casks, taps, and Mac App Store apps if relevant.
  - Full Homebrew version snapshot, not only direct installs.
  - Node/npm global package snapshot.
  - `mise`, nvm, pyenv, rbenv, Swiftly, and Tuist version snapshots.
  - Xcodes/Xcode version and selected developer-directory snapshot.
  - Neovim Mason package snapshot.
- Mark each item as portable, reinstallable, machine-specific, or secret.
- Inventory non-Homebrew applications and VS Code extensions.
- Find project-local `.env` files, signing files, local certificates, Git worktrees, and uncommitted changes across the TOCS repository and other active repositories; classify each before handover.
- For each project secret, record whether it is restored from the encrypted bundle, regenerated from company systems, or intentionally excluded.
- Record Android SDK/AVD, iOS simulator, and Xcode requirements only; do not migrate managed signing or certificate material.

### 2. Make Chezmoi reproducible

- Keep imported `~/.config/nvim` in Chezmoi, including source files and `lazy-lock.json`.
- Exclude `.git`, `.DS_Store`, plugin directories, logs, swap files, shada, cache, and state.
- Make the Xcode debugger path portable; current config references `~/tools/codelldb-darwin-arm64`.
- Add Homebrew manifest and version manifests.
- Add a small bootstrap/check script only where it removes repeated manual work.
- Add an explicit non-migration list for Google Cloud SDK and other intentionally excluded tools.
- Replace hardcoded Homebrew and Java paths with portable resolution where practical.
- Keep Pi configuration and extensions in Chezmoi; keep Pi auth and MCP auth outside normal source files.
- Update Chezmoi README with this migration procedure and current work-machine setup.

### 3. Build encrypted migration bundle

The encrypted bundle is the primary path for restoring secrets, not a reminder to manually re-enter them. Use a streamed tar archive encrypted with symmetric GPG/AES-256 and an explicit allow-list.

Global files to consider:

- `~/.zshrc.local`
- `~/.npmrc`
- `~/.config/chezmoi/chezmoi.toml`
- `~/.pi/agent/auth.json`
- `~/.pi/agent/mcp-auth.json`
- `~/.config/gh/hosts.yml`
- `~/.aws/credentials`
- Approved SSH keys and optional `~/.ssh/config`/`known_hosts`

Also inventory the TOCS repository and other active repositories for build-critical local files, such as `.env*`, `secrets.properties`, signing files, Firebase configuration, New Relic configuration, npm/project auth files, certificates, and keystores. For the current TOCS checkout, explicitly review and include as needed:

- `~/Developer/trainline/tocs-app-2/.npmrc`
- `~/Developer/trainline/tocs-app-2/.env`
- `~/Developer/trainline/tocs-app-2/android/secrets.properties`
- `~/Developer/trainline/tocs-app-2/android/app/google-services.json`
- `~/Developer/trainline/tocs-app-2/ios/GoogleService-Info.plist`

The Firebase files above are ignored by Git in this checkout and therefore need explicit backup. Tracked Firebase/New Relic files and `android/app/debug.keystore` should be verified on the remote but do not need duplication in the encrypted bundle. Include reviewed paths from all relevant repositories in the manifest, preserving their paths under `$HOME`. Restore the archive after checkout so these files land in their expected repository locations.

Include company credentials, project secrets, and SSH keys only if company policy permits their encrypted transfer. Keep the manifest explicit; never archive all of `$HOME` or whole repositories.
Explicitly exclude Google Cloud SDK/configuration because it was marked as non-migrating, along with Chezmoi state, caches, build outputs, node_modules, Pods, DerivedData, Neovim state, and generated package data.

Store the GPG passphrase in the password manager. Upload archive only to approved company storage. Rotate credentials that were exposed or expired, update local files, then create the final archive. Restore files with original permissions and validate each service on the replacement Mac before revoking old-machine access.

Do not touch macOS login Keychain, Apple Developer certificates, provisioning profiles, VPN certificates, MDM credentials, or other company-managed material. The replacement laptop's managed setup owns those.

### 4. Bootstrap replacement Mac

1. Complete company enrollment, MDM, VPN, FileVault, and required Apple tooling.
2. Install Homebrew, GPG, Git, and Chezmoi.
3. Clone/init Chezmoi and create machine-specific `chezmoi.toml` data.
4. Run `chezmoi diff`, then `chezmoi apply`.
5. Run `brew bundle` from the managed manifest after reviewing taps.
6. Install Xcodes.app and required Xcode versions; set `xcode-select` to the intended version and remove broken symlinks.
7. Install Node/npm and Pi at recorded versions; restore Pi non-secret config.
8. Start Neovim once, sync Lazy plugins, and allow Mason to install configured tools.
9. Decrypt and restore approved local-only files.
10. Re-authenticate GitHub, Artifactory, AWS, Jira, MCP, Copilot, and other services where required.

### 5. Close remaining migration gaps

- Leave macOS login Keychain, Apple Developer certificates, provisioning profiles, VPN certificates, MDM credentials, and other managed material entirely to the replacement laptop's company setup.
- Inventory browser profiles, password-manager access, VS Code extensions/settings, app licenses, and non-Homebrew application preferences that are needed for productive work.
- Check every active repository for unpushed commits, local branches, stashes, Git worktrees, ignored build-critical files, and local databases/Podman volumes.
- Decide whether emulator/simulator state is disposable; record required Android SDK packages, AVDs, iOS runtimes, and Xcode versions.
- Create an archive manifest and SHA-256 checksum, test decryption/extraction on the replacement Mac, and keep a second approved backup of the encrypted archive and passphrase.

### 6. Validate before retiring old laptop

- `chezmoi verify`
- New shell loads without errors.
- Git identity and credential helper are correct.
- Homebrew manifest completes successfully.
- `nvim` starts; Lazy lock is respected; LSP, formatter, debugger, and Treesitter work.
- Pi starts with expected extensions/configuration.
- Xcode, `xcodebuild`, Tuist, Fastlane, Android SDK, and project builds work.
- Encrypted archive decrypts on replacement Mac.
- All repositories have pushed commits and no required uncommitted work remains.

Only then wipe/return old laptop.

## Acceptance criteria

- Replacement Mac can be rebuilt from Chezmoi, Homebrew manifest, version manifests, and encrypted archive.
- Neovim and Pi configuration are restored without copying caches or generated state.
- No secret file is committed to Git or uploaded plaintext.
- Xcode selection is explicit and no broken `/Applications/Xcode.app` link remains.
- Setup instructions are sufficient to repeat migration later.

## Non-goals

- Copying all of `~/Library`.
- Preserving package caches or build artefacts.
- Blindly copying company authentication, signing, or VPN material.
- Reproducing every historical runtime version unless a project still requires it.

## Execution record

- Removed unused Lazyworktree cask and `chmouel/lazyworktree` tap.
- Generated `docs/migration/Brewfile`, `npm-global.Brewfile`, Homebrew/runtime/editor/mobile/VS Code snapshots, and repository status inventory.
- Imported Neovim configuration and lockfile into Chezmoi; made codelldb lookup portable through PATH/Mason.
- Added explicit encrypted archive manifest and archive helper; archive requires passphrase entry and approved company storage.
- Added explicit non-migration list and replacement-Mac resetup plan at `docs/plans/2026-06-22-new-machine-resetup-plan.md`.
- Current checks pass: targeted `chezmoi verify`, `brew bundle check --no-upgrade`, Neovim headless startup, archive manifest path validation, and `git diff --check`.
- Still required before final handover: rotate exposed Artifactory/npm tokens, create/upload final archive after passphrase entry, repair broken `/Applications/Xcode.app` symlink with sudo, commit/push Chezmoi source, and validate replacement Mac.
