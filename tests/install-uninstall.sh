#!/usr/bin/env bash
# Isolated integration checks; package tools are mocked, no packages are installed.
set -Eeuo pipefail
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_root=$(mktemp -d)
test_root=$(cd -- "$test_root" && pwd -P)
trap 'printf "Test artifacts: %s\n" "$test_root"' EXIT
export HOME="$test_root/home with spaces"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export PACKAGE_LOG="$test_root/packages.log"
mkdir -p "$HOME" "$test_root/bin"
export PATH="$test_root/bin:$PATH"

# Permit exercising file operations through Git Bash on Windows as well.
printf '#!/usr/bin/env bash\nprintf "Linux\\n"\n' > "$test_root/bin/uname"
for command in sudo pacman yay paru fc-cache; do
    cat > "$test_root/bin/$command" <<'EOF'
#!/usr/bin/env bash
printf '%s %s\n' "${0##*/}" "$*" >> "$PACKAGE_LOG"
exit "${FAKE_PACKAGE_FAIL:-0}"
EOF
done
chmod +x "$test_root/bin/"*

install_configs() { bash "$repo_dir/install.sh" --configs-only "$@" > "$test_root/install.log"; }
uninstall_configs() { bash "$repo_dir/uninstall.sh" "$@" > "$test_root/uninstall.log"; }
latest_record() {
    local manifest result=
    for manifest in "$HOME/.local/state/dotfiles/backups/"*/manifest; do
        [[ -f $manifest ]] && result=${manifest%/manifest}
    done
    printf '%s' "$result"
}

install_configs --dry-run
[[ ! -e $HOME/.config && ! -e $HOME/.local && ! -e $PACKAGE_LOG ]]
printf 'PASS: dry run leaves home untouched\n'

mkdir -p "$HOME/.config/kitty"
printf 'original config\n' > "$HOME/.config/kitty/kitty.conf"
printf 'unrelated config\n' > "$HOME/.config/kitty/keep-me"
install_configs
record=$(latest_record)
[[ -n $record && -f $record/files/.config/kitty/kitty.conf ]]
cmp "$repo_dir/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cmp "$repo_dir/wallpaper.png" "$HOME/.config/hypr/wallpaper.png"
[[ -x $HOME/.config/rofi/clipboard.sh && -d $HOME/Pictures ]]
[[ ! -e $HOME/.config/mpd/database && ! -e $HOME/.config/cmus/autosave ]]
[[ ! -e $HOME/.git && ! -e $HOME/.xinitrc ]]
printf 'PASS: copies files, backs up conflicts, excludes personal and legacy files\n'

install_configs
[[ $(latest_record) == "$record" ]]
uninstall_configs --dry-run
[[ -f $HOME/.config/hypr/hyprland.conf && -f $record/manifest ]]
printf 'PASS: repeated install is unchanged and uninstall dry run makes no changes\n'

printf 'my local edits\n' > "$HOME/.config/kitty/kitty.conf"
uninstall_configs
[[ $(cat "$HOME/.config/kitty/kitty.conf") == 'my local edits' ]]
[[ -f $record/manifest && ! -e $HOME/.config/hypr/hyprland.conf ]]
rm -- "$HOME/.config/kitty/kitty.conf"
uninstall_configs
[[ $(cat "$HOME/.config/kitty/kitty.conf") == 'original config' ]]
[[ -f $HOME/.config/kitty/keep-me && -f $record/manifest.uninstalled ]]
[[ -f $record/files/.config/kitty/kitty.conf ]]
uninstall_configs
grep -q 'No recorded installation' "$test_root/uninstall.log"
printf 'PASS: protects edits, retries, restores originals and keeps unrelated files\n'

FAKE_PACKAGE_FAIL=1
export FAKE_PACKAGE_FAIL
if bash "$repo_dir/install.sh" > "$test_root/failure.log" 2>&1; then
    printf 'FAIL: package failure should stop installation\n'; exit 1
fi
[[ ! -e $HOME/.config/hypr/hyprland.conf ]]
unset FAKE_PACKAGE_FAIL
bash "$repo_dir/install.sh" --packages-only > "$test_root/packages-only.log"
grep -q 'yay -Syu --needed hyprland' "$PACKAGE_LOG"
[[ ! -e $HOME/.config/hypr/hyprland.conf ]]
mv "$test_root/bin/yay" "$test_root/yay"
bash "$repo_dir/install.sh" --packages-only > "$test_root/paru.log"
grep -q 'paru -Syu --needed hyprland' "$PACKAGE_LOG"
printf 'PASS: package failure stops file changes; yay/paru use full upgrade\n'

if bash "$repo_dir/install.sh" --configs-only --packages-only > "$test_root/options.log" 2>&1; then
    printf 'FAIL: conflicting options accepted\n'; exit 1
fi
if bash "$repo_dir/uninstall.sh" --backup > "$test_root/options.log" 2>&1; then
    printf 'FAIL: missing backup path accepted\n'; exit 1
fi
printf 'PASS: rejects invalid options\n'
