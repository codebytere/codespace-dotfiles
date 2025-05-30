#!/bin/bash

# Copy dotfiles to a directory in the home directory.
copy_dotfiles_dir() {
  script_dir=$(dirname "$(readlink -f "$0")")
  dotfiles_dir="$HOME/.dotfiles"

  echo "Copying dotfiles directory to home directory..."

  if [ ! -d "$dotfiles_dir" ]; then
    mkdir -p "$dotfiles_dir"
  fi

  cp -r "$script_dir/." "$dotfiles_dir/"
  echo "✓ Successfully copied dotfiles to $dotfiles_dir"
}

# Create symlinks for dotfiles in the home directory.
create_symlinks() {
  script_dir=$(dirname "$(readlink -f "$0")")
  files=$(find -maxdepth 1 -type f -name ".*")

  for file in $files; do
    name=$(basename $file)
    echo "Creating symlink to $name in home directory."
    rm -rf ~/$name
    ln -s $script_dir/$name ~/$name
  done
}

# Download .gdbinit file from V8 repository.
download_gdbinit() {
  local url="https://raw.githubusercontent.com/v8/v8/refs/heads/main/tools/gdbinit"
  local filename=".gdbinit"
  
  echo "Downloading .gdbinit from V8 repository..."

  if curl -fsSL "$url" -o "$HOME/$filename"; then
    echo "✓ Successfully downloaded .gdbinit to home directory"
  else
    echo "✗ Failed to download .gdbinit"
    return 1
  fi
}

copy_dotfiles_dir

create_symlinks

download_gdbinit

# Install ripgrep if not already installed.
if ! command -v rg &> /dev/null; then
  sudo apt-get install -y ripgrep
else
  echo "ripgrep is already installed."
fi
