### 不同的系统类型使用不同的配置
# echo $(pwd)
# 定义全局变量，用于加载配置文件，通过解析软链接
if [[ -e ~/.zshrc ]]; then
  real_path=$(dirname $(realpath ~/.zshrc))
else
  real_path=$(realpath ~/.config/zsh)
fi
os_type=$(uname)
proxy_env="ALL_PROXY=socks5://127.0.0.1:10808"

### 加载通用的配置
source "$real_path/config_common.zsh"
### 加载函数配置
source "$real_path/config_functions.zsh"
### 加载别名配置
source "$real_path/config_alias.zsh"

### 系统特定配置
if [[ "$os_type" == "Darwin" ]]; then
  # echo "This is macOS."
  ### 加载插件配置
  source "$real_path/plugins/mac_plugins.zsh"
  source "$real_path/os_configs/mac_config.zsh"
elif [[ "$os_type" == "Linux" ]]; then
  # echo "This is Linux."
  ### 加载插件配置
  source "$real_path/plugins/linux_plugins.zsh"
  source "$real_path/os_configs/linux_config.zsh"
elif [[ "$os_type" == CYGWIN* || "$os_type" == MINGW* ]]; then
  # echo "This is Windows (Cygwin/Mingw)."
  ### 加载插件配置
  source "$real_path/plugins/windows_plugins.zsh"
  source "$real_path/os_configs/windows_config.zsh"
else
  echo "Unknown operating system."
fi

