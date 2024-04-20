alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

export PATH=$HOME/.local/bin:$PATH
# . "$HOME/.cargo/env"

eval "$(starship init bash)"

function cd() {
  builtin cd "$@"

  if [[ -z "$VIRTUAL_ENV" ]] ; then
    ## If env folder is found then activate the vitualenv
      if [[ -d ./.venv ]] ; then
        source ./.venv/bin/activate  # commented out by conda initialize
      fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
      parentdir="$(dirname "$VIRTUAL_ENV")"
      if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        deactivate
      fi
  fi
}
alias bton="sudo service bluetooth start"
alias btoff="sudo service bluetooth stop"

# https://www.reddit.com/r/ROS/comments/15yr1zm/ros_c_coding_setup/
# export CC=clang
# export CXX=clang++
# export CLANG_BASE="--build-base build_clang --install-base install_clang"
# export BUILD_ARGS="--symlink-install ${CLANG_BASE} --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
export BUILD_ARGS="--cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
alias cb="cd $HOME/workspaces/ros/ && colcon build --symlink-install ${BUILD_ARGS}"
add-compile-commands() {
    dest_dir=$(find src -name "${1}" -type d -print -quit)
    if [ -z ${dest_dir} ]; then
        echo "Failed to find destination directory"
        return 1
    fi
    ln -s ${PWD}/build/${1}/compile_commands.json ${dest_dir}/compile_commands.json
}
# To use the command, go to the ros workspace directory and type
# add-compile-commands <package_name>
alias add_compile_commands="add-compile-commands"
