#!/bin/bash
# This script commits any local configuration changes and automatically
# pushes them to the remote.
#
# Uploads newest versions of dotfiles from the $HOME dir into
# $HOME/.BACKUP_CONFIG, a folder created by the provisioning script
# that is linked to the remote configuration repo.
# taken from: https://thmsdnnr.com/blog/automatically-backup-config-with-git-and-cron/

BACKUP_DIR="$HOME/.BACKUP_CONFIG"
THIS_SCRIPT_FULL_PATH="$BACKUP_DIR/$(basename -- "$0")"
DOTFILE_DIR="$BACKUP_DIR/dotfiles"
mkdir -p "$BACKUP_DIR"
mkdir -p "$DOTFILE_DIR"

BREW_INSTALLS_FILENAME="brew_bundle_dump"
# VSCODE_EXTENSIONS_FILENAME="vscode_extensions"

/usr/local/bin/brew bundle dump --force --file="$BACKUP_DIR/$BREW_INSTALLS_FILENAME"
# /usr/local/bin/code --list-extensions > "$BACKUP_DIR/$VSCODE_EXTENSIONS_FILENAME"
dotfile_list=(\
  "$HOME/.bash_aliases" \
  "$HOME/.bash_profile" \
  "$HOME/.ctags" \
  "$HOME/.gitconfig" \
  "$HOME/.gitignore_global" \
  "$HOME/.ideavimrc" \
  "$HOME/.tmux.conf.local" \
  "$HOME/.zshrc" \
  "$HOME/.config/karabiner/karabiner.json" \
  "$HOME/.config/nvim/init.vim" \
  "$HOME/.config/skhd/skhdrc" \
  "$HOME/.config/yabai/yabairc" )

for file in "${dotfile_list[@]}"; do cp "$file" "$DOTFILE_DIR"; done

cd "$DOTFILE_DIR" || exit
if ! git diff --quiet HEAD || git status --short; then
  git add --all
  git commit -m "updating dotfiles on $(date -u)"
  git push origin master
fi

# Make this script call itself hourly from the crontab, if it isn't already.
if ! crontab -l | grep "$THIS_SCRIPT_FULL_PATH"; then
  (crontab -l ; echo "0 14 * * * $THIS_SCRIPT_FULL_PATH > /dev/null 2>&1") | sort - | uniq - | crontab - 2>&1
fi
