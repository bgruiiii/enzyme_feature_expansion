# LucaPCycle M2 Enzyme Feature Extraction Plan

Date: 2026-06-24

## 1. Purpose

This branch extracts a new enzyme sequence feature named **M2** from the
LucaPCycle model and prepares it for later enzyme retrieval training.

The current project already has enzyme-side GVP structure/pocket features and
ESM-C 600M sequence/pocket features. The goal of this branch is not to replace
those features. The goal is to add a new word-level protein sequence
representation:

```text
enzyme amino-acid sequence
-> BPE / subword word-level tokenization
-> LucaPCycle trained Transformer encoder
-> M2 representation
-> merge later with GVP + existing ESM-C 600M/ESM-pocket for enzyme retrieval training
```

This plan only covers **M2 extraction**. It does not run final EnzymeCAGE
training yet.

## 2. What Is M2

In the LucaPCycle paper, the model has two sequence-related representation
streams:

| Feature | Level | Paper component | Our project adaptation | Responsibility in our work |
|---|---|---|---|---|
| M1 | character-level amino-acid tokens | ESM2-3B | replace with existing HPC-side ESM600M / ESM-C 600M sequence features | already extracted on HPC |
| M2 | word-level BPE/subword tokens | LucaPCycle Transformer encoder | use LucaPCycle BPE + trained M2 encoder checkpoint | current task |

The paper states that word-level tokenization uses BPE from Subword-NMT, and
that the second encoder submodule derives features from the word-level list to
produce M2.

Important project adaptation:

- The LucaPCycle paper uses ESM2-3B for M1.
- Our later enzyme retrieval training will replace that M1 role with the
  ESM600M / ESM-C 600M sequence features that were already extracted on HPC at
  the beginning of the project.
- This M1 substitution does not change the M2 extraction route, because M2 is
  generated from BPE word-level tokens through the LucaPCycle sequence encoder.

Therefore, M2 is not an ESM embedding. It is also not our existing ESM-C 600M
feature. M2 must be produced with:

1. the same BPE codes and vocabulary used by LucaPCycle;
2. the trained LucaPCycle checkpoint, because the Transformer encoder weights
   are learned parameters;
3. our enzyme amino-acid sequences.

## 3. Source Evidence And Code Mapping

Paper-level evidence:

- LucaPCycle has Input, Tokenizer, Encoder, Pooler, and Output modules.
- The Tokenizer performs both character-level and word-level tokenization.
- The word-level route uses Subword-NMT BPE.
- The Encoder produces M1 from ESM2-3B and M2 from the word-level
  Transformer-Encoder in the original LucaPCycle paper.
- In our adapted training plan, the M1-like sequence feature is the existing
  HPC-side ESM600M / ESM-C 600M feature rather than ESM2-3B.

Code-level mapping in LucaPCycle V3:

| Concept | LucaPCycle file / variable |
|---|---|
| BPE loader | `src/prediction_v2.py`, `BPE(bpe_codes, merges=-1, separator='')` |
| BPE codes | `subword/extra_p/extra_p_50_codes_20000.txt` |
| BPE vocab | `vocab/extra_p/extra_p_50_subword_vocab_20000.txt` |
| model class | `src/lucaprot/models/lucaprot.py`, `LucaProt` |
| word-level encoder | `self.seq_encoder = BertModel(...)` |
| M2 token matrix | `seq_outputs[0]` after `seq_outputs = self.seq_encoder(...)` |
| existing pooled outputs | `seq_matrix_mean`, `seq_matrix_max`, `seq_pooled_vec` under `return_embedding=True` |

Important implementation decision:

- For M2 extraction, we should not require either the original ESM2-3B matrix
  branch or the existing ESM600M / ESM-C 600M feature files.
- M2 extraction should not load or install ESM/ESM-C/ESM2. The ESM600M /
  ESM-C 600M feature is only used later as an already-existing feature stream
  during EnzymeCAGE-style fusion training.
- The trained checkpoint is still loaded, but the extraction script should call
  the sequence encoder route directly:

```text
BPE tokens -> input_ids + attention_mask -> model.seq_encoder(...) -> seq_outputs[0]
```

