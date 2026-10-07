# Laptop Migration Plan

## Intent

Rebuild development setup on replacement company Mac with minimal manual work, while keeping secrets out of Git and Google Drive plaintext.

## Canonical sources

- **Chezmoi:** shell, Git, terminal, Pi non-secret config, Homebrew manifests, Neovim config, and version snapshots.
- **Git remotes:** committed source repositories.
- **Reinstallation:** package-manager caches, Neovim plugins, Mason packages, build outputs, and derived data.
- **Manual re-authentication:** secrets, project-local credentials, and service access are regenerated or re-entered on replacement Mac.

Neovim now lives in Chezmoi. Its NvChad-based configuration and `lazy-lock.json` were imported, and the original local repository was committed as `92c2112` for history.

## Current inventory

- Homebrew: Apple Silicon Homebrew 7.0.8.
- Direct formula installs include: `act`, `aerc`, `autojump`, `awscli`, `bundletool`, `chezmoi`, `difftastic`, `dotnet@8`, `fastlane`, `gh`, `git-lfs`, `lazygit`, `mise`, `mole`, `neovim`, `nvm`, `ollama`, `podman`, `pyenv`, `rbenv`, `ripgrep`, `ruby@3.3`, `watchman`, `xcbeautify`.
- Casks: Claude Code, Codex, Copilot CLI, TrackWeight, Visual Studio Code. Lazyworktree was removed.
- Taps: `krishkrosh/apps`, `modem-dev/tap`.
- Xcodes.app 2.4.2; Xcode 26.3 installed. `/Applications/Xcode.app` is still a broken symlink to missing Xcode 15.4 and must be corrected.
- Neovim 0.11.4; NvChad configuration and `lazy-lock.json` imported into Chezmoi; Mason packages installed separately.
- Pi 1.0.4 installed globally under Node 22.19.0. Pi configuration is partly managed by Chezmoi; auth files are sensitive and must be re-authenticated.
- Google Cloud SDK is installed under `~/Downloads/google-cloud-sdk`, but is explicitly excluded from migration. Its shell hooks were removed from `.zshrc`; current SDK files remain untouched until cleanup.

## Ordered slices

### 1. Freeze and inventory old laptop

- Commit and push Chezmoi source changes.
- Neovim changes, including `lazy-lock.json`, are committed locally as `92c2112`; push its separate repository only if that repository remains an intended remote source.
- Remove unused Lazyworktree cask and tap, then generate:
  - `Brewfile` containing intended formulae, casks, taps, and VS Code extensions.
  - Full Homebrew version snapshot, not only direct installs.
  - Node/npm global package snapshot.
  - `mise`, nvm, pyenv, rbenv, Swiftly, and Tuist version snapshots.
  - Xcodes/Xcode, Java, and selected developer-directory snapshot.
  - Neovim Mason package snapshot.
- Mark each item as portable, reinstallable, machine-specific, or secret.
- Inventory non-Homebrew applications and VS Code extensions.
- Find project-local `.env` files, signing files, local certificates, Git worktrees, and uncommitted changes across the TOCS repository and other active repositories; classify each before handover.
- For each project secret, record whether it is regenerated from company systems, manually re-entered, or intentionally excluded.
- Record Android SDK/AVD, iOS simulator, and Xcode requirements only; do not migrate managed signing or certificate material.

### 2. Make Chezmoi reproducible

- Keep imported `~/.config/nvim` in Chezmoi, including source files and `lazy-lock.json`.
- Exclude `.git`, `.DS_Store`, plugin directories, logs, swap files, shada, cache, and state.
- Make the Xcode debugger path portable; resolve PATH/Mason codelldb instead of assuming `~/tools/codelldb-darwin-arm64`.
- Add Homebrew, npm, runtime, Java, editor, and mobile version manifests.
- Keep `docs/migration/check-reproducible-setup.sh` as the small repeatable validation helper.
- Add an explicit non-migration list for Google Cloud SDK and other intentionally excluded tools.
- Replace hardcoded Homebrew and Java paths with portable resolution where practical.
- Keep Pi configuration and extensions in Chezmoi; keep Pi auth and MCP auth outside normal source files.
- Update Chezmoi README with migration procedure and current work-machine setup.

### 3. Skipped: encrypted migration bundle

This slice is intentionally skipped. Do not create or upload an encrypted bundle. Secrets, project-local credentials, GitHub access, AWS access, Artifactory/npm access, Jira, MCP, Copilot, and Pi authentication must be regenerated or re-entered on the replacement Mac.

Still excluded from any migration:

- macOS login Keychain contents.
- Apple Developer certificates, provisioning profiles, VPN certificates, MDM credentials, and managed signing material.
- Google Cloud SDK/configuration, caches, build outputs, `node_modules`, Pods, DerivedData, Neovim state, and generated package data.

### 4. Bootstrap replacement Mac

1. Complete company enrollment, MDM, VPN, FileVault, and required Apple tooling.
2. Install Homebrew, Git, and Chezmoi.
3. Clone/init Chezmoi and create machine-specific `chezmoi.toml` data.
4. Run `chezmoi diff`, then `chezmoi apply`.
5. Run `brew bundle` from managed manifests after reviewing taps.
6. Install Xcodes.app and required Xcode versions; set `xcode-select` to intended version and remove broken symlinks.
7. Install Node/npm, Java 17, and Pi at recorded versions; restore Pi non-secret config.
8. Start Neovim once, sync Lazy plugins, and allow Mason to install configured tools.
9. Clone active repositories and restore only files obtained through approved project/company systems.
10. Re-authenticate GitHub, Artifactory, AWS, Jira, MCP, Copilot, Pi, and other services.

### 5. Close remaining migration gaps

- Leave macOS login Keychain, Apple Developer certificates, provisioning profiles, VPN certificates, MDM credentials, and other managed material entirely to replacement laptop's company setup.
- Inventory browser profiles, password-manager access, VS Code extensions/settings, app licenses, and non-Homebrew application preferences needed for productive work.
- Check every active repository for unpushed commits, local branches, stashes, Git worktrees, ignored build-critical files, and local databases/Podman volumes.
- Decide whether emulator/simulator state is disposable; record required Android SDK packages, AVDs, iOS runtimes, and Xcode versions.
- Re-enter or regenerate each project secret from its approved company/project source.

### 6. Validate before retiring old laptop

- `chezmoi verify`
- New shell loads without errors.
- Git identity and credential helper are correct.
- Homebrew manifests complete successfully.
- `nvim` starts; Lazy lock is respected; LSP, formatter, debugger, and Treesitter work.
- Pi starts with expected extensions/configuration.
- Xcode, `xcodebuild`, Tuist, Fastlane, Android SDK, Java 17, and project builds work.
- All repositories have pushed commits and no required uncommitted work remains.

Only then wipe/return old laptop.

## Acceptance criteria

- Replacement Mac can be rebuilt from Chezmoi, Homebrew manifests, version manifests, and source repositories.
- Neovim and Pi non-secret configuration are restored without copying caches or generated state.
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
- Generated Homebrew, npm, runtime, Java, editor, mobile, VS Code, and repository status snapshots.
- Imported Neovim configuration and lockfile into Chezmoi; made codelldb lookup portable through PATH/Mason.
- Added portable Homebrew/Java shell resolution and repeatable setup check.
- Added explicit non-migration list and replacement-Mac resetup plan at `docs/plans/2026-06-22-new-machine-resetup-plan.md`.
- Encrypted migration bundle slice intentionally skipped by decision.
