### 不同的系统类型使用不同的配置

# 定义全局变量，用于加载配置文件，通过解析软链接
real_path=$(dirname $(realpath ~/.zshrc))
os_type=$(uname)
proxy_env="ALL_PROXY=socks5://127.0.0.1:10808"

### 加载通用的配置
source "$real_path/config_common.zsh"
### 加载函数配置
source "$real_path/config_functions.zsh"
### 加载插件配置
source "$real_path/config_plugins.zsh"
### 加载别名配置
source "$real_path/config_alias.zsh"

### 系统特定配置
if [[ "$os_type" == "Darwin" ]]; then
  # echo "This is macOS."
  source "$real_path/config_mac.zsh"
elif [[ "$os_type" == "Linux" ]]; then
  # echo "This is Linux."
  source "$real_path/config_linux.zsh"
elif [[ "$os_type" == CYGWIN* || "$os_type" == MINGW* ]]; then
  # echo "This is Windows (Cygwin/Mingw)."
  source "$real_path/config_windows.zsh"
else
  echo "Unknown operating system."
fi

