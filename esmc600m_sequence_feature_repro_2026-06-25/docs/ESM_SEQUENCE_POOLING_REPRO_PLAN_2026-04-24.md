# ESM Sequence Pooling Reproduction Plan 2026-04-24

## Goal

For the 2026 rebuilt dataset, pool the generated original ESM-C sequence
features in the same way as the released EnzymeCAGE code, without mixing in
custom compression, pocket-node pooling, or alternative aggregation rules.

This plan is for the sequence-level ESM feature only.

It is **not** for:

- pocket-node pooling
- 256-dimensional projection
- mean+max concatenation
- CLS token pooling
- learned attention pooling

## Original-Model Ground Truth

Original function:

- `/home/a/EnzymeCAGE/feature/main.py`
- `calc_seq_esm_C_feature`

Original code path:

1. generate per-residue ESM-C embeddings
2. save them to:
   - `node_level/{UniprotID}.npz`
3. mean-pool the full sequence over the residue dimension
4. save pooled sequence feature to:
   - `protein_level/seq2feature.pkl`

Original pooling line:

```python
seq_to_feature[seq] = node_feature.mean(axis=0)
```

Code reference:

- `/home/a/EnzymeCAGE/feature/main.py:132`
- `/home/a/EnzymeCAGE/feature/main.py:137`

## What Exactly Is Being Pooled

Input tensor:

- `node_feature`
- shape:
  - `(sequence_length, 1152)`

Pooling rule:

- mean over the first dimension
- output shape:
  - `(1152,)`

Important:

- This is the **full sequence** embedding, not pocket-only residues.
- `node_level/{uid}.npz` already stores residue-level embeddings, so there is
  no extra BOS/EOS stripping step at pooling time.
- Pocket-node features must remain matrices:
  - `(pocket_residue_count, 1152)`

## Keying Rule: Sequence, Not UID

The original model saves pooled ESM features as:

- `sequence -> pooled_feature`

It does **not** save:

- `UniprotID -> pooled_feature`

This matters because many UIDs share the same amino-acid sequence.

Original consequence:

- repeated identical sequences overwrite to the same dictionary key
- final `seq2feature.pkl` entry count should match:
  - unique sequence count
  - not UID count

For the current 2026 strict set, expected counts are:

- all enzymes:
  - `195,743`
- unique sequences:
  - `164,514`

Therefore the correct target size of `seq2feature.pkl` is:

- `164,514`

## Type Rule For Strict Reproduction

The released code computes:

```python
node_feature = logits_output.embeddings[0].cpu()
seq_to_feature[seq] = node_feature.mean(axis=0)
```

So the original-style pooled object is most naturally a CPU
`torch.Tensor` of shape `(1152,)`.

For strict reproduction, the preferred saved value type is:

- `torch.Tensor`
- dtype:
  - `torch.float32`

Why this is preferable:

- closest to the original code path
- avoids ambiguity between numpy arrays and tensors
- matches downstream PyTorch expectations most closely

Note:

- the current dataset loader can read either numpy arrays or tensors because it
  wraps the loaded value with `torch.tensor(...)`
- but for strict original-style regeneration, use `torch.float32` tensors

## Official Output Path

The official original-style sequence-pooled feature should be:

- `G:\\esm\\ESM-C_600M\\protein_level\\seq2feature.pkl`

If rebuilding locally after verified cloud transfer, mirror to:

- `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/feature/protein/ESM-C_600M/protein_level/seq2feature.pkl`

Do not overwrite any custom experimental pooled feature with this file.

## Detailed Execution Plan

### Step 1. Freeze The Reproduction Boundary

Before running anything, fix the rule:

- sequence-level ESM uses original mean pooling
- pocket-node remains unpooled
- no dimensionality reduction
- no new feature names

### Step 2. Verify Inputs First

Required inputs:

- `all_enzymes.csv`
- `node_level/*.npz`
- existing or target `protein_level/seq2feature.pkl`

Expected counts:

- `all_enzymes.csv` rows:
  - `195,743`
- unique `UniprotID`:
  - `195,743`
- unique `sequence`:
  - `164,514`
- `node_level/*.npz` files:
  - `195,743`

If these counts do not match, stop and diagnose before pooling.

### Step 3. Pool Exactly Like The Original Model

For each UID in `all_enzymes.csv`:

1. load `node_level/{UniprotID}.npz`
2. read `node_feature`
3. verify shape:
   - 2D
   - second dimension `1152`
4. compute:
   - `pooled = torch.from_numpy(node_feature).float().mean(dim=0).cpu()`
5. save:
   - `seq_to_feature[sequence] = pooled`

This reproduces the original semantic operation:

```text
(sequence_length, 1152) -> mean over residues -> (1152,)
```

### Step 4. Handle Duplicate Sequences Correctly

Because the official key is the amino-acid sequence string:

- multiple UIDs may map to one sequence key

Required handling:

1. if a sequence key is seen for the first time:
   - write pooled tensor
2. if the same sequence appears again:
   - recompute pooled tensor from that UID
   - compare against the existing saved value
   - if max absolute difference is within tolerance:
     - keep one copy
   - if not:
     - flag as inconsistency and stop

Recommended tolerance:

- max absolute difference `<= 1e-6`

This keeps the reproduction route honest and protects against corrupted
`node_level` inputs.

### Step 5. Save In Original Structure

Save one pickle file:

- `seq2feature.pkl`

Content:

- Python `dict`
- key:
  - full amino-acid sequence string
- value:
  - `torch.FloatTensor` with shape `(1152,)`

Do not also save:

- UID-keyed pooled dict
- 256-dimensional version
- extra metadata inside the same pickle

If metadata is needed, save it separately.

### Step 6. Validate Before Registration

Validation must include all of the following.

Count checks:

- `seq2feature.pkl` entry count equals unique sequence count:
  - expected `164,514`

Type checks:

- top-level object is `dict`
- sample key is `str`
- sample value is `torch.Tensor`
- sample dtype is `float32`
- sample shape is `(1152,)`

Equality checks:

- sample 20 to 100 UIDs
- recompute mean from `node_level/{uid}.npz`
- compare with `seq2feature.pkl[sequence]`
- report:
  - max absolute difference
  - mean absolute difference
  - missing sequence keys
  - missing `.npz` files

Expected:

- missing sequence keys: `0`
- missing `.npz`: `0`
- numerical difference only at floating-point tolerance

### Step 7. Register As The Official Original-Style Artifact

Only after validation passes, record:

- this `seq2feature.pkl` is the official original-style 2026 sequence-level
  pooled ESM feature

Then update:

- daily log
- `PROJECT_MEMORY.md`
- `DATABASE_PROGRESS.md`

## Recommended Implementation Route

The safest route is:

1. do **not** rerun ESM-C forward inference
2. do **not** touch pocket-node
3. rebuild or validate `seq2feature.pkl` directly from existing
   `node_level/*.npz`

Reason:

- the full residue-level ESM-C features already exist
- pooling is deterministic and cheap
- this avoids unnecessary GPU time
- this also avoids mixing pooling validation with the ESM generation step

## What Must Not Be Done

Do not:

- pool pocket-node matrices for the official reproduction route
- replace `seq2feature.pkl` with a UID-keyed dict
- reduce from `1152` to `256`
- concatenate mean and max
- overwrite original-style outputs with custom experiments
- assume `seq2feature.pkl` is correct only because it exists

## Final One-Sentence Rule

For original EnzymeCAGE reproduction, ESM sequence pooling means:

```text
full-sequence residue embeddings -> mean over residue dimension -> 1152-d pooled sequence vector, keyed by sequence string
```
