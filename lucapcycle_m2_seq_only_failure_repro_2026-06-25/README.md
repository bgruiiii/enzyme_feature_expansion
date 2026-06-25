# LucaPCycle M2 Seq-Only Failure Reproduction Package

Date: 2026-06-25

This folder contains the complete audit trail and runnable source code for the
failed LucaPCycle M2 seq-only/vector-only extraction attempt.

Important status:

```text
RESULT_STATUS=INVALID
DO_NOT_USE_FOR_TRAINING=yes
DO_NOT_USE_FOR_FEATURE_FUSION=yes
DO_NOT_EXPAND_TO_195743=yes
```

## What This Package Reproduces

The failed route manually extracted only the sequence branch from a LucaPCycle
`seq_matrix` checkpoint:

```text
amino-acid sequence
-> LucaPCycle BPE/subword tokenization
-> model.seq_encoder(...)
-> seq_pooler / mean / max / projection
-> vector-only M2-like features
```

This route was later shown to be wrong for the selected checkpoint. The
checkpoint is a full `seq_matrix` dual-channel checkpoint, while the official
LucaPCycle route uses both sequence inputs and ESM-derived matrix inputs.

## Fixed HPC Paths Used

```text
CODE_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
CKPT_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint
ENV=/public/home/acfbwjsi7s/envs/lucapcycle_m2
BIN_CKPT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
BPE_CODES=/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword/extra_p/extra_p_50_codes_20000.txt
TRAINING_TABLE=/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
INVALID_OUT=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
```

Training-table scope:

```text
training rows: 145,607
unique training UniProt IDs extracted: 107,731
complete enzyme pool target was not run: 195,743 unique UniProt IDs
```

## Folder Layout

| Path | Purpose |
|---|---|
| `source_code/` | Runnable shell/Python source reconstructed from the submitted HPC prompts. |
| `prompts/` | Original copy-paste HPC prompts used during the run. |
| `reports/` | HPC-returned reports from asset checks, smoke/sample/full extraction, and audits. |
| `postmortem/` | Diagnosis and asset audit proving why the seq-only result is invalid. |
| `plans/` | Original planning documents that led to the seq-only route. |
| `configs/` | Environment setup notes. |
| `data/` | Deduplicated 107,731-UID sequence input used by the failed extraction. |

For official source/checkpoint download links and assets that are too large for
GitHub, see:

```text
REPRODUCIBILITY_REQUIREMENTS.md
```

## Source Code Index

The most important files are:

| File | What it does |
|---|---|
| `source_code/python_core/extract_lucapcycle_m2_sample10.py` | Core Python used for the 10-UID seq-only extraction. Calls `model.seq_encoder(...)`. |
| `source_code/python_core/extract_lucapcycle_m2_full_vector_only.py` | Core Python used for the 107,731-UID vector-only extraction. Calls `model.seq_encoder(...)`. |
| `source_code/submit_scripts/03_sample10_seq_only_submit.sh` | Generates and submits the 10-UID sample extraction job. |
| `source_code/submit_scripts/05_full_vector_seq_only_submit.sh` | Generates and submits the full training-UID vector-only extraction job. This is the invalid full run. |
| `source_code/audit_scripts/08_vector_diversity_audit.sh` | Diversity audit that failed the produced vectors. |
| `source_code/audit_scripts/09_failure_diagnosis.sh` | Small-sample diagnosis showing official tokenization matched manual tokenization, but the seq branch still collapsed. |
| `source_code/audit_scripts/10_m2_only_asset_audit.sh` | Read-only audit showing no M2-only/seq-only official checkpoint or export route was present. |

## Original Run Order

The actual sequence was:

1. Asset/environment check:
   `source_code/audit_scripts/01_asset_check.sh`
2. Compute-node smoke:
   `source_code/submit_scripts/02_compute_smoke_submit.sh`
3. 10-UID seq-only extraction:
   `source_code/submit_scripts/03_sample10_seq_only_submit.sh`
4. 10-UID output structural audit:
   `source_code/audit_scripts/04_sample10_output_audit.sh`
5. Full training-UID vector-only extraction:
   `source_code/submit_scripts/05_full_vector_seq_only_submit.sh`
6. Full vector structural audit:
   `source_code/audit_scripts/06_full_vector_output_audit.sh`
7. Full enzyme input audit:
   `source_code/audit_scripts/07_full_enzyme_input_audit.sh`
8. Vector diversity audit:
   `source_code/audit_scripts/08_vector_diversity_audit.sh`
9. Failure diagnosis:
   `source_code/audit_scripts/09_failure_diagnosis.sh`
10. M2-only asset audit:
   `source_code/audit_scripts/10_m2_only_asset_audit.sh`

## Observed Results

Structural output audit passed:

```text
FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS
total_rows_across_shards=107731
failed_uids_rows=0
```

Diversity audit failed:

```text
VECTOR_DIVERSITY_AUDIT_STATUS=FAIL
m2_mean mean_dim_std ~ 3.65e-07
m2_max mean_dim_std ~ 4.20e-07
m2_value_attention mean_dim_std ~ 3.70e-07
m2_projected_256 mean_dim_std ~ 1.47e-07
sample pairwise cosine almost all >= 0.9999
```

Diagnosis confirmed:

```text
manual_vs_official_ids_equal=True
manual_global_unk_ratio_nonpad=0.0432183908045977
official_global_unk_ratio_nonpad=0.0432183908045977
embedding before Transformer is diverse
M2/seq branch after Transformer collapses even with official BatchConverter
```

Asset audit confirmed:

```text
M2_ONLY_ASSET_AUDIT_STATUS=NO_M2_ONLY_FOUND
m2_only_checkpoint_paths=none
official_m2_only_export_entrypoint=none
requires_esm_or_matrix_for_official_prediction=yes
recommendation=do not run
```

## Root Cause

This was not primarily a bad input-table issue and not a BPE/tokenizer mismatch.
The small-sample diagnosis showed manual tokenization matched official
`BatchConverter` tokenization.

The error was the extraction design:

```text
Wrong assumption:
The sequence branch inside a seq_matrix checkpoint can be exported as standalone
M2 features.

Observed reality:
The standalone seq branch collapses numerically. Current official assets contain
only seq_matrix checkpoints, not an M2-only/seq-only checkpoint or export route.
```

## Reproduction Warning

The scripts are included so the teacher can reproduce and audit the failure.
They should not be used to generate accepted enzyme features.

If rerun, run only in a controlled reproduction context and stop after the
diagnostic/audit stages. Do not use `INVALID_OUT` as a training feature source.
