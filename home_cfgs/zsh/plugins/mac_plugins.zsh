
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

### 基本插件加载
### zinit load zdharma/history-search-multi-word
### zinit light zsh-users/zsh-syntax-highlighting
### 以上命令展示了两种最基本的加载插件的方式。
### load 会启用分析功能——你可以通过 zinit report {plugin-spec} 跟踪插件具体做了什么，
### 也可以使用 zinit unload {plugin-spec} 卸载插件。
### light不会跟踪加载过程，可以提升加载速度，但是会导致失去查看插件报告和动态卸载插件的能力。
### 开启 Turbo mode 后跟踪插件所耗费的时间可以忽略不计
### Turbo Mode (Zsh >= 5.3)：
### Zinit 中所谓的 Turbo Mode，其实就是插件延迟加载功能，
### 更确切的说，就是使用ice修饰符的 wait 选项进行插件加载。比如：
### zinit ice wait
### zinit load {plugin-spec}
### 示例：
### zinit ice wait
### zinit load zsh-users/zsh-completions
### 使用 Turbo Mode 加载插件时，插件的加载过程会被延迟，直到 Zsh 完成初始化。
### 这意味着插件的加载不会立即发生，而是在 Zsh 完成初始化后进行。
### 这对于提高启动时间非常有用，因为插件的加载不会在启动过程中立即执行。

### Some comment
### PS1="READY > "
### zinit ice wait'!0'
### zinit load halfo/lambda-mod-zsh-theme
### 上述命令表示终端在加载完成.zshrc文件并成功显示第一个 prompt 时，
### 加载插件halfo/lambda-mod-zsh-theme。
### 实际上插件真正进行加载大约是在提示符READY >出现后的 1ms 内。
### 更多关于 ice 的用法参见 https://github.com/zdharma-continuum/zinit#ice-modifiers
### 示例：lucid 参数是为了开启 wait 静默输出
### zinit ice wait lucid
### zinit load zdharma-continuum/history-search-multi-word

### 全局 ice 选项：light-mode (以 light 模式加载)
###  zinit light-mode for \
###     lucid wait zsh-users/zsh-completions \ # 仅适用于此插件的 ice 选项：lucid (静默延迟加载消息), wait (延迟加载)
###     zsh-users/zsh-syntax-highlighting # 以 light 模式 (全局 ice 选项) 正常加载
### 不要直接复制上面的代码，因为有语法错误 (不允许在 \ 后面写注释)，无法运行。
### 不设置任何 ice 选项，依次加载每个插件。
###  zinit for \
###      zsh-users/zsh-completions \
###      zsh-users/zsh-syntax-highlighting
### End of comment

### Plugins ###

#zinit ice wait lucid depth 1 atinit"zpcompinit; zpcdreplay"
#zinit load zdharma-continuum/fast-syntax-highlighting

#zinit ice wait lucid depth 1 atload"_zsh_autosuggest_start"
#zinit load zsh-users/zsh-autosuggestions

#zinit ice wait lucid depth 1
#zinit load zsh-users/zsh-completions

# 以上三行代码展示了如何使用 zinit 加载多个插件，并指定插件的加载顺序
# 使用 for 选项可以指定多个插件的加载顺序
zinit wait lucid depth"1" for \
    atinit"zpcompinit; zpcdreplay" zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' zsh-users/zsh-completions
# 命令高亮
# 历史命令补全
# 命令补全

# prompt 主题
# 首先检测有没有 starship 命令，这里也是要替换到 mac_config.zsh 中，因为通过 brew install

# 由于 starship 是通过 homebrew 安装的，但是 homebrew 的路径是在 mac_config.zsh 中设置并生效的
# 所以这时候检测不到有 starship 命令
# 这部分在 mac_config.zsh 中初始化

# https://github.com/ajeetdsouza/zoxide
# 目录导航工具，适用于过去访问过的每个目录
# 该插件允许根据模糊匹配和访问该目录的频率导航到以前去过的任何目录
# 仓库确实有一个 zoxide.plugin.zsh 文件，但是只是检查有没有安装 zoxide 命令
# 但是不能使用 fbin"zoxide" 选项，fbin 会把 zoxide 作为一个函数
# 因为会从环境变量中读取 zoxide 命令，而不是使用函数
# 所以要分两步，一次安装 zoxide 命令，一次加载 zoxide.plugin.zsh 文件

# 检测有没有 zoxide 命令
if command -v zoxide > /dev/null 2>&1; then
  #echo "Command zoxide exists."
  zoxide_path=$(command -v zoxide)
  eval "$($zoxide_path init zsh)"
else
  #echo "Command zoxide does not exist."
  # 没有，则安装 zoxide 命令
  export $proxy_env
  zinit ice wait lucid depth"1" from"gh-r" as"command" atclone"./zoxide init zsh > init.zsh" \
      src"init.zsh"
  zinit load ajeetdsouza/zoxide
  unset ALL_PROXY  
fi

#fzf --zsh > init.zsh 
#/opt/homebrew/bin/fzf
# echo "This is macOS."
# C-r, C-t 这些快捷键需要通过 install 脚本生成，然后 source 使用
# 这部分需要更新使用方式
# 由于 fzf 是通过 homebrew 安装的，但是 homebrew 的路径是在 mac_config.zsh 中设置并生效的
# 所以这时候检测不到有 fzf 命令
# 这部分在 mac_config.zsh 中初始化

zinit ice wait lucid depth"1" src"fzf-tab.plugin.zsh"
zinit load Aloxaf/fzf-tab

######
####### 替换默认的补全菜单选择，使用了 fzf 需提前安装
######zinit ice wait lucid depth 1
######zinit light Aloxaf/fzf-tab
######
####### fzf
####### 刚好借助 zinit 管理 fzf 的脚本，不然只单独安装二进制包没有自动补全和按键绑定
####### 但是首先需要安装 fzf 的二进制包
####### 使用 ice 修饰符 atclone 在克隆完成后执行一条命令
######zinit ice wait lucid atclone "bash $HOME/.local/share/zinit/plugins/junegunn---fzf/install" depth 1 
######zinit light junegunn/fzf


### End of Plugins ###
