### 通用配置

### Moved
### Lines configured by zsh-newuser-install
HISTFILE=$ZSH_HOME/.histfile
HISTSIZE=99999
SAVEHIST=99999
setopt appendhistory
setopt sharehistory
# 在前面加一个空格就会被忽略而不记录到历史命令
setopt hist_ignore_space
### End of lines configured by zsh-newuser-install

# Set case a/A
# 忽略补全大小写
autoload -Uz compinit && compinit -u
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
# 解决按 TAB 而不能使用 fzf 列表的问题，实际是被默认的 zshell 完成菜单占用了
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# 补全路径时 fzf 的预览开启，首先要是交互式的 cd 选取
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -l --color=always $realpath'
# custom fzf flags
# 注意：fzf-tab 默认情况下不遵循 FZF_DEFAULT_OPTS。
# zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# 注意：这可能会导致意外行为，因为某些标志会破坏此插件。请参阅 Aloxaf/fzf-tab#455。
# zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# environment variable
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'
# Homebrew
zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview 'brew info $word'
