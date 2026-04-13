### Mac 的 zsh 配置

if [[ -x /opt/homebrew/bin/brew ]]; then
  _source_cached_eval_output "brew-shellenv" "/opt/homebrew/bin/brew" /opt/homebrew/bin/brew shellenv
fi
## ## Disable brew auto update
## export HOMEBREW_NO_AUTO_UPDATE=1
## ## Disable brew auto cleanup
## export HOMEBREW_NO_INSTALL_CLEANUP=1
## ## Disable brew auto formul or cask when 'brew install'
## export HOMEBREW_NO_INSTALL_UPGRADE=1

_setup_nvm_base_node_path

###
### Initialize the plugins installed via 'brew install'.
###
# init fzf
if command -v fzf > /dev/null 2>&1; then
    fzf_path=$(command -v fzf)
    _source_cached_eval_output "fzf-init" "$fzf_path" "$fzf_path" --zsh
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
  _source_cached_eval_output "starship-init" "$starship_path" "$starship_path" init zsh
fi

# init zoxide
# 检测有没有 zoxide 命令
if command -v zoxide > /dev/null 2>&1; then
  #echo "Command zoxide exists."
  zoxide_path=$(command -v zoxide)
  _source_cached_eval_output "zoxide-init" "$zoxide_path" "$zoxide_path" init zsh
fi

# init uv
if command -v uv > /dev/null 2>&1; then
  uv_path=$(command -v uv)
  _source_cached_eval_output "uv-completion" "$uv_path" "$uv_path" generate-shell-completion zsh
fi

###
### Initialize the plugins installed via 'brew install'.
###

# /Users/liyunfeng/scripts/pokemon -r

if [[ -e "$ZSH_HOME/self_env.zsh" ]]; then
	source "$ZSH_HOME/self_env.zsh"
fi

if [[ -e "$ZSH_HOME/self_functions.zsh" ]]; then
	source "$ZSH_HOME/self_functions.zsh"
fi

export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
export CMAKE_PREFIX_PATH="/opt/homebrew/opt/llvm"
