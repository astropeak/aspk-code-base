#!/bin/bash

source ~/github/kaldi/setenv.sh


lang=~/github/kaldi/egs/yesno/s5/data/lang_test_tg
# this is split data
sdata=~/github/kaldi/egs/yesno/s5/data/test_yesno/split1/1
# this is the model dir
dir=~/github/kaldi/egs/yesno/s5/exp/mono0a

tmpdir=./tmp
outdir=./tmp


export KALDI_ROOT=~/github/kaldi
#copied from path.sh in egs dir
export PATH=~/github/kaldi/egs/wsj/s5/utils:$KALDI_ROOT/tools/openfst/bin:$PATH

oov_sym=`cat $lang/oov.int` || exit 1;

# 这里做的修改是: 要把输入的text文件修改一下, 这个文件是一个ark文件, 每行第一个字段是sound file id, 后面字段是对应的transcription.
# 要生成自己声音文件的ali, 要创建自己的对应的transcription.

# 创建transcription
# text=$sdata/text
text=$tmpdir/text
echo 'wav_ID NO' > $text

# 这个命令的作用是,替换text文件中的词为数字. 2- 表示第二列数据到最后. 因为text 文件中第一列数据为声音文件 的ID, 第二列为词的symbol.
# map-oov 参数指明,如果 在 词/ID表中不存在的词, 用哪个ID. 其中words.txt为词与ID的对应表.
# sym2int.pl --map-oov $oov_sym -f 2- $lang/words.txt < $text
# exit 1

# 创建train graph
# 会为text文件中每个句子创建一个fst.
compile-train-graphs --read-disambig-syms=$lang/phones/disambig.int $dir/tree $dir/final.mdl  $lang/L.fst \
                     "ark:sym2int.pl --map-oov $oov_sym -f 2- $lang/words.txt < $text|" \
                     "ark:|gzip -c >$outdir/train-graphs-fsts.gz" || exit 1;


boost_silence=1.0 # Factor by which to boost silence likelihoods in alignment
beam=10
careful=false
scale_opts="--transition-scale=1.0 --acoustic-scale=0.1 --self-loop-scale=0.1"
mdl="gmm-boost-silence --boost=$boost_silence `cat $lang/phones/optional_silence.csl` $dir/final.mdl - |"
feats="ark,s,cs:apply-cmvn $cmvn_opts --utt2spk=ark:$tmpdir/utt2spk scp:$tmpdir/cmvn.scp scp:$tmpdir/feats.scp ark:- | add-deltas $delta_opts ark:- ark:- |"
gmm-align-compiled $scale_opts --beam=$beam --retry-beam=$[$beam*4] --careful=$careful "$mdl" \
                   "ark:gunzip -c $outdir/train-graphs-fsts.gz|" "$feats" "ark,t:|gzip -c >$outdir/ali.gz" \
    || exit 1;
