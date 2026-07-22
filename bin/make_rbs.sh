#!/bin/sh

while (( "$#" ))
do
    SRC=$1
    shift

    TGT=`echo "sig/${SRC}s"`
    echo $SRC '->' $TGT

    mkdir -p `dirname $TGT`
    rbs prototype rb $SRC > $TGT
done
