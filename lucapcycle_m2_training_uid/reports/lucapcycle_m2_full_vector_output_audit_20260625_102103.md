# LucaPCycle M2 Full Vector Output Audit

Date: 2026年 06月 25日 星期四 10:21:03 CST
Host: login03
OUT_ROOT=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
JOB_ID=115940591

## 1. Boundary

Read-only output audit.
No model extraction is run.
No training is run.
No ESM/ESM-C/ESM2 model is loaded.
No token-level matrix extraction is run.

## 2. Required File Checks

OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/README.md
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 170 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/README.md
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/extraction_config.json
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 642 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/extraction_config.json
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/input_uid_sequence_manifest.csv
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 44M 6月  25 00:54 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/input_uid_sequence_manifest.csv
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/uid_to_shard.csv
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 12M 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/uid_to_shard.csv
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/audit_summary.json
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 741 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/audit_summary.json
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/logs/lucapcycle_m2_full_vector_report_115940591.md
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 23K 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/logs/lucapcycle_m2_full_vector_report_115940591.md
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/logs/lucapcycle_m2_full_vector_115940591.out
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 23K 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/logs/lucapcycle_m2_full_vector_115940591.out
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/logs/lucapcycle_m2_full_vector_115940591.err
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 0 6月  25 00:53 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/logs/lucapcycle_m2_full_vector_115940591.err
missing_required_file_count=0

## 3. Log Error Check

RUN_ERR_BYTES=0
RUN_ERR is empty.

## 4. Output Directory Size

899M	/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only

Top-level files:
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/audit_summary.json	1 KB
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/extraction_config.json	1 KB
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/extract_lucapcycle_m2_full_vector_only.py	17 KB
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/input_uid_sequence_manifest.csv	44551 KB
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/lucapcycle_m2_full_vector_only.sbatch	4 KB
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/README.md	1 KB
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/uid_to_shard.csv	12125 KB

## 5. Token Matrix Absence Check

These matches are informational. token_count fields are expected metadata; token-level matrix files/directories should not exist.

## 6. Python Structure Audit

### 6.1 Summary JSON
FULL_VECTOR_STATUS: PASS
input_csv: /public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
out_root: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
total_unique_input: 107731
completed_total: 107731
failed_total: 0
shard_file_count: 108
batch_size: 4
shard_size: 1000
elapsed_seconds: 2110.67
device: cuda
torch_version: 1.13.1
torch_cuda_is_available: True
filtered_allowed_keys: ['loss_fct.pos_weight']
token_matrix_saved: False

### 6.2 Extraction Config
model: LucaPCycle V3 binary-class lucaprot seq_matrix checkpoint-264284
outputs: ['m2_mean', 'm2_max', 'm2_value_attention', 'm2_projected_256']
token_matrix_saved: False
code_root: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
bin_ckpt: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
bpe_codes: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword/extra_p/extra_p_50_codes_20000.txt

### 6.3 Manifest Checks
input_manifest_rows: 107731
input_manifest_unique_uid: 107731
uid_to_shard_rows: 107731
uid_to_shard_unique_uid: 107731
uid_to_shard_duplicate_uid_count: 0
uids_missing_from_uid_to_shard: 0
uids_extra_in_uid_to_shard: 0
uid_to_shard_columns: ['uid', 'shard_file', 'row_in_shard', 'sequence_sha256', 'sequence_length', 'bpe_token_count_without_special', 'token_count_with_special']
uid_to_shard_missing_columns: []

### 6.4 Failed UID Check
failed_uids_file_exists: false
failed_uids_rows: 0

### 6.5 Shard File Checks
shard_count: 108
shard_index_min: 0
shard_index_max: 107
shard_indices_contiguous_0_based: True
  checked 30/108 shards...
  checked 60/108 shards...
  checked 90/108 shards...
total_rows_across_shards: 107731
row_count_min: 731
row_count_max: 1000
row_count_last: 731
row_count_distribution: {731: 1, 1000: 107}

### 6.6 Feature Global Sample Stats Across All Shards
m2_mean: global_min=-4.843450, global_max=5.140354, mean_of_shard_means=0.001064
m2_max: global_min=-4.843445, global_max=5.140360, mean_of_shard_means=0.001066
m2_value_attention: global_min=-4.843450, global_max=5.140351, mean_of_shard_means=0.001064
m2_projected_256: global_min=-1.000000, global_max=1.000000, mean_of_shard_means=-0.045595

