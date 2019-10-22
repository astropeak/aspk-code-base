
# this file defines data pack variables. this is the interface to the user.

# source kaldi, will setup path so tools could be found
source ~/github/kaldi/setenv.sh

# where the model is in
modeldir=./yesnos5/exp/mono0a

# where the decoding HCLG graph is in
graphdir=./yesnos5/exp/mono0a/graph_tgpr

# parameters
# below values are form lattice_to_transcription
language_model_weight=12
word_insertion_penalty=0.0


# below values are from sound_to_lattice
max_active=50000
beam=32
lattice_beam=20
acoustic_weight=0.1
