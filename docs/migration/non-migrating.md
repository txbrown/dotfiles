# Explicit non-migration list

Do not copy these items to replacement Mac:

- Google Cloud SDK under `~/Downloads/google-cloud-sdk` and related shell/configuration state.
- macOS login Keychain contents.
- Apple Developer certificates, provisioning profiles, VPN certificates, MDM credentials, and managed signing material.
- Homebrew, npm, Mason, Swift, Android, iOS, Neovim, and build caches.
- `node_modules`, CocoaPods `Pods`, Xcode `DerivedData`, Android build outputs, iOS build outputs, and generated package data.
- Neovim state/cache, plugin installations, shada, swap files, and logs.
- Whole-home-directory or whole-repository copies.

User-managed skill source files under `~/.pi/agent/skills/` and `~/.agents/skills/` are the exception: they are explicitly listed in `secret-archive-manifest.txt` for encrypted transfer. Reinstallable Pi package caches and `node_modules` remain excluded.

Reinstall or regenerate excluded items from package managers, source repositories, company enrollment, or project tooling on the replacement Mac.
