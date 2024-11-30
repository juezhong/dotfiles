# dotfiles
> 用来同步配置的仓库，主要是符合 `XDG` 协议的配置文件存放目录，即 `.config` 目录
> 其他目录如 `/etc` , `~` 等单独新建目录使用
## sync method
1. 克隆仓库
2. 软链接目录
	```bash
	ln -s dotfiles .config
	```
