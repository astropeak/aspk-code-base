#!/bin/bash

# This scripts calsulate lattice given a wav sound file.
# eg: ./sound_to_lattice.sh aaa 2.lat.gz
# the first parameter is a sound file, which is ignored for now. The second parameter is the output lattice file.

source ~/github/kaldi/setenv.sh

sound_file=$1
feats=xxx

outfile=$2

# TODO: replace xxx
max_active=50000
beam=32
lattice_beam=20
acwt=0.1
graphdir=xxx
decode_extra_opts=
model=xxx

# for yesno eg
modeldir=./model
graphdir=$modeldir
model=$modeldir/final.mdl
# sdata=/Users/astropeak/github/kaldi/egs/yesno/s5/data/test_yesno
# directory
sdata=data

cmvn_opts=
delta_opts=

tmpdir=./tmp


# 0 prepare wav.scp, utt2spk
# 需要给出一个ID, 这个ID 在wav.scp 及utt2spk文件中会用.
ID=wav_ID
echo "$ID $sound_file" > $tmpdir/wav.scp
echo "$ID global" > $tmpdir/utt2spk


# 1: from sound to feature
# 1.1 create mffc, stored in fests.scp
compute-mfcc-feats  --use-energy=false --sample-frequency=8000 --verbose=2 scp:$tmpdir/wav.scp ark,scp:$tmpdir/feats.ark,$tmpdir/feats.scp

# 1.2 process mffc, apply cmnv, add deltas
feats="ark,s,cs:apply-cmvn $cmvn_opts --utt2spk=ark:$tmpdir/utt2spk scp:$model/cmvn.scp scp:$tmpdir/feats.scp ark:- | add-deltas $delta_opts ark:- ark:- |"
# feats="ark,s,cs:add-deltas $delta_opts scp:$tmpdir/feats.scp ark:- |"
# if remove --utt2spk, there is error like.
# WARNING (apply-cmvn[5.4.218~2-e6fe]:main():apply-cmvn.cc:112) No normalization statistics available for key 1_1_1_1_1_1_1_1, producing no output for this utterance
# LOG (apply-cmvn[5.4.218~2-e6fe]:main():apply-cmvn.cc:162) Applied cepstral mean normalization to 0 utterances, errors on 29
# so no output will be produced by apply-cmnv
# the utt2spk map all utt to a global speaker, which is a key to query cmnv statictics from cmnv.scp. So if that key is not availble, then no cmnv info, so on ouput
# so in decoer, we sould always map a utt to the global speker.
# feats="ark,s,cs:apply-cmvn $cmvn_opts scp:$sdata/cmvn.scp scp:$tmpdir/feats.scp ark:- | add-deltas $delta_opts ark:- ark:- |"

# 2: from feature to lattice
gmm-latgen-faster --max-active=$max_active --beam=$beam --lattice-beam=$lattice_beam \
                  --acoustic-scale=$acwt --allow-partial=false --word-symbol-table=$graphdir/words.txt $decode_extra_opts \
                  $model $graphdir/HCLG.fst "$feats" "ark:|gzip -c > $outfile" || exit 1;