### 6.7 Selected Shard Data Structure Examples
{
  "m2_vectors_part_000000.npz": {
    "keys": [
      "bpe_token_count_without_special",
      "m2_max",
      "m2_mean",
      "m2_projected_256",
      "m2_value_attention",
      "sequence_length",
      "sequence_sha256",
      "token_count_with_special",
      "uid"
    ],
    "rows": 1000,
    "uid_dtype": "<U10",
    "sequence_length_dtype": "int64",
    "feature_shapes": {
      "m2_mean": [
        1000,
        1024
      ],
      "m2_max": [
        1000,
        1024
      ],
      "m2_value_attention": [
        1000,
        1024
      ],
      "m2_projected_256": [
        1000,
        256
      ]
    },
    "feature_dtypes": {
      "m2_mean": "float32",
      "m2_max": "float32",
      "m2_value_attention": "float32",
      "m2_projected_256": "float32"
    },
    "first_three_records": [
      {
        "row": 0,
        "uid": "P08159",
        "sequence_length": 458,
        "bpe_token_count_without_special": 162,
        "token_count_with_special": 164,
        "sequence_sha256_prefix": "0ec9d6db6ae59c67",
        "m2_mean_first5": [
          0.009833,
          0.007452,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_value_attention_first5": [
          0.009833,
          0.007452,
          0.4918,
          -2.422861,
          0.598321
        ],
        "m2_projected_256_first5": [
          1.0,
          -1.0,
          -0.999998,
          -1.0,
          0.999995
        ],
        "m2_mean_l2_norm": 28.104158,
        "m2_value_attention_l2_norm": 28.104149,
        "m2_projected_256_l2_norm": 13.709576
      },
      {
        "row": 1,
        "uid": "P38999",
        "sequence_length": 446,
        "bpe_token_count_without_special": 165,
        "token_count_with_special": 167,
        "sequence_sha256_prefix": "bec2b765e3d60d9b",
        "m2_mean_first5": [
          0.009833,
          0.007452,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_value_attention_first5": [
          0.009833,
          0.007452,
          0.491801,
          -2.422861,
          0.598321
        ],
        "m2_projected_256_first5": [
          1.0,
          -1.0,
          -0.999998,
          -1.0,
          0.999995
        ],
        "m2_mean_l2_norm": 28.104158,
        "m2_value_attention_l2_norm": 28.104149,
        "m2_projected_256_l2_norm": 13.709576
      },
      {
        "row": 2,
        "uid": "O59711",
        "sequence_length": 450,
        "bpe_token_count_without_special": 166,
        "token_count_with_special": 168,
        "sequence_sha256_prefix": "b3dc7fcb050c0020",
        "m2_mean_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_value_attention_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422861,
          0.59832
        ],
        "m2_projected_256_first5": [
          1.0,
          -1.0,
          -0.999998,
          -1.0,
          0.999995
        ],
        "m2_mean_l2_norm": 28.104158,
        "m2_value_attention_l2_norm": 28.104149,
        "m2_projected_256_l2_norm": 13.709576
      }
    ]
  },
  "m2_vectors_part_000054.npz": {
    "keys": [
      "bpe_token_count_without_special",
      "m2_max",
      "m2_mean",
      "m2_projected_256",
      "m2_value_attention",
      "sequence_length",
      "sequence_sha256",
      "token_count_with_special",
      "uid"
    ],
    "rows": 1000,
    "uid_dtype": "<U10",
    "sequence_length_dtype": "int64",
    "feature_shapes": {
      "m2_mean": [
        1000,
        1024
      ],
      "m2_max": [
        1000,
        1024
      ],
      "m2_value_attention": [
        1000,
        1024
      ],
      "m2_projected_256": [
        1000,
        256
      ]
    },
    "feature_dtypes": {
      "m2_mean": "float32",
      "m2_max": "float32",
      "m2_value_attention": "float32",
      "m2_projected_256": "float32"
    },
    "first_three_records": [
      {
        "row": 0,
        "uid": "Q9WZ22",
        "sequence_length": 538,
        "bpe_token_count_without_special": 195,
        "token_count_with_special": 197,
        "sequence_sha256_prefix": "66c72c4b445b0824",
        "m2_mean_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_value_attention_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422861,
          0.59832
        ],
        "m2_projected_256_first5": [
          1.0,
          -1.0,
          -0.999998,
          -1.0,
          0.999995
        ],
        "m2_mean_l2_norm": 28.104158,
        "m2_value_attention_l2_norm": 28.104149,
        "m2_projected_256_l2_norm": 13.709576
      },
      {
        "row": 1,
        "uid": "P74269",
        "sequence_length": 547,
        "bpe_token_count_without_special": 196,
        "token_count_with_special": 198,
        "sequence_sha256_prefix": "b2835a02501dd5c4",
        "m2_mean_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_value_attention_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422861,
          0.598321
        ],
        "m2_projected_256_first5": [
          1.0,
          -1.0,
          -0.999998,
          -1.0,
          0.999995
        ],
        "m2_mean_l2_norm": 28.104158,
        "m2_value_attention_l2_norm": 28.104149,
        "m2_projected_256_l2_norm": 13.709576
      },
      {
        "row": 2,
        "uid": "Q9RPW4",
        "sequence_length": 132,
        "bpe_token_count_without_special": 47,
        "token_count_with_special": 49,
        "sequence_sha256_prefix": "476ec4b2799e785c",
        "m2_mean_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_value_attention_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_projected_256_first5": [
          1.0,
          -1.0,
          -0.999998,
          -1.0,
          0.999995
        ],
        "m2_mean_l2_norm": 28.104158,
        "m2_value_attention_l2_norm": 28.104153,
        "m2_projected_256_l2_norm": 13.709576
      }
    ]
  },
  "m2_vectors_part_000107.npz": {
    "keys": [
      "bpe_token_count_without_special",
      "m2_max",
      "m2_mean",
      "m2_projected_256",
      "m2_value_attention",
      "sequence_length",
      "sequence_sha256",
      "token_count_with_special",
      "uid"
    ],
    "rows": 731,
    "uid_dtype": "<U10",
    "sequence_length_dtype": "int64",
    "feature_shapes": {
      "m2_mean": [
        731,
        1024
      ],
      "m2_max": [
        731,
        1024
      ],
      "m2_value_attention": [
        731,
        1024
      ],
      "m2_projected_256": [
        731,
        256
      ]
    },
    "feature_dtypes": {
      "m2_mean": "float32",
      "m2_max": "float32",
      "m2_value_attention": "float32",
      "m2_projected_256": "float32"
    },
    "first_three_records": [
      {
        "row": 0,
        "uid": "Q60099",
        "sequence_length": 253,
        "bpe_token_count_without_special": 92,
        "token_count_with_special": 94,
        "sequence_sha256_prefix": "58d2d368ffdd947a",
        "m2_mean_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_value_attention_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422861,
          0.59832
        ],
        "m2_projected_256_first5": [
          1.0,
          -1.0,
          -0.999998,
          -1.0,
          0.999995
        ],
        "m2_mean_l2_norm": 28.104158,
        "m2_value_attention_l2_norm": 28.104151,
        "m2_projected_256_l2_norm": 13.709576
      },
      {
        "row": 1,
        "uid": "P72542",
        "sequence_length": 292,
        "bpe_token_count_without_special": 104,
        "token_count_with_special": 106,
        "sequence_sha256_prefix": "9929e807b229dc82",
        "m2_mean_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_value_attention_first5": [
          0.009833,
          0.007453,
          0.491801,
          -2.422861,
          0.598321
        ],
        "m2_projected_256_first5": [
          1.0,
          -1.0,
          -0.999998,
          -1.0,
          0.999995
        ],
        "m2_mean_l2_norm": 28.104158,
        "m2_value_attention_l2_norm": 28.104151,
        "m2_projected_256_l2_norm": 13.709576
      },
      {
        "row": 2,
        "uid": "Q3ZAB8",
        "sequence_length": 554,
        "bpe_token_count_without_special": 212,
        "token_count_with_special": 214,
        "sequence_sha256_prefix": "c1b57060a55f82e0",
        "m2_mean_first5": [
          0.009833,
          0.007452,
          0.491801,
          -2.422862,
          0.598321
        ],
        "m2_value_attention_first5": [
          0.009833,
          0.007452,
          0.4918,
          -2.422861,
          0.59832
        ],
        "m2_projected_256_first5": [
          1.0,
          -1.0,
          -0.999998,
          -1.0,
          0.999995
        ],
        "m2_mean_l2_norm": 28.104158,
        "m2_value_attention_l2_norm": 28.104147,
        "m2_projected_256_l2_norm": 13.709576
      }
    ]
  }
}

