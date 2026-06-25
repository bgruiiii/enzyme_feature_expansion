# LucaPCycle M2 Compute-Node Smoke Test

Date: 2026年 06月 24日 星期三 20:49:18 CST
Host: f13r4n00
SLURM_JOB_ID: 115927754

## 1. Module And Environment

Loaded modules:
Currently Loaded Modulefiles:
  1) compiler/devtoolset/7.3.1   3) compiler/rocm/dtk-22.10.1
  2) mpi/hpcx/2.11.0/gcc-7.3.1   4) compiler/rocm/dtk-23.10

python: /public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/python
Python 3.9.23

## 2. Torch Runtime Check

python_executable: /public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/python
torch_import: OK
torch_version: 1.13.1
torch_cuda_is_available: True
torch_cuda_device_count: 1
torch_device_0_name: Z200SM_71_S

## 3. Checkpoint Load And State Dict Inspection

checkpoint_dir: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
model_path: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/pytorch_model.bin
model_size_bytes: 378348333
loaded_object_type: dict
state_dict_source: raw_dict
state_dict_key_count: 84
first_30_keys:
   seq_encoder.embeddings.word_embeddings.weight
   seq_encoder.embeddings.LayerNorm.weight
   seq_encoder.embeddings.LayerNorm.bias
   seq_encoder.encoder.layer.0.attention.self.RoPE.inv_freq
   seq_encoder.encoder.layer.0.attention.self.query.weight
   seq_encoder.encoder.layer.0.attention.self.query.bias
   seq_encoder.encoder.layer.0.attention.self.key.weight
   seq_encoder.encoder.layer.0.attention.self.key.bias
   seq_encoder.encoder.layer.0.attention.self.value.weight
   seq_encoder.encoder.layer.0.attention.self.value.bias
   seq_encoder.encoder.layer.0.attention.output.dense.weight
   seq_encoder.encoder.layer.0.attention.output.dense.bias
   seq_encoder.encoder.layer.0.attention.output.LayerNorm.weight
   seq_encoder.encoder.layer.0.attention.output.LayerNorm.bias
   seq_encoder.encoder.layer.0.intermediate.dense.weight
   seq_encoder.encoder.layer.0.intermediate.dense.bias
   seq_encoder.encoder.layer.0.output.dense.weight
   seq_encoder.encoder.layer.0.output.dense.bias
   seq_encoder.encoder.layer.0.output.LayerNorm.weight
   seq_encoder.encoder.layer.0.output.LayerNorm.bias
   seq_encoder.encoder.layer.1.attention.self.RoPE.inv_freq
   seq_encoder.encoder.layer.1.attention.self.query.weight
   seq_encoder.encoder.layer.1.attention.self.query.bias
   seq_encoder.encoder.layer.1.attention.self.key.weight
   seq_encoder.encoder.layer.1.attention.self.key.bias
   seq_encoder.encoder.layer.1.attention.self.value.weight
   seq_encoder.encoder.layer.1.attention.self.value.bias
   seq_encoder.encoder.layer.1.attention.output.dense.weight
   seq_encoder.encoder.layer.1.attention.output.dense.bias
   seq_encoder.encoder.layer.1.attention.output.LayerNorm.weight
match_count[seq_encoder]: 71
  seq_encoder.embeddings.word_embeddings.weight: (19988, 1024)
  seq_encoder.embeddings.LayerNorm.weight: (1024,)
  seq_encoder.embeddings.LayerNorm.bias: (1024,)
  seq_encoder.encoder.layer.0.attention.self.RoPE.inv_freq: (64,)
  seq_encoder.encoder.layer.0.attention.self.query.weight: (1024, 1024)
  seq_encoder.encoder.layer.0.attention.self.query.bias: (1024,)
  seq_encoder.encoder.layer.0.attention.self.key.weight: (1024, 1024)
  seq_encoder.encoder.layer.0.attention.self.key.bias: (1024,)
  seq_encoder.encoder.layer.0.attention.self.value.weight: (1024, 1024)
  seq_encoder.encoder.layer.0.attention.self.value.bias: (1024,)
match_count[seq_pooler]: 3
  seq_pooler.U: (1024, 1024)
  seq_pooler.V: (1024, 1024)
  seq_pooler.W: (1024, 1024)
match_count[seq_linear]: 2
  seq_linear.0.weight: (256, 1024)
  seq_linear.0.bias: (256,)
match_count[embedding]: 8
  seq_encoder.embeddings.word_embeddings.weight: (19988, 1024)
  seq_encoder.embeddings.LayerNorm.weight: (1024,)
  seq_encoder.embeddings.LayerNorm.bias: (1024,)
  embedding_pooler.U: (2560, 2560)
  embedding_pooler.V: (2560, 2560)
  embedding_pooler.W: (2560, 2560)
  embedding_linear.0.weight: (256, 2560)
  embedding_linear.0.bias: (256,)
match_count[classifier]: 2
  classifier.weight: (1, 512)
  classifier.bias: (1,)
SMOKE_STATUS=PASS_SEQ_ENCODER_KEYS_PRESENT

config_summary:
hidden_size: 1024
num_hidden_layers: 4
num_attention_heads: 8
vocab_size: 19988
seq_fc_size: [256]
seq_pooling_type: value_attention
seq_max_length: 3072
input_type: None
embedding_input_size: 2560

## 4. Final Boundary

No M2 extraction was run.
No ESM/ESM-C/ESM2 model was loaded.
Wait for local review before the next step.
