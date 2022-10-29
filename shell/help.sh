#!/usr/bin/env bash

# 帮助文档
helpdoc(){
    cat <<EOF
Description:

    This is a help document
    - Plot circos

Usage:

    $0 -i <input file> -o <output file>

Option:

    -i    this is a input file
    -o    this is a output file
EOF
}

# 参数传递
while getopts ":i:o:" opt
do
    case $opt in
        i)
        infile=`echo $OPTARG`
        ;;
        o)
        outfile=`echo $OPTARG`
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

# 若无指定任何参数则输出帮助文档
if [ $# = 0 ]
then
    helpdoc
    exit 1
fi

# 核心代码
cat $infile | grep '[12]' > $outfile