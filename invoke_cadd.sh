#!/bin/bash

CMD=$1

if [[ $CMD == "Dummy" ]];then
    echo "Dummy command"
    exit 0
else
    bash "$CMD1"
fi
