#!/bin/bash


# this scripts convert a lattice file to the best word transcription. The main code is copied from score.sh. The transcription for each sentence will be output to stdout.
# This script could be used as the second step for a decoder: create 1 best transcription from a lattice file. The first step is to create that lattice file, which stores all possible transcriptions.

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 lattice-file"
    echo "  eg. $0 ~/github/kaldi/egs/timit/s5/exp/tri3/decode_test/lat.5.gz"
    exit 1
fi

source datapack.sh

latfile=$1

latfile="ark:gunzip -c $latfile|"
hyp_filtering_cmd=cat
int2sym_cmd=$KALDI_ROOT/egs/wsj/s5/utils/int2sym.pl

lattice-scale --inv-acoustic-scale=$language_model_weight "$latfile" ark:- | \
    lattice-add-penalty --word-ins-penalty=$word_insertion_penalty ark:- ark:- | \
    lattice-best-path --word-symbol-table=$graphdir/words.txt ark:- ark,t:- | \
    $int2sym_cmd -f 2- $graphdir/words.txt | \
    $hyp_filtering_cmd