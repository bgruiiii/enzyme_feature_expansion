# Source Code

This directory contains runnable source extracted from the original HPC prompts.
The original prompts are preserved in `../prompts/` and `../postmortem/`.

## Directories

| Directory | Contents |
|---|---|
| `submit_scripts/` | Shell scripts that create Python/sbatch files and submit jobs. |
| `python_core/` | Core Python extraction code separated out for review. |
| `audit_scripts/` | Read-only or post-run audit scripts. |
| `utils/` | Small helpers for preparing included repro data. |

## Core Mistake To Inspect

The invalid route is visible in:

```text
python_core/extract_lucapcycle_m2_sample10.py
python_core/extract_lucapcycle_m2_full_vector_only.py
```

Both call:

```python
seq_outputs = model.seq_encoder(...)
m2 = seq_outputs[0]
```

This bypassed the full official LucaPCycle `seq_matrix` route.

## Safe Review Order

For source review, start with:

1. `python_core/extract_lucapcycle_m2_full_vector_only.py`
2. `audit_scripts/08_vector_diversity_audit.sh`
3. `audit_scripts/09_failure_diagnosis.sh`
4. `audit_scripts/10_m2_only_asset_audit.sh`

The full extraction script is provided only to reproduce the failure. It is not
a recommended rerun path.

## Included Input Data Helper

To convert the included gzip input into a plain CSV usable by the extraction
scripts:

```bash
source_code/utils/prepare_repro_input.sh \
  ../data/training_unique_uniprot_sequences_107731.csv.gz \
  /tmp/lucapcycle_m2_repro/reaction_enzyme_pairs.csv
```

Then point `--input_csv` or the submit script candidate path at that generated
CSV. The extraction code only requires `UniprotID` and `sequence`; the extra
`sequence_length` and `sequence_sha256` columns are harmless.
