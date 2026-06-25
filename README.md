# Enzyme Feature Expansion

This repository collects staged reports, reproducibility prompts, and audit
records for enzyme feature expansion experiments.

Current branches:

| Folder | Status | Description |
|---|---|---|
| `lucapcycle_m2_training_uid/` | completed stage report | LucaPCycle M2 vector-only extraction for the 107,731 unique training enzyme UIDs |
| `future_enzyme_feature_branch/` | placeholder | Reserved for the next enzyme feature branch |

Large feature artifacts are not stored directly in this GitHub repository.
Each branch documents the HPC data location and the exact audit status.

## Current LucaPCycle M2 Result

The current completed result is the training-UID version:

```text
HPC output root:
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only

Scope:
107,731 unique UniProt IDs from the EnzymeCAGE training table

Status:
FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS
```

This is not yet the complete 195,743-UID enzyme pool. The complete enzyme-pool
version will be added as a later update after approval of the current data
structure and extraction route.
