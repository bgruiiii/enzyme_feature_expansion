# Reproducibility Requirements

This document separates assets included in this GitHub folder from assets that
must be downloaded or supplied separately.

## Included In This Folder

```text
source_code/
prompts/
reports/
postmortem/
plans/
configs/
data/training_unique_uniprot_sequences_107731.csv.gz
```

The included compressed data file contains the exact deduplicated UniProt
sequence set used by the failed 107,731-UID seq-only extraction route.

```text
data/training_unique_uniprot_sequences_107731.csv.gz
rows=107731
columns=UniprotID,sequence,sequence_length,sequence_sha256
sha256=7167966e55ffca393f540f1a5240898b493b76df6be6fc4b7a2e4e04bce54ff6
```

The original reaction-enzyme row table is not included because it is 244MB and
the extraction used only the deduplicated `UniprotID,sequence` set.

## Not Included: LucaPCycle Official Source

The official LucaPCycle source code is not vendored here.

Download from:

```text
https://github.com/LucaOne/LucaPCycle
https://github.com/LucaOne/LucaPCycle/tree/V3
```

The official README states that the latest branch is `V3`, so use `V3` for this
reproduction unless intentionally comparing against V2/master.

Expected HPC path in our run:

```text
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
```

## Not Included: LucaPCycle TrainedCheckPoint

The checkpoint files are large and are not uploaded to this repository.

The official LucaPCycle README points to the trained checkpoint FTP:

```text
http://47.93.21.181/lucapcycle/TrainedCheckPoint/
```

The checkpoint used in this failed attempt was:

```text
TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
```

Required files inside that checkpoint:

```text
config.json
pytorch_model.bin
training_args.bin
tokenizer/special_tokens_map.json
tokenizer/tokenizer_config.json
tokenizer/vocab.txt
```

Expected HPC path in our run:

```text
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint
```

## Not Included: ESM / ESM2 Weights

The failed seq-only extraction route did not load ESM/ESM2. It directly called
`model.seq_encoder(...)`.

However, official LucaPCycle `seq_matrix` prediction may require ESM-derived
matrix embeddings. If reproducing official full LucaPCycle prediction rather
than this failed seq-only route, install/use the FAIR ESM package and allow for
ESM2-3B resources.

FAIR ESM repository:

```text
https://github.com/facebookresearch/esm
```

The LucaPCycle M1/matrix branch expects ESM2-3B style matrix input:

```text
esm2_t36_3B_UR50D
embedding_input_size=2560
```

Do not confuse this with our earlier EnzymeCAGE ESM-C 600M features, which are
1152-dimensional and are not a drop-in replacement for LucaPCycle M1.

## Not Included: Invalid Output Shards

The invalid output shards are not uploaded because they are large and should not
be used as features.

Invalid HPC output location:

```text
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
```

Observed size:

```text
899M
108 compressed NumPy .npz shard files
107731 rows
```

The reports in `reports/` and `postmortem/` are sufficient to audit why this
output is invalid.

## Minimal Reproduction Options

### Option A: Reproduce The Failure Exactly

Requires:

```text
LucaPCycle V3 source
LucaPCycle TrainedCheckPoint checkpoint-264284
data/training_unique_uniprot_sequences_107731.csv.gz converted to an input CSV
ROCm/DCU or CUDA-compatible torch environment
```

Then adapt the input path in:

```text
source_code/submit_scripts/05_full_vector_seq_only_submit.sh
```

To prepare the included gzip as a plain CSV:

```bash
source_code/utils/prepare_repro_input.sh \
  data/training_unique_uniprot_sequences_107731.csv.gz \
  /tmp/lucapcycle_m2_repro/reaction_enzyme_pairs.csv
```

This will reproduce the invalid seq-only route. It is not recommended unless
the goal is to audit the failure.

### Option B: Verify The Root Cause Without Full Extraction

Requires the same LucaPCycle source and checkpoint, but only runs small-sample
diagnostics:

```text
source_code/audit_scripts/09_failure_diagnosis.sh
source_code/audit_scripts/10_m2_only_asset_audit.sh
```

This is the preferred review path.

## GitHub Size Policy Used Here

Uploaded:

```text
15M deduplicated sequence input gzip
markdown reports
shell/python source
```

Not uploaded:

```text
244MB original reaction_enzyme_pairs.csv
LucaPCycle source clone
LucaPCycle checkpoint/model weights
899M invalid output shards
ESM/ESM2 model weights
```
