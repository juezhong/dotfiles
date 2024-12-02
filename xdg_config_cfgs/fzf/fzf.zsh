# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/liyunfeng/.local/share/zinit/plugins/junegunn---fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/liyunfeng/.local/share/zinit/plugins/junegunn---fzf/bin"
fi

source <(fzf --zsh)
