#!/bin/bash -e

# Blue colored info message.
info(){
    printf "\e[1;34m$1\e[0m\n"
}

# Checks if a path is a git repository or not
is_git_repo(){
    if [ ! -d $1 ]; then
        return 1
    fi
    cd $1
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) ]]; then
        cd - > /dev/null
        return 0
    else
        cd - > /dev/null
        return 1
    fi
}

# This script downloads the files from the given URLs and saves them in the given directory.
# Arguments:
#   $1: the directory where the files will be saved
#   then all the URLs of the files to download
# Files will be saved with the original name.
download_contents(){
    DOWNLOAD_DIR=$1
    shift 1
    FILES_URL=$@

    cd $DOWNLOAD_DIR
    for FILE in $FILES_URL; do
        curl -JLO $FILE
    done
    cd - > /dev/null
}

PACK_DIR=$HOME/programs
MY_BASH=$HOME/.mybashrc
mkdir -p $PACK_DIR

info "Getting updates"
sudo apt update -y
info "Upgrading"
sudo apt upgrade -y

info "Installing apt packages"
sudo apt install -y  \
        curl grep ripgrep git python3 fuse g++ meson ninja-build python3-pip \
        build-essential libssl-dev libffi-dev python3-dev python3-venv \
        python-is-python3 autoconf libtool pkg-config npm \
        figlet \
        cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
        python3 rustc cargo \
        curl libfuse2 npm python3.12-venv

mkdir -p ~/.local/bin
# echo "alias ..='cd ..'" > $MY_BASH
# echo "alias ...='cd ../..'" > $MY_BASH
# echo "export PATH=\$HOME/.local/bin:\$PATH" >> $MY_BASH


# info "Installing fonts"
# FONTSDIR=$HOME/.local/share/fonts
# mkdir -p $FONTSDIR
# pushd $FONTSDIR
# info " > Downloading RobotMono"
# curl -LOs https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/RobotoMono.zip
# info " > Downloading Mononoki"
# curl -LOs https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/Mononoki.zip
# info  " > Downloading JetBrains Mono"
# curl -LOs https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/JetBrainsMono.zip
# info " > Downloading FiraCode"
# curl -LOs https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/FiraCode.zip
# info " > Unzipping files"
# unzip -n "*.zip"
# rm *.zip
# fc-cache -f -v
# popd


info "Installing Alacritty"
if is_git_repo $PACK_DIR/alacritty; then
    info " > Pulling updated"
    cd $PACK_DIR/alacritty
    git pull
else
    info " > Cloning repo"
    cd $PACK_DIR
    git clone https://github.com/jwilm/alacritty.git
    cd alacritty
fi
cargo build --release
info "Adding Alacritty desktop entry"
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database


