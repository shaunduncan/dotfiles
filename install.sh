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
mkdir -p ~/.tmux
mkdir -p ~/.tmux/plugins
mkdir -p ~/.vim
mkdir -p ~/.zsh

# files that should exist
touch ~/.secrets.env

# permissions that might be required
chmod -R 0700 ~/.sockets
chmod -R 0700 ~/.ssh
chmod 0700 ~/.secrets.env

# install the things tracked here
ln -sf ${dotfiles}/tmux/tmux.conf ~/.tmux.conf
ln -sf ${dotfiles}/alacritty/alacritty.yaml ~/.config/alacritty/alacritty.yml
ln -sf ${dotfiles}/vim/vimrc ~/.vimrc
ln -sf ${dotfiles}/vim/snips ~/.vim/UltiSnips
ln -sf ${dotfiles}/zsh/zshenv ~/.zshenv
ln -sf ${dotfiles}/zsh/zshrc ~/.zshrc
ln -sf ${dotfiles}/bin/* ~/bin/
ln -sf ${dotfiles}/ssh_config ~/.ssh/config
ln -sf ${dotfiles}/git_config ~/.gitconfig
ln -sf ${dotfiles}/aws/alias ~/.aws/cli/alias

# mac-specifig things
if [[ "${platform}" == "darwin" ]]; then
  echo "installing mac specific utilities"

  # gopls
  mkdir -p ~/Library/LaunchAgents
  ln -sf ${dotfiles}/mac/gopls.plist ~/Library/LaunchAgents/gopls.plist

  # yabai and skhd
  ln -sf ${dotfiles}/mac/dot_skhdrc ~/.skhdrc
  ln -sf ${dotfiles}/mac/dot_yabairc ~/.yabairc

  # install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  cat ${dotfiles}/mac/homebrew.list | xargs brew install -f -q

  # change the default shell
  chsh -s $(which zsh)
fi

# linux: this assumes debian-based
if [[ "${platform}" == "linux" ]]; then
  sudo apt update && sudo apt install -y --no-install-recommends \
    ca-certificates \
    cargo \
    curl \
    git \
    gnupg \
    htop \
    jq \
    qemu \
    silversearcher-ag \
    tmux \
    tree \
    vim \
    wget \
    zsh

  # change the default shell
  chsh -s $(which zsh)

  # go
  if [[ ! -f ~/go/bin/go ]]; then
    pushd ${HOME}
    wget -O go.tar.gz https://go.dev/dl/go1.20.2.linux-386.tar.gz
    tar -xvzf go.tar.gz
    rm -f go.tar.gz
    popd
  fi

  export PATH=${PATH}:${HOME}/go/bin

  # tools that require go
  go install gitlab.com/gitlab-org/cli@latest

  # docker
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y --no-install-recommends \
    docker-ce-cli \
    docker-buildx-plugin \
    docker-compose-plugin

  # minikube
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
  sudo dpkg -i minikube_latest_amd64.deb
  rm -f minikube_latest_amd64.deb

  # alacritty
  sudo apt install -y --no-install-recommends \
    cmake \
    pkg-config \
    libfreetype6-dev \
    libfontconfig1-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    python3
  cargo install alacritty

  # git-delta
  cargo install git-delta
fi

# tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# ssh public keys
curl https://github.com/shaunduncan.keys > ~/.ssh/authorized_keys
chmod 0644 ~/.ssh/authorized_keys
