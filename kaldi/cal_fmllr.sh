#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0  <datadir> <outdir>"
    echo "  eg. $0 ./data/fmllr ./tmp"
    echo "  The output file is in <outdir>/trans.ark, which could be passed to transform-feats, to apply fmllr transformation."
    echo "  This program calulate fmllr transformation given sound file and its correspoding transcripton. so this is the supervise method."
    exit 1
fi


source datapack.sh

datadir=$1
outdir=$2

# the key result file of this step is $outdir/ali.gz, which is the alignment file
./create_align.sh $datadir $outdir

fmllr_update_type=full
adapt_model=$modeldir/final.mdl

post="ark:ali-to-post \"ark:gzip -d -c $outdir/ali.gz|\" ark:-|"
feats="ark,s,cs:apply-cmvn $cmvn_opts --utt2spk=ark:$datadir/utt2spk scp:$outdir/cmvn.scp scp:$outdir/feats.scp ark:- | add-deltas $delta_opts ark:- ark:- |"

gmm-est-fmllr --fmllr-update-type=$fmllr_update_type \
              --spk2utt=ark:$datadir/spk2utt \
              --fmllr-min-count=1 \
              $adapt_model "$feats" \
              "$post" ark:$outdir/trans.ark


# aplly the fmllr transformation, by transform-feats. the input file is trans.ark
# feats="$feats transform-feats --utt2spk=ark:$datadir/utt2spk ark:$outdir/trans.ark ark:- ark:- |"
