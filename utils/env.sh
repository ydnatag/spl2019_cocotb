REPO_PATH=$(git rev-parse --show-toplevel)
export PATH=$REPO_PATH/utils:$PATH
alias make="docker_run make"
alias gtkwave="docker_run gtkwave"
