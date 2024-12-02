#export ALL_PROXY=socks5://172.23.128.1:10808
# p10k 最先加载就会先显示 zsh 主题，但插件还是会有延迟一点（因为顺序问题）（大部分延迟因为末尾注释的 conda 脚本
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#
####### if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#######   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
####### fi
# End of Powerlevel10k



### Myself Config ------------------------------------------------


### Plugins

####### prompt 主题
######zinit ice depth 1
######zinit light romkatv/powerlevel10k
######
####### 命令高亮
######zinit ice wait lucid depth 1
######zinit light zsh-users/zsh-syntax-highlighting
######
####### 命令补全
#######zinit ice wait lucid depth 1
#######zinit ice depth 1
#######zinit light zsh-users/zsh-completions
######
####### 历史命令补全
######zinit ice depth 1
######zinit light zsh-users/zsh-autosuggestions
######
####### 替换默认的补全菜单选择，使用了 fzf 需提前安装
######zinit ice wait lucid depth 1
######zinit light Aloxaf/fzf-tab
######
####### fzf
####### 刚好借助 zinit 管理 fzf 的脚本，不然只单独安装二进制包没有自动补全和按键绑定
####### 使用 ice 修饰符 atclone 在克隆完成后执行一条命令
######zinit ice wait lucid atclone "bash $HOME/.local/share/zinit/plugins/junegunn---fzf/install" depth 1 
######zinit light junegunn/fzf
######
####### 目录导航工具，适用于过去访问过的每个目录
####### 该插件允许根据模糊匹配和访问该目录的频率导航到以前去过的任何目录
######zinit ice wait lucid depth 1
######zinit light rupa/z

### End of Plugins




### End of myself config ------------------------------------------------


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
###### [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

##########################
# 注：p10k 需要的字体仓库
# https://github.com/romkatv/powerlevel10k-media
# 克隆后手动安装，步骤
# mkdir /usr/share/fonts/{font-name}
# mv {fonts} /usr/share/fonts/{font-name}
# fc-cache
# 在当前目录建立字体数据缓存
# fc-cache Build font information caches in [dirs]

# 借助 zinit 管理 fzf 运行克隆下来仓库里面的 install 脚本自动添加的
###### [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

###### export PATH=$PATH:~/.local/share/nvim/mason/bin/
###### export LANG=zh_CN.UTF8
###### export LANGUAGE=zh_CN:en_US
###### export EDITOR=nvim

if is_ubuntu; then
  # echo "System is Ubuntu"
  export PATH=$PATH:~/.local/share/nvim/mason/bin/
  export PATH=$PATH:~/.local/bin
  # add eza
  export $proxy_env
  zinit ice wait lucid depth"1" from"gh-r" as"command"
  zinit load eza-community/eza
  unset ALL_PROXY

  # lazygit
  zinit ice wait lucid depth"1" from"gh-r" sbin"lazygit"
  zinit load jesseduffield/lazygit

  export PATH=$PATH:~/.local/share/nvim/mason/bin/
  export LANG=zh_CN.UTF8
  export LANGUAGE=zh_CN:en_US
  export EDITOR=nvim
else
  # echo "Def ArchLinux"
fi

