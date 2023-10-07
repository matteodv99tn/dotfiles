#!/usr/bin/bash

## --- Variables
PACK_DIR=$HOME/programs
mkdir -p $PACK_DIR


## --- Custom functions ---------------------------------------------------------------------------

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


# Checks if a elment is present in a list.
# Arguments:
#  $1: the element to search
#  $2: the list where to search
# Return 0 if the element is present, 1 otherwise.
is_in_list(){
    elem=$1
    shift 1
    list=$@

    for e in $list; do
        if [ $e == $elem ]; then
            return 0
        fi
    done
    return 1
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

# Blue colored info message.
info(){
    printf "\e[1;34m$1\e[0m\n"
}


## --- Help message -------------------------------------------------------------------------------
if [[ $# -eq 0 ]]; then
    info "Script won't run, at least one argument must be supplied"
    info "For default installation: ./script.sh default"
    cat << EOF
List of available commands:
    default
    --update
    --upgrade
    --base
    --fonts
    --alacritty
    --neovim
    --qtile
    --picom
    --xmonad
    --rofi
EOF
exit 1
fi

## --- Component selector -------------------------------------------------------------------------
get_updates=false
install_upgrades=false
install_base_packages=false
install_fonts=false
install_alacritty=false
install_neovim=false
install_picom=false
install_qtile=false
install_xmonad=false
install_rofi=false

if is_in_list "default" $@; then # default installation
    get_updates=true
    install_upgrades=true
    install_base_packages=true
    install_fonts=true
    install_neovim=true
    install_alacritty=true
fi

if is_in_list "--update" $@; then # updates
    get_updates=true
fi

if is_in_list "--upgrade" $@; then # upgrades
    get_updates=true
    install_upgrades=true
fi

if is_in_list "--base" $@; then # base packages
    install_base_packages=true
fi

if is_in_list "--fonts" $@; then # fonts packages
    install_fonts=true
fi

if is_in_list "--alacritty" $@; then # alacritty
    install_alacritty=true
fi

if is_in_list "--neovim" $@; then # neovim
    install_neovim=true
fi

if is_in_list "--picom" $@; then # picom
    install_picom=true
fi

if is_in_list "--qtile" $@; then # qtile
    install_picom=true
    install_rofi=true
    install_qtile=true
fi

if is_in_list "--xmonad" $@; then # xmonad
    install_picom=true
    install_xmonad=true
fi

if is_in_list "--rofi" $@; then # xmonad
    install_rofi=true
fi

## --- Installs -----------------------------------------------------------------------------------
if $get_updates; then # updates
    info "Getting apt updates"
    sudo apt update -y
fi

if $install_upgrades; then
    info "Upgrading packages"
    sudo apt upgrade -y
fi

if $install_base_packages; then # base packages
    info "Installing base packages"
    sudo apt install -y \
        curl grep ripgrep git python3 fuse g++ meson ninja-build python3-pip \
        build-essential libssl-dev libffi-dev python3-dev python3-venv \
        python-is-python3 autoconf libtool pkg-config npm
    mkdir -p ~/.local/bin
    echo "export PATH=\$HOME/.local/bin:\$PATH" >> $HOME/.bashrc >> $HOME/.bashrc
fi

if $install_fonts; then # fonts
    info "Installing fonts"
    sudo apt install -y \
        figlet
    FONTSDIR=$HOME/.local/share/fonts
    mkdir -p $FONTSDIR
    pushd $FONTSDIR
    info "Downloading nerd-fonts"
    echo "Installing RobotMono"
    curl -LOs https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/RobotoMono.zip
    echo "Installing Mononoki"
    curl -LOs https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/Mononoki.zip
    echo "Installing JetBrains Mono"
    curl -LOs https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/JetBrainsMono.zip
    echo "Installing FiraCode"
    curl -LOs https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/FiraCode.zip
    unzip -n "*.zip"
    rm *.zip
    fc-cache -f -v
    popd
fi

if $install_alacritty; then # alacritty
    info "Installing alacritty dependencies"
    sudo apt install -y \
        cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
        python3 rustc cargo
    orig_dir=$(pwd)
    info "Building alacritty from source"
    if is_git_repo $PACK_DIR/alacritty; then
        cd $PACK_DIR/alacritty
        git pull
    else
        cd $PACK_DIR
        git clone https://github.com/jwilm/alacritty.git
        cd alacritty
    fi
    pushd $PACK_DIR/alacritty
    cargo build --release
    info "Adding Alacritty desktop entry"
    sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database
    popd
fi

if $install_neovim; then
    info "Installing neovim"
    pushd ~/.local/bin
    echo "Downloading neovim..."
    curl -LOs https://github.com/neovim/neovim/releases/v3.0.1/download/nvim.appimage
    info "Install packer from git"
    PACKER_DIR=$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim
    if is_git_repo $PACKER_DIR; then
	cd $PACKER_DIR
	git pull
    else
	git clone --depth 1 https://github.com/wbthomason/packer.nvim $PACKER_DIR
    fi
    chmod u+x nvim.appimage
    mv $HOME/.local/bin/nvim.appimage $HOME/.local/bin/nvim
    chmod u+x $HOME/.local/bin/nvim
    popd
fi

if $install_picom; then
    info "Installing picom dependencies"
    sudo apt install -y \
        libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev \
        libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev \
        libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev \
        libdbus-1-dev libconfig-dev libgl1-mesa-dev  libpcre2-dev  libevdev-dev uthash-dev \
        libev-dev libx11-xcb-dev libpcre++-dev
    info "Installing picom"
    orig_dir=$(pwd)
    if is_git_repo $PACK_DIR/picom; then
        cd $PACK_DIR/picom
        git pull
    else
        cd $PACK_DIR
        # forks
        # git clone https://github.com/dccsillag/picom
        git clone https://github.com/jonaburg/picom
        # git clone https://github.com/pijulius/picom
        cd picom
    fi
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install
    cd $orig_dir
fi

if $install_qtile; then
    info "Installing qtile from pip"
    pip3 install xcffib
    pip3 install qtile psutil
    info "Creating qtile.xsession file"
    sudo cat > /usr/share/xsessions/qtile.xsession << EOF
[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=qtile start
Type=Application
Type=wm;tiling
EOF
fi

if $install_xmonad; then
    info "Installing Xmonad"
    # sudo apt install -y \
    #     xmonad libghc-xmonad-contrib-dev xmobar dmenu feh
    # mkdir -p $HOME/.config/xmonad
    # ln -s $HOME/.config/xmonad $HOME/.xmonad
    sudo apt install -y \
        git libx11-dev libxft-dev libxinerama-dev libxrandr-dev libxss-dev \
        haskell-stack
    mkdir -p $HOME/.config/xmonad
    pushd $HOME/.config/xmonad
    git clone https://github.com/xmonad/xmonad
    git clone https://github.com/xmonad/xmonad-contrib
    stack init
    stack install
    popd
fi

if $install_rofi; then # rofy
    info "Installing rofi package"
    sudo apt install -y rofi
    orig_dir=$(pwd)
    info "Installing rofi theme collection"
    if is_git_repo $PACK_DIR/rofi; then
        cd $PACK_DIR/rofi
        git pull
    else
        cd $PACK_DIR
        git clone --depth=1 https://github.com/adi1090x/rofi.git
        cd rofi
    fi
    pushd $PACK_DIR/rofi
    chmod +x setup.sh
    ./setup.sh
    popd
fi

