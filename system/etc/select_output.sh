#!/system/bin/sh
if [ "$1" == "0" -o "$1" == "1" -o "$1" == "2" -o "$1" == "3" ]; then
    setprop audio.output.selected $1
    result=`getprop audio.output.selected`
    if [ "$result" == "$1" ]; then
        echo 1
    else
        echo 0
    fi
else
    echo 0
fi
