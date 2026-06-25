# Data Location

Large feature files are stored on HPC and are not committed to this GitHub
repository.

## Completed Training-UID M2 Output

```text
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
```

Vector shards:

```text
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features
```

Important files inside the output root:

```text
README.md
extraction_config.json
input_uid_sequence_manifest.csv
uid_to_shard.csv
audit_summary.json
vector_features/m2_vectors_part_000000.npz
...
vector_features/m2_vectors_part_000107.npz
logs/lucapcycle_m2_full_vector_report_115940591.md
logs/lucapcycle_m2_full_vector_output_audit_20260625_102103.md
```

## Input Data Used For This Result

```text
/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
```

This input has:

```text
145,607 reaction-enzyme pair rows
107,731 unique UniProt IDs
```

## Complete Enzyme Pool Not Yet Extracted

Local complete enzyme table:

```text
/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv
```

It contains:

```text
195,743 rows
195,743 unique UniProt IDs
columns: UniprotID, sequence
```

Planned HPC upload target if complete-pool extraction is approved:

```text
/public/home/acfbwjsi7s/LucaPCycle-3/all_enzymes.csv
```

The complete 195,743-UID M2 extraction should be written to a new output
directory so it is not mixed with the current 107,731 training-UID result.

## Current Audit Status

```text
FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS
error_count=0
RUN_ERR_BYTES=0
shard_count=108
total_rows_across_shards=107731
row_count_distribution={731: 1, 1000: 107}
failed_uids_rows=0
```
