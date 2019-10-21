#!/bin/bash


# this scripts convert a lattice file to the best word transcription. The main code is copied from score.sh. The transcription for each sentence will be output to stdout.
# This script could be used as the second step for a decoder: create 1 best transcription from a lattice file. The first step is to create that lattice file, which stores all possible transcriptions.

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 lattice-file symbol-table-file language-model-weight word-insertion-penalty"
    echo "  eg. $0 ~/github/kaldi/egs/timit/s5/exp/tri3/decode_test/lat.5.gz ~/github/kaldi/egs/timit/s5/exp/tri3/graph/words.txt 12 0.0"
    exit 1
fi

source ~/github/kaldi/setenv.sh

latfile=$1
symtab=$2
lmwt=$3
wip=$4

latfile="ark:gunzip -c $latfile|"
hyp_filtering_cmd=cat
int2sym_cmd=~/github/kaldi/egs/wsj/s5/utils/int2sym.pl


lattice-scale --inv-acoustic-scale=$lmwt "$latfile" ark:- | \
    lattice-add-penalty --word-ins-penalty=$wip ark:- ark:- | \
    lattice-best-path --word-symbol-table=$symtab ark:- ark,t:- | \
    $int2sym_cmd -f 2- $symtab | \
    $hyp_filtering_cmd