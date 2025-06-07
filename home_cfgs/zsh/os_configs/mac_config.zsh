### Mac 的 zsh 配置

eval "$(/opt/homebrew/bin/brew shellenv)"
## Disable brew auto update
export HOMEBREW_NO_AUTO_UPDATE=1
## Disable brew auto cleanup
export HOMEBREW_NO_INSTALL_CLEANUP=1
## Disable brew auto formul or cask when 'brew install'
export HOMEBREW_NO_INSTALL_UPGRADE=1

###
### Initialize the plugins installed via 'brew install'.
###
# init fzf
if command -v fzf > /dev/null 2>&1; then
    fzf_path=$(command -v fzf)
    eval "$($fzf_path --zsh)"
fi

# init starship
if command -v starship > /dev/null 2>&1; then
  starship_path=$(command -v starship)
  # 检查有没有 ~/.config/starship.toml 文件，只判断不存在的情况，默认存在
  if [ ! -f ~/.config/starship.toml ]; then
    #echo "File ~/.config/starship.toml does not exist."
    # 没有，则创建一个
    $starship_path preset nerd-font-symbols -o ~/.config/starship.toml
    # 加载 starship
  fi
  ##eval "$($starship_path completions zsh)"
  eval "$($starship_path init zsh)"
fi

# init zoxide
# 检测有没有 zoxide 命令
if command -v zoxide > /dev/null 2>&1; then
  #echo "Command zoxide exists."
  zoxide_path=$(command -v zoxide)
  eval "$($zoxide_path init zsh)"
fi

if [[ -e self_env.zsh ]]; then
	source self_env.zsh
fi
###
### Initialize the plugins installed via 'brew install'.
###

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

