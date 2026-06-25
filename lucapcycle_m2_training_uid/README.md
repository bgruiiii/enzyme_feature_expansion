# LucaPCycle M2 Training-UID Feature Extraction

This folder contains the staged documentation for LucaPCycle M2 enzyme feature
extraction.

## Status: Invalid Result

This result is **invalid** and must not be used for model training, feature
fusion, or downstream analysis.

What happened:

```text
The extraction route manually used only:
sequence -> BPE/subword tokens -> seq_encoder -> pooled vectors

But the selected LucaPCycle checkpoint is a seq_matrix checkpoint. Official
LucaPCycle logic uses the full model pathway, including matrix/embedding inputs
handled by Encoder and BatchConverter. The manual seq-only branch extraction
therefore did not match the official inference path.
```

Failure evidence:

```text
VECTOR_DIVERSITY_AUDIT_STATUS=FAIL
m2_mean mean_dim_std ~ 3.65e-07
m2_max mean_dim_std ~ 4.20e-07
m2_value_attention mean_dim_std ~ 3.70e-07
m2_projected_256 mean_dim_std ~ 1.47e-07
sample pairwise cosine almost all >= 0.9999
```

The files in this folder are retained only as an audit trail explaining why the
first attempt failed. The next attempt must follow the official LucaPCycle
inference/data-preparation logic and must include a diversity audit before any
full-scale extraction.

## What Was Extracted

This failed attempt extracted vectors from protein sequences using LucaPCycle's
BPE/subword tokenizer and the `seq_encoder` branch.

Route:

```text
amino-acid sequence
-> LucaPCycle BPE/subword tokenization
-> LucaPCycle trained Transformer seq_encoder
-> M2 token representation
-> pooled / projected vector features
```

This was the incorrect assumption for the selected `seq_matrix` checkpoint.
Future runs must first reproduce the official LucaPCycle inference path and only
then decide which intermediate representation can be safely exported.

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

## Invalid Result Location

```text
output root:
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only

shards:
108 compressed NumPy .npz files

output size:
899M

structural audit:
FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS
error_count=0

diversity audit:
VECTOR_DIVERSITY_AUDIT_STATUS=FAIL
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
