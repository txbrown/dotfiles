#!/usr/bin/env bash
set -euo pipefail

HOME_DIR=${HOME:?HOME must be set}
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MANIFEST=${1:-"$SCRIPT_DIR/secret-archive-manifest.txt"}
OUTPUT=${2:-"$HOME_DIR/Desktop/laptop-migration-$(date +%Y-%m-%d).tar.gpg"}

[[ -f "$MANIFEST" ]] || { printf 'Manifest not found: %s\n' "$MANIFEST" >&2; exit 1; }

paths=()
while IFS= read -r path || [[ -n "$path" ]]; do
  [[ -z "$path" || "$path" == \#* ]] && continue
  case "$path" in
    /*|../*|*/../*|.|./*)
      printf 'Unsafe manifest path: %s\n' "$path" >&2
      exit 1
      ;;
  esac
  [[ -f "$HOME_DIR/$path" ]] || {
    printf 'Missing regular file: %s\n' "$HOME_DIR/$path" >&2
    exit 1
  }
  paths+=("$path")
done < "$MANIFEST"

((${#paths[@]} > 0)) || { printf 'Manifest has no files\n' >&2; exit 1; }

mkdir -p "$(dirname -- "$OUTPUT")"
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/laptop-migration.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT
archive="$tmpdir/files.tar"

# Paths are relative to HOME, so extraction restores their expected locations.
tar -C "$HOME_DIR" --no-recursion -cf "$archive" "${paths[@]}"

export GPG_TTY=$(tty 2>/dev/null || true)
gpg --pinentry-mode loopback --symmetric --cipher-algo AES256 --output "$OUTPUT" "$archive"
chmod 600 "$OUTPUT"
shasum -a 256 "$OUTPUT" > "$OUTPUT.sha256"
chmod 600 "$OUTPUT.sha256"

printf 'Encrypted archive: %s\nChecksum: %s\nFiles: %d\n' \
  "$OUTPUT" "$OUTPUT.sha256" "${#paths[@]}"
printf 'Upload archive and checksum only to approved company storage. Keep passphrase in password manager.\n'
