# Manifest

## Included Source

| File | Origin | Notes |
|---|---|---|
| `source_code/run_esmc_sequence_only.py` | `custom/data_build/run_esmc_sequence_only.py` | Standalone sequence ESM-C 600M extraction over `all_enzymes.csv`. |
| `source_code/feature_main.py` | `feature/main.py` | Original EnzymeCAGE feature workflow; ESM-C logic is in `calc_seq_esm_C_feature`. |
| `source_code/run_esmc_pocket_node_only.py` | `custom/data_build/run_esmc_pocket_node_only.py` | Builds pocket-node ESM-C matrices from existing node-level features. |
| `source_code/write_training_esmc_cloud_scripts.py` | `custom/data_build/write_training_esmc_cloud_scripts.py` | Helper for exporting already-generated ESM-C features into training packages. |

## Included Input

| File | Contents |
|---|---|
| `data/all_enzymes_195743.csv.gz` | Full enzyme sequence input table, compressed. |
| `data/all_enzymes_195743_manifest.md` | Row counts, unique counts, SHA256, and input schema. |

## Included Documentation

| File | Contents |
|---|---|
| `docs/DATABASE_PROGRESS.md` | Project status, including expected ESM-C artifact counts. |
| `docs/DAILY_LOG_2026-04-23.md` | Daily log covering ESM-C cloud artifacts and pooling route. |
| `docs/ESM_SEQUENCE_POOLING_EXPERIMENT_PLAN_2026-04-23.md` | Original-vs-custom boundary and validation plan. |
| `docs/ESM_SEQUENCE_POOLING_REPRO_PLAN_2026-04-24.md` | Strict reproduction plan for sequence mean pooling. |
| `comparison/ESMC_600M_VS_LUCAPCYCLE_M1_ANALYSIS_2026-06-24.html` | Technical comparison of ESM-C 600M and LucaPCycle M1. |

## Key Code Lines

In `source_code/run_esmc_sequence_only.py`:

```python
model = ESMC.from_pretrained(model_name).to(device)
node_feature = logits_output.embeddings[0].cpu().numpy()
np.savez_compressed(save_path, node_feature=node_feature)
seq_to_feature[seq] = node_feature.mean(axis=0)
```

In `source_code/feature_main.py`:

```python
model = ESMC.from_pretrained("esmc_600m").to(device)
node_feature = logits_output.embeddings[0].cpu()
np.savez_compressed(save_path, node_feature=node_feature)
seq_to_feature[seq] = node_feature.mean(axis=0)
```

## Not Included

Generated artifacts are not included:

```text
node_level/*.npz
protein_level/seq2feature.pkl
pocket_node_feature_full_valid_sharded_20260422
```

They are feature outputs, not source code, and are too large for this GitHub
package.
