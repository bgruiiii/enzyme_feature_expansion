# LucaPCycle M2 Asset Check

Date: 2026年 06月 24日 星期三 20:38:46 CST
Host: login03

## 1. Path Summary

```text
CODE_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
CKPT_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint
ENV=/public/home/acfbwjsi7s/envs/lucapcycle_m2
BIN_CKPT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
MC_CKPT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250
```

## 2. Directory Checks

OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
drwxr-xr-x 10 acfbwjsi7s acfbwjsi7s 4096 6月  24 18:49 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src
drwxr-xr-x 8 acfbwjsi7s acfbwjsi7s 4096 6月  24 18:49 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword
drwxr-xr-x 6 acfbwjsi7s acfbwjsi7s 4096 6月  24 18:49 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/vocab
drwxr-xr-x 6 acfbwjsi7s acfbwjsi7s 4096 6月  24 18:49 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/vocab
OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint
drwxr-xr-x 4 acfbwjsi7s acfbwjsi7s 4096 6月  24 18:49 /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint
OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
drwxr-xr-x 4 acfbwjsi7s acfbwjsi7s 4096 6月  24 18:56 /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
OK: /public/home/acfbwjsi7s/envs/lucapcycle_m2
drwxrwxr-x 5 acfbwjsi7s acfbwjsi7s 4096 6月  24 18:19 /public/home/acfbwjsi7s/envs/lucapcycle_m2

## 3. Required File Checks

OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/README.md
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 13K 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/README.md
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/requirements.txt
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 1016 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/requirements.txt
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/prediction_v2.py
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 38K 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/prediction_v2.py
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/inference.py
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 13K 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/inference.py
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/lucaprot/models/lucaprot.py
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 32K 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/lucaprot/models/lucaprot.py
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 88K 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 33K 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 32K 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword/extra_p/extra_p_50_codes_20000.txt
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 114K 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword/extra_p/extra_p_50_codes_20000.txt
OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/vocab/extra_p/extra_p_50_subword_vocab_20000.txt
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 94K 6月  24 16:59 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/vocab/extra_p/extra_p_50_subword_vocab_20000.txt
OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/config.json
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 1.9K 1月  17 2025 /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/config.json
OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/pytorch_model.bin
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 361M 1月  17 2025 /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/pytorch_model.bin
OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/training_args.bin
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 4.9K 1月  17 2025 /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/training_args.bin
OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/tokenizer/special_tokens_map.json
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 125 1月  17 2025 /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/tokenizer/special_tokens_map.json
OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/tokenizer/tokenizer_config.json
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 395 1月  17 2025 /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/tokenizer/tokenizer_config.json
OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/tokenizer/vocab.txt
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 95K 1月  17 2025 /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/tokenizer/vocab.txt

Missing required file count: 0

## 4. Optional 31-class Checkpoint Check

OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/config.json
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/dev_metrics.txt
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/pytorch_model.bin
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/test_metrics.txt
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/tokenizer/special_tokens_map.json
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/tokenizer/tokenizer_config.json
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/tokenizer/vocab.txt
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/training_args.bin

## 5. Checkpoint Config Summary

hidden_size: 1024
num_hidden_layers: 4
num_attention_heads: 8
vocab_size: 19988
seq_fc_size: [256]
seq_pooling_type: value_attention
seq_max_length: 3072
input_type: None
embedding_input_size: 2560

## 6. BPE/Vocab Line Counts

/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword/extra_p/extra_p_50_codes_20000.txt
20001 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword/extra_p/extra_p_50_codes_20000.txt
#version: 0.2
A A
L L
---
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/vocab/extra_p/extra_p_50_subword_vocab_20000.txt
19978 /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/vocab/extra_p/extra_p_50_subword_vocab_20000.txt
[PAD]
[UNK]
[CLS]
---
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/tokenizer/vocab.txt
19988 /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/tokenizer/vocab.txt
[PAD]
[UNK]
[CLS]
---

## 7. Environment Non-Torch Import Check

python 3.9.23 (main, Jun  5 2025, 13:40:20) 
[GCC 11.2.0]
OK numpy 1.26.4
OK pandas 2.0.3
OK transformers 4.29.0
OK tokenizers 0.13.2
OK subword_nmt version_not_reported
OK sklearn 1.6.1
OK scipy 1.12.0
OK tqdm 4.68.3
OK Bio 1.80
OK h5py 3.14.0

## 8. Torch Login-Node Check

Torch may fail on login node; this is informational only.
torch import failed on this node: ImportError('/public/home/acfbwjsi7s/miniconda3/envs/nis/lib/python3.9/site-packages/torch/lib/libtorch_cpu.so: symbol roctracer_next_record, version HIP not defined in file libgalaxyhip.so.5 with link time reference')

## 9. py_compile Checks

py_compile: src/prediction_v2.py
OK_COMPILE: src/prediction_v2.py
py_compile: src/inference.py
OK_COMPILE: src/inference.py
py_compile: src/lucaprot/models/lucaprot.py
OK_COMPILE: src/lucaprot/models/lucaprot.py
py_compile: src/common/modeling_bert.py
OK_COMPILE: src/common/modeling_bert.py
py_compile: src/batch_converter.py
OK_COMPILE: src/batch_converter.py
py_compile: src/encoder.py
OK_COMPILE: src/encoder.py

## 10. Final Status

ASSET_CHECK_STATUS=PASS_REQUIRED_FILES_PRESENT

Do not proceed to extraction until this report is reviewed.
