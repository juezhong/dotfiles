### 通用配置

### Moved
### Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=99999
SAVEHIST=99999
### End of lines configured by zsh-newuser-install

# Set case a/A
# 忽略补全大小写
autoload -Uz compinit && compinit -u
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
