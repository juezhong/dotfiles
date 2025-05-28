### Mac 的 zsh 配置

eval "$(/opt/homebrew/bin/brew shellenv)"
## Disable brew auto update
export HOMEBREW_NO_AUTO_UPDATE=1
## Disable brew auto cleanup
export HOMEBREW_NO_INSTALL_CLEANUP=1
## Disable brew auto formul or cask when 'brew install'
export HOMEBREW_NO_INSTALL_UPGRADE=1

# init fzf
if command -v fzf > /dev/null 2>&1; then
    fzf_path=$(command -v fzf)
    eval "$($fzf_path --zsh)"
fi

if [[ -e self_env.zsh ]]; then
	source self_env.zsh
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

