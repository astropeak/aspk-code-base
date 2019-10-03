#!/bin/bash

# extract one fst for a lattice file by lattice-to-fst and fstcopy, and convert that fst to picture

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 latfile key"
    exit 1
fi

latfile=$1
key=$2

lattice-to-fst "ark:gunzip -c $latfile|" ark:1.fsts
fstcopy 'ark:1.fsts' "scp,p:echo $key -|" >1.fst
fstdraw --osymbols=model/words.txt 1.fst |dot -Tps > 1.ps