This avoids depending on the M1/ESM matrix branch while still using the trained
LucaPCycle M2 encoder weights.

## 4. Local Inputs Already Prepared

LucaPCycle code:

```text
F:\CHR\LucaPCycle\LucaPCycle-3\LucaPCycle-3
```

WSL path:

```text
/mnt/f/CHR/LucaPCycle/LucaPCycle-3/LucaPCycle-3
```

Checkpoint archive:

```text
F:\CHR\LucaPCycle\TrainedCheckPoint (1).tar.gz
```

Verified local MD5:

```text
8ce38bf2b789d83d4740528ac7d23b81
```

Required binary-class V3 checkpoint is present after extraction:

```text
TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/
```

Required files observed:

```text
config.json
pytorch_model.bin
training_args.bin
tokenizer/special_tokens_map.json
tokenizer/tokenizer_config.json
tokenizer/vocab.txt
```

Current priority sequence input:

```text
/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01/tables/reaction_enzyme_pairs.csv
```

This table contains:

```text
145,607 training rows
107,731 unique UniprotID values
sequence column available
unique sequence length range observed locally: 20 to 1000 aa
```

Full optional sequence input:

```text
/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv
```

This table contains:

```text
195,743 enzymes
columns: UniprotID, sequence
```

Initial extraction should use the **107,731 training UIDs**, because those are
the enzymes currently used in the clean retrieval training package.

## 5. HPC Environment Status

Existing M1-replacement feature status:

- The project already has ESM600M / ESM-C 600M enzyme sequence features on HPC
  from the earlier EnzymeCAGE feature preparation stage.
- The version to preserve is the one used previously:
  `ESMC.from_pretrained("esmc_600m")`, stored under the `ESM-C_600M` feature
  layout.
- Historical audit recorded coverage for `107,731` training UIDs, including
  sequence-level ESM-C outputs.
- Therefore, this branch should not re-extract the M1 replacement feature. It
  should extract M2, upload/keep M2 on HPC, and align M2 by `UniprotID` with
  the existing HPC-side ESM600M / ESM-C 600M and GVP feature assets.

HPC-side M2 environment report:

```text
/home/a/EnzymeCAGE/custom/docs/enzyme_feature_expansion/lucapcycle_m2_env_setup_20260624_183306.md
```

Key points:

- Environment path:
  `/public/home/acfbwjsi7s/envs/lucapcycle_m2`
- Python: `3.9.23`
- Cluster: DCU/ROCm, not NVIDIA CUDA.
- `torch` import is expected to fail on the login node because the DCU runtime
  is only available on compute nodes.
- Non-torch M2 dependencies passed import checks on the login node:
  `transformers`, `tokenizers`, `subword_nmt`, `numpy`, `pandas`, `scipy`,
  `sklearn`, `tqdm`, `biopython`, `h5py`, `statsmodels`, `sentencepiece`,
  `sacremoses`, `pynvml`, `matplotlib`, `requests`.
- LucaPCycle code and checkpoint were not yet uploaded when the environment
  report was generated.

HPC jobs must load:

```bash
module load compiler/rocm/dtk-23.10
source /public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/activate
```

## 6. Feature Outputs To Produce

The extraction should save both compact training-ready features and enough
metadata to audit the result.

### 6.1 Core Training Features

For each `UniprotID`, save fixed-size vectors:

| Feature name | Shape | Meaning |
|---|---:|---|
| `m2_mean` | `(1024,)` | attention-mask-aware mean over M2 token matrix |
| `m2_max` | `(1024,)` | attention-mask-aware max over M2 token matrix |
| `m2_value_attention` | `(1024,)` | LucaPCycle seq_pooler output before seq linear layer |
| `m2_projected_256` | `(256,)` | output after LucaPCycle seq linear layer, if extracted cleanly |

Rationale:

- `m2_mean` and `m2_max` are simple, transparent, and easy to reproduce.
- `m2_value_attention` preserves LucaPCycle's trained pooling idea.
- `m2_projected_256` may be useful for lightweight EnzymeCAGE integration, but
  should be treated as an additional derived feature, not the only M2 record.

### 6.2 Optional Token-Level Features

For a more faithful M2 matrix record, save:

