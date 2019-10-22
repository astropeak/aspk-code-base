
# this file defines data pack variables. this is the interface to the user.

# source kaldi, will setup path so tools could be found
source ~/github/kaldi/setenv.sh

# where the model is in
modeldir=./yesnos5/exp/mono0a

# where the decoding HCLG graph is in
graphdir=./yesnos5/exp/mono0a/graph_tgpr

# parameters
language_model_weight=12
word_insertion_penalty=0.0
