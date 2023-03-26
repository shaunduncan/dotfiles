#!/bin/bash
set -uo pipefail
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
ln -sfn ${dotfiles}/tmux/tmux.conf ~/.tmux.conf
ln -sfn ${dotfiles}/alacritty/alacritty.yaml ~/.config/alacritty/alacritty.yml
ln -sfn ${dotfiles}/vim/vimrc ~/.vimrc
ln -sfn ${dotfiles}/vim/snips ~/.vim/UltiSnips
ln -sfn ${dotfiles}/zsh/zshenv ~/.zshenv
ln -sfn ${dotfiles}/zsh/zshrc ~/.zshrc
ln -sfn ${dotfiles}/bin/* ~/bin/
ln -sfn ${dotfiles}/ssh_config ~/.ssh/config
ln -sfn ${dotfiles}/git_config ~/.gitconfig
ln -sfn ${dotfiles}/aws/alias ~/.aws/cli/alias

# mac-specifig things
if [[ "${platform}" == "darwin" ]]; then
  echo "installing mac specific utilities"

  # gopls
  mkdir -p ~/Library/LaunchAgents
  ln -sfn ${dotfiles}/mac/gopls.plist ~/Library/LaunchAgents/gopls.plist

  # yabai and skhd
  ln -sfn ${dotfiles}/mac/dot_skhdrc ~/.skhdrc
  ln -sfn ${dotfiles}/mac/dot_yabairc ~/.yabairc

  # install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  cat ${dotfiles}/mac/homebrew.list | xargs brew install -f -q
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
    mlocate \
    qemu \
    silversearcher-ag \
    tmux \
    tree \
    vim \
    wget \
    zsh

  # zsh plugins
  if [[ ! -d /usr/local/share/zsh-autosuggestions ]]; then
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/local/share/zsh-autosuggestions
  fi

  if [[ ! -d /usr/local/share/zsh-history-substring-search ]]; then
    sudo git clone https://github.com/zsh-users/zsh-history-substring-search /usr/local/share/zsh-history-substring-search
  fi

  # go
  if [[ ! -f ~/go/bin/go ]]; then
    pushd ${HOME}
    wget -O go.tar.gz https://go.dev/dl/go1.20.2.linux-amd64.tar.gz
    tar -xvzf go.tar.gz
    rm -f go.tar.gz
    popd
  fi

  export PATH=${PATH}:${HOME}/go/bin

  # tools that require go
  which glab >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    go install gitlab.com/gitlab-org/cli/cmd/glab@latest
  fi

  # docker
  which docker >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
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
  fi

  # kubectl
  which kubectl >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/kubectl
  fi

  # minikube
  which minikube >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    sudo dpkg -i minikube_latest_amd64.deb
    rm -f minikube_latest_amd64.deb
  fi

  # alacritty
  if [[ ! -f ~/.cargo/bin/alacritty ]]; then
    sudo apt install -y --no-install-recommends \
      cmake \
      pkg-config \
      libfreetype6-dev \
      libfontconfig1-dev \
      libxcb-xfixes0-dev \
      libxkbcommon-dev \
      python3
    cargo install alacritty
  fi

  # git-delta
  if [[ ! -f ~/.cargo/bin/delta ]]; then
    cargo install git-delta
  fi
fi

# change the default shell
if [[ "$(getent passwd $(id -un) | awk -F ':' '{print $NF}')" != "$(which zsh)" ]]; then
  chsh -s $(which zsh)
fi

# tmux plugins
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ssh public keys
curl https://github.com/shaunduncan.keys > ~/.ssh/authorized_keys
chmod 0644 ~/.ssh/authorized_keys
