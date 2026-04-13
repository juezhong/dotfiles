python_hook() {
    if [[ -d .venv ]]; then
        source .venv/bin/activate
    elif [[ -d venv ]]; then
        source venv/bin/activate
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
    fi
}

ls_hook() {
    ls
}

autoload -Uz add-zsh-hook

add-zsh-hook chpwd python_hook
add-zsh-hook chpwd ls_hook
