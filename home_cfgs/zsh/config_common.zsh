### 通用配置

### Moved
### Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
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
zstyle ':completion:*' menu no
# 补全路径时 fzf 的预览开启，首先要是交互式的 cd 选取
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'
