#!/bin/bash
set -euo pipefail

platform=$(uname -s | tr '[:upper:]' '[:lower:]')

echo "setting up vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp .vimrc ~/
vim +PlugInstall +qall!

echo "setting up user directories"
mkdir -p ~/.ssh/sockets
chmod 0700 ~/.ssh

echo "setting up tmux"
cp .tmux.${platform}.conf ~/.tmux.conf

echo "setting up zsh"
cp .zshrc ~/