### 6.8 Teacher-Facing Feature Schema
{
  "file_format": "compressed NumPy .npz shard",
  "shard_count": 108,
  "rows_total": 107731,
  "rows_per_full_shard": 1000,
  "last_shard_rows": 731,
  "keys": [
    "uid",
    "sequence_sha256",
    "sequence_length",
    "bpe_token_count_without_special",
    "token_count_with_special",
    "m2_mean",
    "m2_max",
    "m2_value_attention",
    "m2_projected_256"
  ],
  "features": {
    "m2_mean": "float32, shape (N, 1024), masked mean pooling over LucaPCycle seq_encoder token representations",
    "m2_max": "float32, shape (N, 1024), masked max pooling over LucaPCycle seq_encoder token representations",
    "m2_value_attention": "float32, shape (N, 1024), LucaPCycle configured value_attention seq_pooler output",
    "m2_projected_256": "float32, shape (N, 256), value_attention pooled vector after LucaPCycle seq_linear projection"
  },
  "metadata": {
    "uid": "UniProt ID string array, shape (N,)",
    "sequence_sha256": "sequence hash for consistency checking, shape (N,)",
    "sequence_length": "original amino-acid sequence length, int64, shape (N,)",
    "bpe_token_count_without_special": "BPE token count before CLS/SEP, int64, shape (N,)",
    "token_count_with_special": "BPE token count plus CLS/SEP, int64, shape (N,)"
  }
}

### 6.9 Final Audit Status
FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS
error_count: 0

## 7. Final Boundary

Read-only audit finished.
No extraction was run.
No training was run.
No ESM/ESM-C/ESM2 model was loaded.

AUDIT_REPORT_WRITTEN=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/logs/lucapcycle_m2_full_vector_output_audit_20260625_102103.md
