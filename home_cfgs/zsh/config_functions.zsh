### Functions
function cdd
{
    destination_dir=$(dirname $1 -z)
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
### End of functions