#!/usr/bin/env bash
set -Eeuo pipefail

dry_run=false
backup_dir=
usage() {
    cat <<'EOF'
Usage: bash uninstall.sh [--dry-run] [--backup PATH]

Undo the most recent recorded dotfiles installation, restoring original files.
  --dry-run       Preview removals and restores without changing anything
  --backup PATH   Undo a specific record printed by install.sh
  -h, --help      Show this help

Locally edited files are preserved and remain in the record for a later retry.
Packages and directories are kept. Run again to undo an older installation.
EOF
}
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
while (( $# )); do
    case "$1" in
        --dry-run) dry_run=true; shift ;;
        --backup)
            (( $# >= 2 )) || die '--backup requires a path.'
            backup_dir=$2; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown option: $1 (see --help)" ;;
    esac
done
[[ $(uname -s) == Linux ]] || die 'This uninstaller must run on Linux.'
(( EUID != 0 )) || die 'Run as your normal user, without sudo.'
[[ ${HOME:-} == /* && $HOME != / && -d $HOME ]] || die 'HOME must be an existing absolute directory.'
state_dir="$HOME/.local/state/dotfiles/backups"

if [[ -z $backup_dir ]]; then
    # Names start with a timestamp; completed uninstall records have no manifest.
    shopt -s nullglob
    for manifest in "$state_dir"/*/manifest; do
        backup_dir=${manifest%/manifest}
    done
    [[ -n $backup_dir ]] || { printf 'No recorded installation to uninstall.\n'; exit 0; }
fi
[[ -d $backup_dir && ! -L $backup_dir ]] || die 'Installation record is missing or is a symlink.'
backup_dir=$(cd -- "$backup_dir" && pwd -P)
[[ -f $backup_dir/manifest && ! -L $backup_dir/manifest ]] || die 'No installation manifest at the selected path.'
printf 'Uninstalling record: %s\n' "$backup_dir"

relatives=()
checksums=()
while IFS= read -r -d '' relative; do
    IFS= read -r -d '' checksum || die 'Incomplete installation manifest.'
    case "$relative" in
        .config/*|.local/share/fonts/*) ;;
        *) die "Unexpected manifest path: $relative" ;;
    esac
    [[ /$relative/ != */../* && /$relative/ != */./* && $relative != *//* ]] || die 'Unsafe manifest path.'
    [[ $checksum =~ ^[a-f0-9]{64}$ ]] || die 'Invalid checksum in manifest.'
    relatives+=("$relative")
    checksums+=("$checksum")
done < "$backup_dir/manifest"

# Preflight all parent paths before removing anything.
for relative in "${relatives[@]}"; do
    for base in "$HOME" "$backup_dir/files"; do
        parent="$base/${relative%/*}"
        while [[ $parent != "$base" ]]; do
            [[ ! -L $parent ]] || die "Parent directory is a symlink: $parent"
            [[ ! -e $parent || -d $parent ]] || die "Parent path is not a directory: $parent"
            parent=${parent%/*}
        done
        [[ ! -L $base ]] || die "Directory is a symlink: $base"
    done
done

skipped=0
for i in "${!relatives[@]}"; do
    relative=${relatives[i]}
    target="$HOME/$relative"
    original="$backup_dir/files/$relative"
    # Per-entry markers allow retries after a partial or interrupted uninstall.
    [[ ! -f $backup_dir/restored/$relative ]] || continue
    if [[ -e $target || -L $target ]]; then
        current=
        if [[ -f $target && ! -L $target ]]; then
            current=$(sha256sum < "$target")
            current=${current%% *}
        fi
        if [[ $current != "${checksums[i]}" ]]; then
            printf 'Preserving locally changed file: %s\n' "$target"
            skipped=$((skipped + 1))
            continue
        fi
        printf 'Remove %s\n' "$target"
        if ! "$dry_run"; then rm -- "$target"; fi
    fi
    if [[ -e $original || -L $original ]]; then
        printf 'Restore %s\n' "$target"
        if ! "$dry_run"; then
            mkdir -p -- "${target%/*}"
            # Copy the original, preserving the backup for manual recovery.
            cp -a -- "$original" "$target"
        fi
    fi
    if ! "$dry_run"; then
        mkdir -p -- "$backup_dir/restored/${relative%/*}"
        touch -- "$backup_dir/restored/$relative"
    fi
done

if "$dry_run"; then
    printf '\nDry run complete; no changes made.\n'
elif (( skipped )); then
    printf '\nKept %s edited file(s). Back them up elsewhere and remove them, then rerun to finish.\n' "$skipped"
else
    mv -- "$backup_dir/manifest" "$backup_dir/manifest.uninstalled"
    if command -v fc-cache >/dev/null; then fc-cache -f "$HOME/.local/share/fonts"; fi
    printf '\nDotfiles uninstalled. Original backups remain at %s\n' "$backup_dir/files"
fi
printf 'Installed packages have been kept. Log out to finish applying config changes.\n'
