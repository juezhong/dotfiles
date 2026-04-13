全局配置这两个文件的顺序是：

1. $XDG_CONFIG_HOME/git/config
2. ~/.gitconfig

所以如果两个都存在：

- 先读 ~/.config/git/config
- 后读 ~/.gitconfig
- 同一个键冲突时，~/.gitconfig 覆盖前者

也就是说，优先级上是 ~/.gitconfig 更高，因为它读得更晚。

你可以这样验证来源：

git config --global --show-origin --list

如果你想彻底走 XDG 风格，最稳妥的做法就是只保留 ~/.config/git/config，不要同时保留 ~/.gitconfig。
