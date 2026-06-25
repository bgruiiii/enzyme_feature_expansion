# Enzyme Feature Expansion

This repository collects staged reports, reproducibility prompts, and audit
records for enzyme feature expansion experiments.

## Critical Status Notice

The current LucaPCycle M2 training-UID result is **INVALID** and must not be
used for training or downstream analysis.

Reason:

```text
The vector-only extraction did not follow LucaPCycle's official complete
seq_matrix inference path. It extracted only the sequence branch from the
seq_matrix checkpoint, while the official model logic also uses the
matrix/embedding branch. A subsequent diversity audit showed vector collapse:
pairwise cosine similarities were almost all >= 0.9999.
```

The uploaded reports are kept only as an audit trail and failure record. The
next run must follow LucaPCycle's official inference/data-conversion logic
without manually rewriting the model pathway.

Current branches:

| Folder | Status | Description |
|---|---|---|
| `lucapcycle_m2_training_uid/` | invalid / superseded | Failed LucaPCycle M2 vector-only extraction for the 107,731 unique training enzyme UIDs |
| `future_enzyme_feature_branch/` | placeholder | Reserved for the next enzyme feature branch |

Large feature artifacts are not stored directly in this GitHub repository.
Each branch documents the HPC data location and the exact audit status.

## Invalid LucaPCycle M2 Result

The current invalid result is the training-UID version:

```text
HPC output root:
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only

Scope:
107,731 unique UniProt IDs from the EnzymeCAGE training table

Structural audit:
FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS

Diversity audit:
VECTOR_DIVERSITY_AUDIT_STATUS=FAIL
```

Although the structural audit passed, the feature vectors collapsed numerically.
This result is invalid and should not be extended to the complete 195,743-UID
enzyme pool. A future replacement run must use the official LucaPCycle inference
route.
