# LucaPCycle M2 Training-UID Feature Extraction

This folder contains the staged documentation for LucaPCycle M2 enzyme feature
extraction.

## What Was Extracted

M2 was extracted from protein sequences using LucaPCycle's BPE/subword tokenizer
and trained Transformer `seq_encoder`.

Route:

```text
amino-acid sequence
-> LucaPCycle BPE/subword tokenization
-> LucaPCycle trained Transformer seq_encoder
-> M2 token representation
-> pooled / projected vector features
```

This branch does not load ESM, ESM-C, or ESM2. In the adapted EnzymeCAGE plan,
the paper's M1 branch will be replaced by existing HPC-side ESM-C 600M /
ESM600M features.

## Scope

The current completed extraction covers the training UID set only:

```text
input table:
/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv

training rows:
145,607

unique UniProt IDs extracted:
107,731
```

The complete enzyme sequence pool has 195,743 unique UniProt IDs and has not
yet been extracted in this branch.

## Key Result

```text
output root:
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only

shards:
108 compressed NumPy .npz files

output size:
899M

audit:
FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS
error_count=0
```

## Folder Layout

| Folder | Contents |
|---|---|
| `reports/` | teacher-facing summary, extraction report, output audit, smoke/sample reports |
| `prompts/` | copy-paste HPC prompts used for asset checks, smoke tests, extraction, and audits |
| `plans/` | planning documents and teacher-facing HTML plan |
| `configs/` | environment/setup notes |
| `examples/` | reserved for small example artifacts if needed later |

Start with:

```text
reports/LUCAPCYCLE_M2_TRAINING_UID_RESULT_SUMMARY_FOR_TEACHER_2026-06-25.md
```