| Feature name | Shape | Meaning |
|---|---:|---|
| `m2_token_matrix_fp16` | `(bpe_token_count, 1024)` | `seq_outputs[0]`, excluding padding |
| `input_ids` | `(bpe_token_count,)` | tokenizer ids for traceability |
| `attention_mask` | `(bpe_token_count,)` | mask before padding removal |

The token-level matrix is closest to the paper's M2 representation, but it is
larger. It should be stored in shards and compressed. The fixed-size vectors
above are the practical inputs for first-round retrieval training.

## 7. Proposed Storage Layout

HPC output root:

```text
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-24/
```

Suggested structure:

```text
lucapcycle_m2_features_2026-06-24/
  README.md
  manifests/
    input_uid_sequence_manifest.csv
    extraction_config.json
    shard_manifest.csv
    failed_uids.csv
    audit_summary.json
  vector_features/
    m2_vectors_part_0000.npz
    m2_vectors_part_0001.npz
    ...
  token_features_optional/
    m2_tokens_part_0000.npz
    m2_tokens_part_0001.npz
    ...
  logs/
    m2_sample_extract_<jobid>.out
    m2_sample_extract_<jobid>.err
    m2_full_extract_<jobid>.out
    m2_full_extract_<jobid>.err
```

Each vector shard should contain arrays such as:

```text
uid
sequence_sha256
sequence_length
bpe_token_count
m2_mean
m2_max
m2_value_attention
m2_projected_256
```

Each token shard, if produced, should contain:

```text
uid
sequence_sha256
bpe_token_count
m2_token_matrix_fp16
input_ids
```

## 8. Implementation Plan

### Step 1. Upload And Verify LucaPCycle Assets On HPC

Upload:

```text
LucaPCycle V3 code archive
TrainedCheckPoint (1).tar.gz
```

Recommended HPC code root:

```text
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
```

After upload:

```bash
md5sum 'TrainedCheckPoint (1).tar.gz'
tar -xzf 'TrainedCheckPoint (1).tar.gz'
```

Then make sure the LucaPCycle project root contains:

```text
src/
subword/
vocab/
models/
logs/
README.md
requirements.txt
```

Verification:

```bash
test -f subword/extra_p/extra_p_50_codes_20000.txt
test -f vocab/extra_p/extra_p_50_subword_vocab_20000.txt
test -f models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/pytorch_model.bin
python -m py_compile src/prediction_v2.py
python -m py_compile src/lucaprot/models/lucaprot.py
python -m py_compile src/common/modeling_bert.py
python -m py_compile src/batch_converter.py
python -m py_compile src/encoder.py
```

### Step 2. Build 10-UID Sample Input

Create a small FASTA or CSV from the training table:

```text
sample_uid_sequences_10.csv
columns: UniprotID, sequence
```

The sample should include ordinary sequence lengths and at least one relatively
long sequence from our training set.

### Step 3. Write A Custom M2 Extraction Script

Proposed script name:

```text
custom/data_build/extract_lucapcycle_m2_features.py
```

The script should:

1. read `UniprotID, sequence`;
2. load LucaPCycle checkpoint from the binary-class V3 checkpoint directory;
3. load BPE codes and tokenizer;
4. convert sequences to BPE word-level input ids and attention masks;
5. call the trained sequence encoder:

```python
seq_outputs = model.seq_encoder(
    input_ids,
    attention_mask=attention_mask,
    token_type_ids=None,
    position_ids=None,
    output_attentions=False,
    output_hidden_states=False,
    return_dict=False,
)
m2_token_matrix = seq_outputs[0]
```

6. remove padding positions using `attention_mask`;
7. save fixed-size vectors and optional token-level matrices;
8. write a manifest and failed UID table.

This should be a custom extraction script rather than a direct use of
`prediction_v2.py`, because `prediction_v2.py` is designed for classification
CSV output, not for exporting M2 matrices.

### Step 4. Run Small Sample On HPC Compute Node

Submit a small SLURM job using the existing environment:

```bash
module load compiler/rocm/dtk-23.10
source /public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/activate
```

Validation checks for the 10-UID run:

