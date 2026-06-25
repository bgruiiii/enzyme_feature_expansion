# ESM-C 600M Sequence Feature Reproduction Package

Date: 2026-06-25

This folder collects the source code, input table, and notes for the earlier
EnzymeCAGE ESM-C 600M enzyme feature route. It is intended for comparison with
the LucaPCycle M1 / ESM2-3B matrix feature route.

## What ESM-C 600M Produced

The sequence-level ESM-C route uses:

```text
model = ESMC.from_pretrained("esmc_600m")
```

For each enzyme sequence:

```text
amino-acid sequence
-> ESM-C 600M
-> residue/node feature matrix: (sequence_length, 1152)
-> mean over residue dimension
-> sequence-level vector: (1152,)
```

Output structure:

```text
node_level/{UniprotID}.npz
  key: node_feature
  shape: (sequence_length, 1152)

protein_level/seq2feature.pkl
  type: dict
  key: full amino-acid sequence string
  value: mean-pooled feature, shape (1152,)
```

The pocket-node route reuses the residue matrix and selects pocket residue rows.
It is included here for completeness, but it is not the main feature to compare
against LucaPCycle M1.

## Why This Is Different From LucaPCycle M1

| Item | EnzymeCAGE ESM-C 600M | LucaPCycle M1 |
|---|---|---|
| Upstream PLM | ESM-C `esmc_600m` | ESM2 `esm2_t36_3B_UR50D` |
| Residue dimension | 1152 | 2560 |
| Stored sequence vector | Mean over residues | LucaPCycle matrix branch uses value-attention pooling |
| Main local source | `source_code/run_esmc_sequence_only.py`, `source_code/feature_main.py` | LucaPCycle official source/checkpoint, not included here |
| Task adaptation | General EnzymeCAGE enzyme feature route | LucaPCycle `seq_matrix` classifier trained for phosphorus-cycling protein tasks |

Interpretation:

```text
Both are protein language model residue/contextual features.
They are not equivalent and one should not be renamed as the other.
```

## Included Data

This package includes the full enzyme sequence input table as gzip:

```text
data/all_enzymes_195743.csv.gz
rows=195743
unique_UniprotID=195743
unique_sequence=164514
sha256=b7494b2ab7b8f01350841a44f9572746e34978bec5341fe5d7a4feca41837f97
```

The extraction script reads `UniprotID` and `sequence` from this table.

## Source Code Index

| File | Purpose |
|---|---|
| `source_code/run_esmc_sequence_only.py` | Standalone sequence-level ESM-C 600M extraction script. |
| `source_code/feature_main.py` | Original EnzymeCAGE feature workflow containing `calc_seq_esm_C_feature`. |
| `source_code/run_esmc_pocket_node_only.py` | Standalone pocket-node extraction from existing ESM-C node-level matrices. |
| `source_code/write_training_esmc_cloud_scripts.py` | Helper that generated cloud-side ESM-C export scripts for training packages. |

## Minimal Reproduction

From this folder, after installing the ESM-C-compatible Python environment:

```bash
python source_code/run_esmc_sequence_only.py \
  --data_path data/all_enzymes_195743.csv.gz \
  --output_root /path/to/ESM-C_600M \
  --model_name esmc_600m
```

Expected output:

```text
/path/to/ESM-C_600M/node_level/*.npz
/path/to/ESM-C_600M/protein_level/seq2feature.pkl
```

This runs ESM-C forward inference and can be expensive. If the node-level
features already exist, prefer validation/re-pooling instead of recomputation.

## What Is Not Uploaded

Not uploaded because they are large generated feature artifacts:

```text
G:\esm\ESM-C_600M\node_level\*.npz
G:\esm\ESM-C_600M\protein_level\seq2feature.pkl
G:\esm\ESM-C_600M\pocket_node_feature_full_valid_sharded_20260422
```

Recorded expected counts:

```text
node_level/*.npz: 195,743
seq2feature.pkl entries: 164,514
pocket-node valid rows/features: 191,062
```

## Comparison Materials

See:

```text
comparison/ESMC_600M_VS_LUCAPCYCLE_M1_ANALYSIS_2026-06-24.html
docs/DATABASE_PROGRESS.md
docs/ESM_SEQUENCE_POOLING_REPRO_PLAN_2026-04-24.md
```

Those documents explain why ESM-C 600M is useful as an existing EnzymeCAGE PLM
feature but is not a drop-in replacement for LucaPCycle M1.
