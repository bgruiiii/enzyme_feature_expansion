# Manifest

This manifest maps each included file to its role in the failed LucaPCycle M2
seq-only/vector-only attempt.

## Source Code

| File | Source prompt | Role |
|---|---|---|
| `source_code/audit_scripts/01_asset_check.sh` | `prompts/HPC_LUCAPCYCLE_M2_ASSET_CHECK_PROMPT_2026-06-24.md` | Checks LucaPCycle paths, checkpoint files, BPE/vocab, env imports, and py_compile. |
| `source_code/submit_scripts/02_compute_smoke_submit.sh` | `prompts/HPC_LUCAPCYCLE_M2_COMPUTE_SMOKE_PROMPT_2026-06-24.md` | Submits compute-node smoke job and inspects checkpoint state_dict keys. |
| `source_code/submit_scripts/03_sample10_seq_only_submit.sh` | `prompts/HPC_LUCAPCYCLE_M2_SAMPLE10_EXTRACT_PROMPT_2026-06-24.md` | Generates sample10 Python and sbatch, then submits seq-only extraction. |
| `source_code/python_core/extract_lucapcycle_m2_sample10.py` | Extracted from `03_sample10_seq_only_submit.sh` | Core 10-UID seq-only extraction Python. |
| `source_code/audit_scripts/04_sample10_output_audit.sh` | `prompts/HPC_LUCAPCYCLE_M2_SAMPLE10_OUTPUT_AUDIT_PROMPT_2026-06-25.md` | Audits sample10 structural outputs. |
| `source_code/submit_scripts/05_full_vector_seq_only_submit.sh` | `prompts/HPC_LUCAPCYCLE_M2_FULL_VECTOR_ONLY_PROMPT_2026-06-25.md` | Generates full vector-only Python and sbatch, then submits invalid full run. |
| `source_code/python_core/extract_lucapcycle_m2_full_vector_only.py` | Extracted from `05_full_vector_seq_only_submit.sh` | Core 107,731-UID vector-only extraction Python. |
| `source_code/audit_scripts/06_full_vector_output_audit.sh` | `prompts/HPC_LUCAPCYCLE_M2_FULL_VECTOR_OUTPUT_AUDIT_PROMPT_2026-06-25.md` | Structural audit for the full vector output. |
| `source_code/audit_scripts/07_full_enzyme_input_audit.sh` | `prompts/HPC_LUCAPCYCLE_M2_FULL_ENZYME_INPUT_AUDIT_PROMPT_2026-06-25.md` | Checks the 195,743-UID complete enzyme pool input against current output coverage. |
| `source_code/audit_scripts/08_vector_diversity_audit.sh` | `prompts/HPC_LUCAPCYCLE_M2_VECTOR_DIVERSITY_AUDIT_PROMPT_2026-06-25.md` | Diversity audit that marked vectors invalid. |
| `source_code/audit_scripts/09_failure_diagnosis.sh` | `postmortem/HPC_LUCAPCYCLE_M2_FAILURE_DIAGNOSIS_PROMPT_2026-06-25.md` | Small-sample diagnosis of tokenization and seq branch collapse. |
| `source_code/audit_scripts/10_m2_only_asset_audit.sh` | `postmortem/HPC_LUCAPCYCLE_M2_ONLY_ASSET_AUDIT_PROMPT_2026-06-25.md` | Read-only audit showing no M2-only official route/checkpoint. |
| `source_code/utils/prepare_repro_input.sh` | Added for this GitHub package | Converts included gzip sequence input to a plain CSV accepted by the extraction scripts. |

## Reports

| File | Status / key result |
|---|---|
| `reports/lucapcycle_m2_asset_check_20260624_203846.md` | Required LucaPCycle files present. |
| `reports/lucapcycle_m2_compute_smoke_REPORT.md` | Smoke saw `seq_encoder` and `seq_pooler` keys. Did not test vector diversity. |
| `reports/lucapcycle_m2_sample10_report_115936581.md` | 10-UID seq-only extraction ran. |
| `reports/lucapcycle_m2_sample10_output_audit_20260625_000912.md` | Sample10 structural audit passed. |
| `reports/lucapcycle_m2_full_vector_report_115940591.md` | 107,731 training UIDs extracted by invalid vector-only route. |
| `reports/lucapcycle_m2_full_vector_output_audit_20260625_102103.md` | Structural full-output audit passed. |
| `reports/lucapcycle_m2_full_enzyme_input_audit_20260625_103251.md` | Complete enzyme pool scope checked; full 195,743 was not run. |
| `reports/lucapcycle_m2_vector_diversity_audit_20260625_105636.md` | `VECTOR_DIVERSITY_AUDIT_STATUS=FAIL`. |
| `reports/LUCAPCYCLE_M2_TRAINING_UID_RESULT_SUMMARY_FOR_TEACHER_2026-06-25.md` | Teacher-facing summary of the invalid result. |

## Postmortem

| File | Finding |
|---|---|
| `postmortem/lucapcycle_m2_failure_diagnosis_20260625_153728.md` | Tokenization was not the root cause; seq branch output collapsed. |
| `postmortem/lucapcycle_m2_only_asset_audit_20260625_161823.md` | No official M2-only checkpoint/export route found. |

## Invalid Output Location

The invalid HPC output was:

```text
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
```

This repository does not include the 899M `.npz` output shards. It includes the
source code, prompts, and markdown reports needed to reproduce and audit the
failure.

## Data Included

| File | Contents |
|---|---|
| `data/training_unique_uniprot_sequences_107731.csv.gz` | Deduplicated `UniprotID,sequence` input used by the failed seq-only extraction. |
| `data/training_unique_uniprot_sequences_107731_manifest.md` | Row count, transformation notes, SHA256, and column schema for the gzip input. |

See `REPRODUCIBILITY_REQUIREMENTS.md` for assets not uploaded to GitHub,
including the official LucaPCycle source, checkpoint, ESM/ESM2 weights, and
invalid output shards.
