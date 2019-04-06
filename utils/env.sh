REPO_PATH=$(git rev-parse --show-toplevel)
export PATH=$REPO_PATH/utils:$PATH

alias make="echo Running in docker; docker_run make"
alias gtkwave="echo Running in docker; docker_run gtkwave"
