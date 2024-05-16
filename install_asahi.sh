#!/bin/bash
set -euo pipefail
set -x

platform=$(uname -s | tr '[:upper:]' '[:lower:]')
dotfiles="${HOME}/.config/dotfiles"

if [[ "${PWD}" != "${dotfiles}" ]]; then
  echo "fatal: incorrect install dir: ${PWD} != ${dotfiles}"
  exit 1
fi

echo "installing dotfiles and utilities"

# ensure all directories
mkdir -p ~/bin
mkdir -p ~/.aws/cli
mkdir -p ~/.config/alacritty
mkdir -p ~/.sockets
mkdir -p ~/.ssh/conf.d
mkdir -p ~/.ssh/socks
mkdir -p ~/.tmux/plugins
mkdir -p ~/.vim/{backup,nvim-backup,nvim-undo,undo,view}
mkdir -p ~/.zsh/{backup,undo}

# files that should exist
touch ~/.secrets.env

# permissions that might be required
chmod -R 0700 ~/.sockets
chmod -R 0700 ~/.ssh
chmod 0700 ~/.secrets.env

# install the things tracked here
ln -sfn ${dotfiles}/tmux/tmux.conf ~/.tmux.conf
ln -sfn ${dotfiles}/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
ln -sfn ${dotfiles}/vim/vimrc ~/.vimrc
ln -sfn ${dotfiles}/vim/snips ~/.vim/UltiSnips
ln -sfn ${dotfiles}/nvim ~/.config/
ln -sfn ${dotfiles}/zsh/zshenv ~/.zshenv
ln -sfn ${dotfiles}/zsh/zshrc ~/.zshrc
ln -sfn ${dotfiles}/bin/* ~/bin/
ln -sfn ${dotfiles}/ssh_config ~/.ssh/config
ln -sfn ${dotfiles}/git_config ~/.gitconfig
ln -sfn ${dotfiles}/aws/alias ~/.aws/cli/alias

# other misc dotfiles
ln -sfn ${dotfiles}/misc/agignore ~/.agignore

# package installation
sudo dnf update

sudo dnf install -y \
  ca-certificates \
  cargo \
  clang \
  cmake \
  curl \
  dkms \
  dnf-plugins-core \
  fontconfig \
  fontconfig-devel \
  freetype \
  freetype-devel \
  git \
  gnupg \
  golang \
  htop \
  jq \
  kernel-16k-devel \
  libdrm \
  libdrm-devel \
  libxkbcommon \
  libxkbcommon-devel \
  llvm \
  mlocate \
  neovim \
  net-tools \
  p7zip \
  pybind11-devel \
  python3-devel \
  python3-pybind11 \
  qemu \
  scdoc \
  the_silver_searcher \
  tmux \
  tree \
  vim \
  wget \
  zsh \
  ;

# zsh plugins
if [[ ! -d /usr/local/share/zsh-autosuggestions ]]; then
  sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/local/share/zsh-autosuggestions
fi

if [[ ! -d /usr/local/share/zsh-history-substring-search ]]; then
  sudo git clone https://github.com/zsh-users/zsh-history-substring-search /usr/local/share/zsh-history-substring-search
fi

export PATH=${PATH}:${HOME}/go/bin

# tools that require go (these break on the first go and need a restart)
# NOTE: the gitlab go install requires that you add their key to known hosts (not sure why)
go install gitlab.com/gitlab-org/cli/cmd/glab@main
go install github.com/derailed/k9s@latest

# docker
which docker >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo groupadd docker || true
  sudo usermod -aG docker ${USER}
  newgrp docker

  # podman for emulation
  sudo dnf install -y podman
fi

# kubectl
which kubectl >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# alacritty
if [[ ! -f ~/.cargo/bin/alacritty ]]; then
  pushd /tmp
  rm -rf alacritty || true
  git clone https://github.com/shaunduncan/alacritty
  cd alacritty
  cargo install --path alacritty
  sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
  popd
fi

# git-delta
if [[ ! -f ~/.cargo/bin/delta ]]; then
  cargo install git-delta
fi

# change the default shell
usershell=$(getent passwd $(id -un) | awk -F ':' '{print $NF}')

if [[ "${usershell}" != "$(which zsh)" ]]; then
  chsh -s $(which zsh)
fi

# tmux plugins
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ssh public keys
curl https://github.com/shaunduncan.keys > ~/.ssh/authorized_keys
chmod 0644 ~/.ssh/authorized_keys

# evdi / displaylink
if [[ -z "$(dkms status | grep -i evdi)" ]]; then
  pushd /tmp
  rm -rf evdi || true
  git clone https://github.com/DisplayLink/evdi
  cd evdi/module
  sudo mkdir -p /usr/src/evdi-1.14.4
  sudo cp -f * /usr/src/evdi-1.14.4
  sudo dkms build -m evdi -v 1.14.4
  sudo dkms build -m evdi -v 1.14.4 --force
  sudo dkms install -m evdi -v 1.14.4
  sudo dkms install -m evdi -v 1.14.4 --force

  # now the displaylink thing
  echo "Go to here and install the displaylink driver: https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu"
  echo "unzip displaylink.zip"
  echo "chmod +x displaylink-driver-6.0.0-24.run"
  echo "sudo ./displaylink-driver-6.0.0-24.run -h"
  echo "sudo ./displaylink-driver-6.0.0-24.run --info"
  echo "sudo ./displaylink-driver-6.0.0-24.run --lsm"
  echo "sudo ./displaylink-driver-6.0.0-24.run --list"
  echo "sudo ./displaylink-driver-6.0.0-24.run --check"
  echo "sudo ./displaylink-driver-6.0.0-24.run --confirm"

  popd
fi

# i own /opt
sudo chown -R sduncan:sduncan /opt

# gcloud
which gcloud >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-aarch64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
  sudo dnf install -y google-cloud-cli
fi

# aws
which aws >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  pushd /tmp
  curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  popd
fi
