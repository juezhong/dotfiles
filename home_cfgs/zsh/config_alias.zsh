### alias
# 考虑将一些实用性的命令写成 xx.zsh 文件的形式
# 用作 zsh 的函数，设置快捷键调用

alias ls='eza --icons=always --color=auto -h -g -O --git --git-repos --time-style=iso'
alias ll='ls -lh'
alias la='ls -alh'
# 使用 zoxide 替换 cd 命令，而 z 是 zoxide 的另一个函数映射
alias c='z'
alias grep='grep --color=auto'
alias rg='rg -S'
alias tree='tree -C'
alias pp='export $proxy_env'
alias up='unset ALL_PROXY'
alias cb='cmake -B build'
alias cc='cmake --build build'
alias rb='rm -r build'
alias ttytheme='ttyscheme -a $(ttyscheme -l | fzf)'
alias cman='man -L zh_CN'
alias vim='nvim'
alias vi='vim'
alias v='vi'







### 同样由于三个系统上可能命令不同，alias 的命令也不同
if [[ "$os_type" == "Darwin" ]]; then
  # echo "This is macOS."
  
elif [[ "$os_type" == "Linux" ]]; then
  # echo "This is Linux."
  # alias xclip='xclip -selection clipboard -rmlastnl'
  # xclip 的相关寄存器
  # primary: 鼠标选中某些单词即是使用了 primary 如果取消选中，则 primary 就被清空了
  # Shift + Insert 使用的是 primary
  # Ctrl + Insert 使用的 剪切板
  # clipboard: 剪切板，不会被清除
  alias xc='xclip -selection clipboard -rmlastnl && xclip -o -selection clipboard | xclip -selection primary -rmlastnl'
  alias xp='xclip -o -selection clipboard'  
  ### ues pacmd switch audio output
  alias pacmdswitcher='pacmd set-default-sink $(pacmd list-sinks | rg "name: <(.*)>" -0 | cut -d "<" -f 2 | cut -d ">" -f 1 | fzf)'
  ### use thunar(file manager) to open directory
  alias open='fd --color=always --hidden --exclude .git -t d | fzf --ansi | xargs thunar'
  # find / (whole disk) file to use
  alias rf='fd --color=always --hidden \
  --exclude boot \
  --exclude dev \
  --exclude lost+found \
  --exclude proc \
  --exclude .git \
  . / | fzf --ansi -0 | xc && xp'
  
  ### use neovim to edit any file
  alias rv='fd --color=always --hidden \
  	--exclude boot \
  	--exclude dev \
  	--exclude lost+found \
  	--exclude proc \
  	--exclude .git \
  	. / | fzf --ansi| xargs -I {} vim {}'
  
  ### find home file to use
  alias hf='fd --color=always --hidden --exclude .git . '/home/liyunfeng' | fzf --ansi -0 | xc && xp'
  
  ### use neovim to edit home file
  alias hv='fd --color=always --hidden --exclude .git -t f . '/home/liyunfeng' | fzf --ansi | xargs -I {} nvim {}'
  
  ### find current directory file
  alias cf='fd --color=always --hidden --exclude .git | fzf --ansi -0 | xc && xp'
  
  ### use neovim to edit current directory file
  alias cv='fd --color=always --hidden --exclude .git | fzf --ansi | xargs -I {} nvim {}'
elif [[ "$os_type" == CYGWIN* || "$os_type" == MINGW* ]]; then
  # echo "This is Windows (Cygwin/Mingw)."
fi







### End of alias
