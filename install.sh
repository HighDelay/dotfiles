#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
dry_run=false
packages=true
configs=true
backup_dir=

usage() {
    cat <<'EOF'
Usage: bash install.sh [--dry-run] [--configs-only | --packages-only]

Install the Hyprland dotfiles and packages on Arch Linux / Arch-based systems.
Run as your normal user; package installation uses sudo when needed.

  --dry-run        Print planned commands and file changes without writing anything
  --configs-only   Copy configs, fonts, wallpaper and EasyEffects preset only
  --packages-only  Install packages only (includes a full system upgrade)
  -h, --help       Show this help

Changes are recorded in ~/.local/state/dotfiles/backups/<unique-dir>/.
Use uninstall.sh to remove installed files and restore their previous versions.
Package-manager prompts remain interactive. If yay/paru is absent, build yay.
EOF
}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
run() {
    if "$dry_run"; then
        printf '  '; printf '%q ' "$@"; printf '\n'
    else
        "$@"
    fi
}

for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=true ;;
        --configs-only) packages=false ;;
        --packages-only) configs=false ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown option: $arg (see --help)" ;;
    esac
done
"$packages" || "$configs" || die 'Choose only one of --configs-only and --packages-only.'
[[ $(uname -s) == Linux ]] || die 'This installer must run on Linux.'
(( EUID != 0 )) || die 'Run as your normal user, without sudo.'
[[ ${HOME:-} == /* && $HOME != / && -d $HOME ]] || die 'HOME must be an existing absolute directory.'

trap 'printf "Installation stopped at line %s. Existing backups: %s\n" "$LINENO" "${backup_dir:-none}" >&2' ERR

# These configs use explicit ~/.config and ~/.local paths throughout.
if "$configs"; then
    [[ ${XDG_CONFIG_HOME:-$HOME/.config} == "$HOME/.config" ]] || die 'These dotfiles require XDG_CONFIG_HOME to be ~/.config.'
    [[ ${XDG_DATA_HOME:-$HOME/.local/share} == "$HOME/.local/share" ]] || die 'These dotfiles require XDG_DATA_HOME to be ~/.local/share.'
fi

sources=()
targets=()
add_file() {
    sources+=("$1")
    targets+=("$2")
}

# Refuse symlinked parent directories so installation never modifies their targets.
check_parents() {
    local parent=${1%/*}
    while [[ $parent != "$HOME" ]]; do
        [[ ! -L $parent ]] || die "Parent directory is a symlink: $parent"
        [[ ! -e $parent || -d $parent ]] || die "Parent path is not a directory: $parent"
        parent=${parent%/*}
    done
}

if "$configs"; then
    while IFS= read -r -d '' source; do
        relative=${source#"$repo_dir/"}
        # Do not import the author's music database or playback state.
        case "$relative" in .config/mpd/database|.config/cmus/autosave) continue ;; esac
        add_file "$source" "$HOME/$relative"
    done < <(find "$repo_dir/.config" "$repo_dir/.local/share/fonts" -type f -print0)
    add_file "$repo_dir/wallpaper.png" "$HOME/.config/hypr/wallpaper.png"
    add_file "$repo_dir/easyeffects-presets/HighDelay's EZFx Preset.json" "$HOME/.config/easyeffects/output/HighDelay's EZFx Preset.json"
    for target in "${targets[@]}" "$HOME/Pictures/.check" "$HOME/.local/state/dotfiles/backups/.check"; do
        check_parents "$target"
    done
    for source in "${sources[@]}"; do
        [[ -f $source ]] || die "Missing source file: $source"
    done
fi

if "$packages"; then
    command -v pacman >/dev/null || die 'Package installation requires Arch Linux / pacman. Use --configs-only on other distributions.'
    command -v sudo >/dev/null || die 'Install and configure sudo first.'
    package_list=()
    while IFS= read -r package || [[ -n $package ]]; do
        package=${package%$'\r'}
        [[ -z $package || $package == \#* ]] && continue
        [[ $package =~ ^[a-z0-9][a-z0-9@._+-]*$ ]] || die "Invalid package name in packages.txt: $package"
        package_list+=("$package")
    done < "$repo_dir/packages.txt"
    (( ${#package_list[@]} )) || die 'packages.txt is empty.'

    helper=
    if command -v yay >/dev/null; then
        helper=yay
    elif command -v paru >/dev/null; then
        helper=paru
    fi

    if [[ -z $helper ]]; then
        printf '\nInstalling build tools and building yay from the AUR.\n'
        run sudo pacman -Syu --needed git base-devel
        if "$dry_run"; then
            printf '  Clone https://aur.archlinux.org/yay.git into a temporary directory; run makepkg -si there.\n'
        else
            # Retain the build directory for inspection if the build fails.
            build_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-yay.XXXXXXXX")
            printf 'yay build directory: %s\n' "$build_dir"
            git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
            (cd -- "$build_dir/yay" && makepkg -si)
            command -v yay >/dev/null || die 'yay was not installed.'
        fi
        helper=yay
    fi
    printf '\nInstalling dependencies and upgrading the system with %s.\n' "$helper"
    run "$helper" -Syu --needed "${package_list[@]}"
fi

install_file() {
    local source=$1 target=$2 relative checksum
    relative=${target#"$HOME/"}
    if [[ ! -L $target && -f $target ]] && cmp -s -- "$source" "$target"; then
        if [[ $target != *.sh || -x $target ]]; then
            return
        fi
    fi
    printf 'Install %s\n' "$target"
    if ! "$dry_run"; then
        if [[ -z $backup_dir ]]; then
            mkdir -p -- "$HOME/.local/state/dotfiles/backups"
            backup_dir=$(mktemp -d "$HOME/.local/state/dotfiles/backups/$(date +%Y%m%d-%H%M%S-%N).XXXXXXXX")
            printf 'Installation record and backups: %s\n' "$backup_dir"
        fi
        checksum=$(sha256sum < "$source")
        checksum=${checksum%% *}
    fi
    if [[ -e $target || -L $target ]]; then
        if "$dry_run"; then
            printf '  Back up existing %s\n' "$relative"
        else
            mkdir -p -- "$backup_dir/files/$(dirname -- "$relative")"
            mv -- "$target" "$backup_dir/files/$relative"
        fi
    fi
    if ! "$dry_run"; then
        # Record before copying so an interrupted copy can still be recovered.
        printf '%s\0%s\0' "$relative" "$checksum" >> "$backup_dir/manifest"
    fi
    run mkdir -p -- "$(dirname -- "$target")"
    run cp -- "$source" "$target"
    if [[ $target == *.sh ]]; then
        run chmod u+x -- "$target"
    fi
}

if "$configs"; then
    printf '\nInstalling user files.\n'
    for i in "${!sources[@]}"; do
        install_file "${sources[i]}" "${targets[i]}"
    done
    run mkdir -p -- "$HOME/Pictures"
    if command -v fc-cache >/dev/null; then
        run fc-cache -f "$HOME/.local/share/fonts"
    else
        printf 'Font cache tool unavailable; run fc-cache -f after installing fontconfig.\n'
    fi
fi

if "$dry_run"; then
    printf '\nDry run complete; no changes made.\n'
else
    printf '\nInstallation complete. Backups: %s\n' "${backup_dir:-none needed}"
    printf 'Review the NVIDIA environment settings in ~/.config/hypr before starting Hyprland.\n'
    printf 'Log out and select Hyprland, or run start-hyprland from a TTY.\n'
fi
