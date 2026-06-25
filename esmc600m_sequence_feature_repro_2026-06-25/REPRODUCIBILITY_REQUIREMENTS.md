# Reproducibility Requirements

## Included

This folder includes:

```text
source code
full all_enzymes input table as gzip
project notes and comparison report
```

## Required Python Environment

The sequence extraction script requires a Python environment with:

```text
torch with GPU support
esm package exposing esm.models.esmc.ESMC
numpy
pandas
tqdm
```

The code imports:

```python
from esm.models.esmc import ESMC
from esm.sdk.api import ESMProtein, LogitsConfig
```

The model is loaded by:

```python
ESMC.from_pretrained("esmc_600m")
```

Depending on the environment, model weights may be downloaded or loaded from an
existing local cache.

## Input Data

Use the included gzip directly:

```text
data/all_enzymes_195743.csv.gz
```

`pandas.read_csv` can read this gzip file directly because it has a `.gz`
extension.

## Minimal Command

```bash
python source_code/run_esmc_sequence_only.py \
  --data_path data/all_enzymes_195743.csv.gz \
  --output_root /path/to/ESM-C_600M \
  --model_name esmc_600m
```

Expected output:

```text
/path/to/ESM-C_600M/node_level/{UniprotID}.npz
/path/to/ESM-C_600M/protein_level/seq2feature.pkl
/path/to/ESM-C_600M/node_level/failed_proteins.csv
```

## Hardware / Runtime Notes

This is a full protein language model inference job over 195,743 enzyme
sequences. It should be run on a GPU-capable machine. The script checks
`torch.cuda.is_available()` and fails if CUDA is unavailable.

## Output Validation Expectations

Expected output counts from the project record:

```text
node_level/*.npz: 195,743
seq2feature.pkl entries: 164,514
```

Expected shapes:

```text
node_feature: (sequence_length, 1152)
seq2feature.pkl value: (1152,)
```

The pooled dictionary is keyed by sequence string, not by UniProt ID. Therefore
the expected pooled entry count is the unique sequence count, not the UID count.

## Relationship To LucaPCycle M1

This package reproduces the EnzymeCAGE ESM-C 600M route. It does not reproduce
LucaPCycle M1.

For comparison:

```text
ESM-C 600M: 1152-d residue matrix, mean-pooled to 1152-d vector
LucaPCycle M1: ESM2-3B / 2560-d residue matrix used by LucaPCycle matrix branch
```