- torch imports on compute node;
- checkpoint loads;
- BPE/vocab loads;
- output has 10 successful UIDs;
- vector shapes are correct:
  - `m2_mean`: `(10, 1024)`
  - `m2_max`: `(10, 1024)`
  - `m2_value_attention`: `(10, 1024)` if enabled
  - `m2_projected_256`: `(10, 256)` if enabled
- token-level matrices have variable token lengths and hidden dimension `1024`;
- no NaN or Inf;
- sequence SHA256 in output matches input sequence.

### Step 5. Full Training-UID Extraction

After the sample run passes, extract M2 for the `107,731` unique training UIDs.

Recommended full run policy:

- use sharded outputs;
- periodically flush shards to disk;
- resume by skipping UIDs already present in shard manifest;
- record failed UIDs without stopping the full job;
- keep token-level matrices optional if storage or runtime is too high.

### Step 6. Integration Preparation

After full extraction:

1. copy or keep M2 features on HPC near the existing full training data;
2. build an alignment table keyed by `UniprotID`;
3. verify all `145,607` training rows can map to M2 by UID;
4. add M2 as a new enzyme feature stream in a later EnzymeCAGE-style retrieval
   training run together with GVP and existing ESM-C 600M/ESM-pocket.

## 9. Quality Control Checklist

Before accepting the extraction:

- checkpoint MD5 or file sizes recorded;
- BPE codes and vocab file paths recorded;
- LucaPCycle code path recorded;
- environment report path recorded;
- sample run completed before full run;
- number of input unique UIDs equals expected value;
- number of successful output UIDs recorded;
- failed UIDs table exists even if empty;
- no NaN/Inf in vector outputs;
- output hidden dimension equals `1024`;
- sequence SHA256 checks pass;
- shard manifest can reconstruct all UID -> feature file mappings;
- training table row coverage checked: `145,607 / 145,607` rows should map to a
  valid M2 feature if all `107,731` training UIDs succeed.

## 10. Risks And Controls

| Risk | Control |
|---|---|
| login node cannot import torch on DCU cluster | run torch checks and extraction only through SLURM compute node |
| full `requirements.txt` is too heavy | use the lightweight M2 environment already installed |
| accidentally extracting M1 instead of M2 | do not run ESM2-3B or ESM-C 600M in this script; call `model.seq_encoder` on BPE token ids |
| checkpoint missing on HPC | verify the six required files before running extraction |
| output too large | always save fixed-size vectors; make token-level matrix optional and sharded |
| silent sequence mismatch | save `sequence_sha256` and verify against input |
| padding contaminates pooled features | use `attention_mask` for mean/max and remove padding before token-matrix save |
| full job interruption | shard outputs and implement resume-by-manifest |

## 11. What To Show The Teacher

Short explanation:

```text
We will add LucaPCycle M2 as a new enzyme sequence feature. M2 is the
word-level BPE representation generated by the trained LucaPCycle Transformer
encoder. It is different from our existing GVP structural features and ESM-C
600M sequence/pocket features. Unlike the original LucaPCycle paper, which uses
ESM2-3B for M1, our retrieval model will use the ESM600M / ESM-C 600M sequence
features that were already extracted on HPC as the M1 replacement. We will first
run a small 10-protein extraction test on HPC, verify tensor shapes and feature
integrity, then extract M2 for the 107,731 training UniProt IDs. The output will
be stored as sharded fixed-size vectors, with optional token-level matrices for
traceability. These M2 features will later be fused with GVP and existing
ESM600M / ESM-C 600M features in a new EnzymeCAGE-style enzyme retrieval model.
```

## 12. References

- LucaPCycle Nature Communications article:
  `https://www.nature.com/articles/s41467-025-60142-4`
- LucaPCycle V3 GitHub repository:
  `https://github.com/LucaOne/LucaPCycle/tree/V3`
- LucaPCycle V3 README:
  `https://raw.githubusercontent.com/LucaOne/LucaPCycle/V3/README.md`
- BPE codes:
  `https://github.com/LucaOne/LucaPCycle/tree/V3/subword/extra_p`
- BPE vocab:
  `https://github.com/LucaOne/LucaPCycle/tree/V3/vocab/extra_p`
