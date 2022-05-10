#!/bin/bash

# this script is downloaded from the config repo and run on
# a new machine to reinstall all packages, configure dotfiles,
# and set up preferences

# secret, set up my SSH

# secret, set up git

# .dotfiles paths
BACKUP_DIR="$HOME/.BACKUP_CONFIG"
DOTFILES_DIR="$BACKUP_DIR/dotfiles"
BREW_INSTALLS_FILE="$BACKUP_DIR/brew_bundle_dump"
VSCODE_EXTENSIONS_FILE="$BACKUP_DIR/vscode_extensions"

# Clone my dotfiles repo: $BACKUP_DIR is my local folder where
# backup copies of all my dotfiles and config are saved.
git clone --depth=1 git@github.com:ME/MYSECRETREPO.git "$BACKUP_DIR" || {
  printf "Error: git clone of configuration repo failed\n"
  exit 1
}
# Copy dotfiles into homedir
cp -a "$DOTFILES_DIR" "$HOME"
git config --global core.excludesfile "$DOTFILES_DIR/.gitignore_global"

# Install Brew
if test ! "$(command -v brew)"; then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha

# Install all brew packages
brew update-reset && brew update
brew tap Homebrew/bundle
brew bundle install --file="$BREW_INSTALLS_FILE"
brew upgrade --all && brew cleanup

# Set up packages just installed via homebrew

## vscode
### install extensions
while IFS= read -r line; do
  code --install-extension "$line"
done < "$VSCODE_EXTENSIONS_FILE"

### import settings
VSCODE_SETTINGS_FOLDER="$HOME/Library/Application Support/Code/User/"
mkdir -p "$VSCODE_SETTINGS_FOLDER"
mv "$DOTFILES_DIR/vscode_settings.json" "$VSCODE_SETTINGS_FOLDER/settings.json"

# bootstrap my backup script
"$BACKUP_DIR/config_updater.sh"
