#!/bin/bash

set +x

# This scripts calsulate lattice given a wav sound file.
# eg: ./sound_to_lattice.sh aaa 2.lat.gz
# the first parameter is a sound file, which is ignored for now. The second parameter is the output lattice file.
# to enable fmllr, set the do_fmllr to true

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <sound_file> <lattice-file>"
    echo "  eg. $0 ./data/00001111.wav tmp/lat.gz"
    echo "Note: to enable fmllr, set the do_fmllr to true"
    exit 1
fi

do_fmllr=false
# do_fmllr=true



# datapack
source datapack.sh

sound_file=$1
outfile=$2

# below values could also be moved to datapack file
max_active=50000
beam=32
lattice_beam=20
acwt=0.1
decode_extra_opts=


# for yesno eg
model=$modeldir/final.mdl
# sdata=/Users/astropeak/github/kaldi/egs/yesno/s5/data/test_yesno
# directory
sdata=data

cmvn_opts=`cat $modeldir/cmvn_opts` || exit 1;
delta_opts=

tmpdir=./tmp


# 0 prepare wav.scp, utt2spk
# 需要给出一个ID, 这个ID 在wav.scp 及utt2spk文件中会用.
ID=wav_ID
echo "$ID $sound_file" > $tmpdir/wav.scp
echo "$ID global" > $tmpdir/utt2spk
echo "global $ID" > $tmpdir/spk2utt



# 1: from sound to feature
# 1.1 create mffc, stored in fests.scp
compute-mfcc-feats  --use-energy=false --sample-frequency=8000 --verbose=2 scp:$tmpdir/wav.scp ark,scp:$tmpdir/feats.ark,$tmpdir/feats.scp
compute-cmvn-stats --spk2utt=ark:$tmpdir/spk2utt scp:$tmpdir/feats.scp ark,scp:$tmpdir/cmvn.ark,$tmpdir/cmvn.scp

# 1.2 process mffc, apply cmnv, add deltas
feats="ark,s,cs:apply-cmvn $cmvn_opts --utt2spk=ark:$tmpdir/utt2spk scp:$tmpdir/cmvn.scp scp:$tmpdir/feats.scp ark:- | add-deltas $delta_opts ark:- ark:- |"

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



if ! $do_fmllr ; then
    echo "Not do fmllr"
    exit 1
fi


# 3. do fmllr
# the fmllr dir
dir=$tmpdir/fmllr
if [ ! -d $dir ]; then
    mkdir $dir
fi

sifeats=$feats
silence_weight=0.1
final_model=model/final.mdl
alignment_model=$final_model
adapt_model=$final_model
fmllr_update_type=full
silphonelist=`cat $graphdir/phones/silence.csl` || exit 1;


# here outfile is the lattice file
gunzip -c $outfile | \
    lattice-to-post --acoustic-scale=$acwt ark:- ark:- | \
    weight-silence-post $silence_weight $silphonelist $alignment_model ark:- ark:- | \
    gmm-post-to-gpost $alignment_model "$sifeats" ark:- ark:- | \
    gmm-est-fmllr-gpost --fmllr-update-type=$fmllr_update_type \
                        --fmllr-min-count=1 \
                        --spk2utt=ark:$tmpdir/spk2utt $adapt_model "$sifeats" ark,s,cs:- \
                        ark:$dir/pre_trans.JOB || exit 1;


pass1feats="$sifeats transform-feats --utt2spk=ark:$tmpdir/utt2spk ark:$dir/pre_trans.JOB ark:- ark:- |"
gmm-latgen-faster --max-active=$max_active --beam=$beam --lattice-beam=$lattice_beam \
                  --acoustic-scale=$acwt --determinize-lattice=false \
                  --allow-partial=false --word-symbol-table=$graphdir/words.txt $decode_extra_opts \
                  $model $graphdir/HCLG.fst "$feats" "ark:|gzip -c > $outfile" || exit 1;


thread_string=

lattice-determinize-pruned$thread_string --acoustic-scale=$acwt --beam=4.0 \
                                         "ark:gunzip -c $outfile|" ark:- | \
    lattice-to-post --acoustic-scale=$acwt ark:- ark:- | \
    weight-silence-post $silence_weight $silphonelist $adapt_model ark:- ark:- | \
    gmm-est-fmllr --fmllr-update-type=$fmllr_update_type \
                  --spk2utt=ark:$tmpdir/spk2utt \
                  --fmllr-min-count=1 \
                  $adapt_model "$pass1feats" \
                  ark,s,cs:- ark:$dir/trans_tmp.JOB && \
    compose-transforms --b-is-affine=true ark:$dir/trans_tmp.JOB ark:$dir/pre_trans.JOB \
                       ark:$dir/trans.JOB  || exit 1;






post="ark:ali-to-post \"ark:gzip -d -c $tmpdir/ali.gz|\" ark:-|"

gmm-est-fmllr --fmllr-update-type=$fmllr_update_type \
              --spk2utt=ark:$tmpdir/spk2utt \
              --fmllr-min-count=1 \
              $adapt_model "$feats" \
              "$post" ark:$tmpdir/trans.JOB

feats="$sifeats transform-feats --utt2spk=ark:$tmpdir/utt2spk ark:$dir/trans.JOB ark:- ark:- |"

gmm-rescore-lattice $final_model "ark:gunzip -c $outfile|" "$feats" ark:- | \
    lattice-determinize-pruned$thread_string --acoustic-scale=$acwt --beam=$lattice_beam ark:- \
                                             "ark:|gzip -c > $outfile"|| exit 1;
