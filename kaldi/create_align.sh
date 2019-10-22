#!/bin/bash

# create aligemnet files
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <datadir> <outdir>"
    echo "  eg. $0 ./data/fmllr ./tmp"
    echo "  the <datadir> should contains: wav.scp, text, spk2utt, utt2spk"
    echo "  the result alignment file is in <outdir> named ali.gz"
    exit 1
fi


source datapack.sh


datadir=$1
outdir=$2


# 1. create feature, from sound to feature
# 1.1 create mffc, stored in fests.scp
compute-mfcc-feats  --use-energy=false --sample-frequency=8000 --verbose=2 scp:$datadir/wav.scp ark,scp:$outdir/feats.ark,$outdir/feats.scp
compute-cmvn-stats --spk2utt=ark:$datadir/spk2utt scp:$outdir/feats.scp ark,scp:$outdir/cmvn.ark,$outdir/cmvn.scp
# 1.2 process mffc, apply cmnv, add deltas
feats="ark,s,cs:apply-cmvn $cmvn_opts --utt2spk=ark:$datadir/utt2spk scp:$outdir/cmvn.scp scp:$outdir/feats.scp ark:- | add-deltas $delta_opts ark:- ark:- |"


# 2. create train graph
oov_sym=`cat $langdir/oov.int` || exit 1;

# 这里做的修改是: 要把输入的text文件修改一下, 这个文件是一个ark文件, 每行第一个字段是sound file id, 后面字段是对应的transcription.
# 要生成自己声音文件的ali, 要创建自己的对应的transcription.

# 这个命令的作用是,替换text文件中的词为数字. 2- 表示第二列数据到最后. 因为text 文件中第一列数据为声音文件 的ID, 第二列为词的symbol.
# map-oov 参数指明,如果 在 词/ID表中不存在的词, 用哪个ID. 其中words.txt为词与ID的对应表.
# sym2int.pl --map-oov $oov_sym -f 2- $langdir/words.txt < $text
# exit 1

# 创建train graph
# 会为text文件中每个句子创建一个fst.
compile-train-graphs --read-disambig-syms=$langdir/phones/disambig.int $modeldir/tree $modeldir/final.mdl  $langdir/L.fst \
                     "ark:sym2int.pl --map-oov $oov_sym -f 2- $langdir/words.txt < $datadir/text|" \
                     "ark:|gzip -c >$outdir/train-graphs-fsts.gz" || exit 1;


# 3. create alignment file
boost_silence=1.0 # Factor by which to boost silence likelihoods in alignment
beam=10
careful=false
scale_opts="--transition-scale=1.0 --acoustic-scale=0.1 --self-loop-scale=0.1"
mdl="gmm-boost-silence --boost=$boost_silence `cat $langdir/phones/optional_silence.csl` $modeldir/final.mdl - |"
gmm-align-compiled $scale_opts --beam=$beam --retry-beam=$[$beam*4] --careful=$careful "$mdl" \
                   "ark:gunzip -c $outdir/train-graphs-fsts.gz|" "$feats" "ark,t:|gzip -c >$outdir/ali.gz" \
    || exit 1;
