# ESM Sequence Pooling Experiment Plan 2026-04-23

## Decision From Discussion

After discussion with the advisor, the next feature-design decision is:

- ESM sequence-level information should follow the original EnzymeCAGE pooling
  route.
- ESM pocket-node features should temporarily remain unpooled.
- Do not replace the original pocket-node matrix with the 256-dimensional demo
  vector.

## Boundary: Original Model Versus Custom Work

The experimental route must keep original EnzymeCAGE behavior and custom helper
work clearly separated.

Original-model behavior to follow:

- Generate ESM-C residue/node representations per enzyme sequence.
- Save per-UID node-level features under `node_level/{UniprotID}.npz`.
- Pool the full enzyme sequence by taking the mean over the residue dimension:
  - `(sequence_length, 1152) -> (1152,)`
- Save the pooled sequence-level dictionary as:
  - `protein_level/seq2feature.pkl`
- Keep pocket-node features as matrices:
  - `(pocket_residue_count, 1152)`
- Feed the sequence-level pooled ESM feature and pocket-node matrix into the
  existing downstream dataset/model path.

Custom helper work that must be explicitly labeled as custom:

- Validation scripts or commands that audit counts, shapes, dtypes, and sampled
  mean-pooling equality.
- Rebuilding `seq2feature.pkl` from already-computed `node_level/*.npz` if the
  pooled dictionary is incomplete after an interrupted/resumed cloud run.
- The sharded storage format for full pocket-node features:
  - this is a storage/loader safety change to avoid RAM failure
  - it does not change the tensor value or shape for each UID
- Any 256-dimensional pocket-node pooling demo:
  - this is an exploratory custom example only
  - it is not part of the current official reproduction route

Rule:

- Do not mix custom ablation features into the original-model reproduction
  experiment.
- If a later custom experiment is proposed, give it a separate output path,
  separate name, separate log entry, and do not overwrite original-style assets.

## Original EnzymeCAGE ESM Pooling

Original function:

- `feature/main.py::calc_seq_esm_C_feature`

Original ESM-C residue-level output:

- per UID file:
  - `node_level/{UniprotID}.npz`
- key:
  - `node_feature`
- shape:
  - `(sequence_length, 1152)`

Original pooling operation:

```python
seq_to_feature[seq] = node_feature.mean(axis=0)
```

Result:

- `protein_level/seq2feature.pkl`
- dictionary:
  - `sequence -> pooled_esm_feature`
- each pooled feature:
  - shape: `(1152,)`
  - dtype: usually `torch.float32` or equivalent float array

This is a mean over the residue / sequence-length dimension. It is not a
learned projection and it does not reduce `1152` to `256`.

## Current 2026 Cloud Status

Cloud paths:

- ESM-C node-level features:
  - `G:\esm\ESM-C_600M\node_level\*.npz`
- ESM-C sequence-level pooled file:
  - `G:\esm\ESM-C_600M\protein_level\seq2feature.pkl`

Previously verified counts:

- node-level `.npz`:
  - `195,743 / 195,743`
- unique sequences in `all_enzymes.csv`:
  - `164,514`
- final `seq2feature.pkl` entries:
  - `164,514`

Interpretation:

- The original-style sequence-level pooling is already expected to be complete.
- The next task should be validation and registration, not recomputing ESM-C
  forward embeddings.

## Important Original-Code Risk

The original pooling is generated during ESM-C feature extraction.

However, when `node_level/{uid}.npz` already exists, the original code skips
that UID and does not automatically backfill it into `seq2feature.pkl`.

Therefore, after interrupted or resumed runs, `node_level/*.npz` can be
complete while `seq2feature.pkl` is incomplete.

This happened before and is why the cloud-side `seq2feature.pkl` had to be
rebuilt from the full `node_level` pool.

For future work, never trust `seq2feature.pkl` only because the file exists.
Always check:

- entry count equals unique sequence count
- sampled pooled vectors equal the mean of matching UID `node_feature`

## Experiment Goal

Confirm that the 2026 ESM sequence-level feature file follows the original
EnzymeCAGE pooling rule:

```text
node_feature: (sequence_length, 1152)
mean over sequence_length -> (1152,)
```

Pocket-node remains:

```text
pocket_node_feature: (pocket_residue_count, 1152)
```

