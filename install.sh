#!/usr/bin/bash

## --- Variables
PACK_DIR=$HOME/pack_dir 
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
    --alacritty
    --neovim
    --qtile
EOF
exit 1
fi

## --- Component selector -------------------------------------------------------------------------
get_updates=false
install_upgrades=false
install_base_packages=false
install_alacritty=false
install_neovim=false
install_qtile=false

if is_in_list "default" $@; then # default installation
    get_updates=true
    install_upgrades=true
    install_base_packages=true
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

if is_in_list "--alacritty" $@; then # alacritty
    install_alacritty=true
fi

if is_in_list "--neovim" $@; then # neovim
    install_neovim=true
fi

if is_in_list "--qtile" $@; then # qtile
    install_qtile=true
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
        curl grep ripgrep git python3
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
    cargo build --release
fi

if $install_neovim; then
    info "Installing neovim"
    echo "Downloading neovim..."
    curl -LOs https://github.com/neovim/neovim/releases/latest/download/nvim.appimage 
    echo "Download finished"
    mv nvim.appimage $HOME/.local/bin/nvim 
    chmod u+x $HOME/.local/bin/nvim
fi

if $install_qtile; then
    info "Installing qtile from pip"
    pip3 install xcffib
    pip3 install qtile
    info "Creating qtile.xsession file"
    sudo cat > /usr/share/xsessions/qtile.xsession << EOF
[Desktop Entry]
Name=Qtile 
Comment=Qtile Session 
Exec=qtile start
Type=Application
Type=wm;tiling
EOF
    info "Installing picom dependencies (for qtile)"
    sudo apt install -y \
        libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev \
        libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev \
        libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev \
        libdbus-1-dev libconfig-dev libgl1-mesa-dev  libpcre2-dev  libevdev-dev uthash-dev \
        libev-dev libx11-xcb-dev
    info "Installing picom (for qtile)"
    orig_dir=$(pwd)
    if is_git_repo $PACK_DIR/picom; then
        cd $PACK_DIR/picom
        git pull
    else 
        cd $PACK_DIR
        git clone https://github.com/jonaburg/picom
        cd picom
    fi
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install
    cd $orig_dir
fi
