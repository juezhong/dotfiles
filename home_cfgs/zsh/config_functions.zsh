### Functions
function cdd
{
    destination_dir=$(dirname $1)
    local os_type=$(uname -s)
    if [[ "$os_type" == "Linux" ]] then
        destination_dir=$(dirname $1 -z)
    fi
    chdir $destination_dir
}

function tree_cp
{
    # paremeter number
    # echo $#
    local level=$1
    local os_type=$(uname -s)
    if [[ "$os_type" == "Linux" ]] then
        # echo "Linux system"
        # 直接通过命令输出复制，都不需要函数
        tree -L $level | xc
    fi
    # MINGW64_NT-10.0-19045
    if [[ "$os_type" == "MINGW64_NT-10.0-19045" ]] then
        tree -L $level | xargs -0 echo > level_utf8.txt
        # echo "MINGW64_NT-10.0-19045"
        iconv -c -f UTF-8 -t GBK level_utf8.txt > level_gbk.txt
        CLIP < level_gbk.txt
        rm -rf level_utf8.txt level_gbk.txt
    fi
}

function is_ubuntu
{
    # uname -a | grep -i "ubuntu" | wc -l
    uname -a | grep -iq "ubuntu"
}

function is_windows
{
    # elif [[ "$os_type" == CYGWIN* || "$os_type" == MINGW* ]]; then
    (uname -s | grep -iq "CYGWIN") || (uname -s | grep -iq "MINGW")
    # (uname -a | grep -iq "MINGW64_NT") || (uname -a | grep -iq "MSYS_NT")
}

# logger, record log messages with line number to ~/log_zsh.txt
# Usage: logger "message"
function logger
{
    # echo $@ >> ~/log_zsh.txt
    echo $(date "+%Y-%m-%d %H:%M:%S") $@ >> ~/log_zsh.txt
}
### End of functions