and should not be pooled for the default original-model route.

## Required Inputs

On cloud:

- `G:\esm\all_enzymes.csv`
  - columns:
    - `UniprotID`
    - `sequence`
- `G:\esm\ESM-C_600M\node_level\*.npz`
- `G:\esm\ESM-C_600M\protein_level\seq2feature.pkl`

Optional but useful:

- `G:\esm\ESM-C_600M\node_level\failed_proteins.csv`

## Execution Location

Run the first validation on the cloud Windows machine, not locally.

Reason:

- the complete `node_level/*.npz` feature pool is already on cloud
- the candidate official pooled file `seq2feature.pkl` is already on cloud
- local validation would require transferring a large feature archive first
- cloud validation avoids unnecessary transfer and confirms whether the archive
  is worth preserving

Local machine should only be used after the cloud-side validation passes and
the cloud feature archives are packaged with checksums.

Cloud validation must not:

- rerun ESM-C forward inference
- rerun pocket-node extraction
- modify or overwrite `seq2feature.pkl`
- modify or overwrite pocket-node sharded outputs

## Validation Plan

### Step 1: Count Inputs

Check:

- `all_enzymes.csv` row count:
  - expected `195,743`
- unique `UniprotID`:
  - expected `195,743`
- unique `sequence`:
  - expected `164,514`
- `node_level/*.npz` count:
  - expected `195,743`
- `seq2feature.pkl` entries:
  - expected `164,514`

### Step 2: Inspect Pooled Feature Types

Load `seq2feature.pkl` and report:

- top-level type:
  - `dict`
- sample key type:
  - sequence string
- sample value type:
  - `torch.Tensor` or `numpy.ndarray`
- sample shape:
  - `(1152,)`
- sample dtype:
  - float32 expected

### Step 3: Recompute Sample Means

For 20 to 100 sampled UIDs:

1. read sequence from `all_enzymes.csv`
2. load `node_level/{uid}.npz`
3. read `node_feature`
4. compute:
   - `node_feature.mean(axis=0)`
5. compare against:
   - `seq2feature.pkl[sequence]`

Report:

- number checked
- max absolute difference
- mean absolute difference
- any missing sequence keys
- any missing UID `.npz`

Expected:

- missing keys: `0`
- missing `.npz`: `0`
- differences should be near floating point tolerance

### Step 4: Register As Official Feature

If validation passes, treat:

- `G:\esm\ESM-C_600M\protein_level\seq2feature.pkl`

as the official original-style ESM sequence-level pooled feature for 2026.

Do not generate a new 256-dimensional ESM sequence feature unless a later
experimental branch explicitly requests it.

## Estimated Time

Validation only:

- counting files and loading `seq2feature.pkl`:
  - about 2 to 10 minutes, depending on disk speed
- sample mean check for 20 to 100 UIDs:
  - about 1 to 5 minutes

Full rebuild from existing `node_level/*.npz`, if needed:

- no GPU ESM forward pass needed
- CPU/disk I/O only
- estimated about 20 to 60 minutes for `195,743` `.npz` files, depending on
  cloud disk speed

Full ESM-C forward recomputation:

- not recommended
- should not be done unless node-level files are missing or corrupt
- would be much longer and unnecessary given current completed node-level pool

## Default Experimental Route

Route A: original-model reproduction, official route for now

- use `seq2feature.pkl` as ESM sequence-level `(1152,)`
- use pocket-node sharded matrix as `(pocket_residue_count, 1152)`
- use GVP sharded pocket structure features
- run dataset-loading smoke test
- run training smoke test

Route B: optional later custom ablation, not part of the official route

- create derived pooled pocket vector features
- examples:
  - mean pocket-node `(1152,)`
  - mean + max pocket-node `(2304,)`
  - learned projection inside model
- this is not the default route
- it must be documented as custom if used
- do not overwrite original-style pocket-node sharded features

## Success Criteria

The ESM sequence pooling audit passes if:

- `seq2feature.pkl` has `164,514` entries
- each sampled value has shape `(1152,)`
- sampled recomputed means match stored pooled values
- no missing UID `.npz` in sampled checks
- no missing sequence keys in sampled checks

After that, the next default step is local artifact transfer / registration and
dataset-loading smoke tests, not feature recomputation.
