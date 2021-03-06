#!/bin/bash

# give a sound wav file(should be 8K sample frequence), output the transcription
# use some files of yesno, such as the model, word.txt, cmvn data, graph.

if [ "$#" -lt 1 ]; then
    echo "usage: $0 sound_file [feature-transform-file]"
    echo "  eg. $0 ./data/00001111.wav"
    exit 1
fi

tmpdir=./tmp
if [ ! -d $tmpdir ]; then
    mkdir $tmpdir
fi

source datapack.sh

latfile=$tmpdir/lat.gz

echo "run sound_to_lattice.sh "
./sound_to_lattice.sh $1 $latfile $2  2>$tmpdir/log.log  ||  exit 1;
echo "run lattice_to_transcription.sh"
./lattice_to_transcription.sh $latfile 2>>$tmpdir/log.log
