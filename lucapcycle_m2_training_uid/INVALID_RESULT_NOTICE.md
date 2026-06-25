# Invalid Result Notice

Date: 2026-06-25

The LucaPCycle M2 training-UID vector-only result in this repository is invalid.

## Invalid HPC Output

```text
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
```

Do not use this output for:

- model training;
- feature fusion;
- downstream analysis;
- complete 195,743-enzyme expansion.

## Why It Failed

The extraction route manually used only the sequence branch:

```text
sequence -> BPE/subword tokens -> seq_encoder -> pooled vectors
```

However, the selected LucaPCycle checkpoint is a `seq_matrix` checkpoint. The
official LucaPCycle pathway uses the full model/data-conversion logic, including
`Encoder`, `BatchConverter`, and the matrix/embedding branch. The manual
seq-only extraction did not match the official inference path.

## Failure Evidence

The structural audit passed:

```text
FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS
total_rows_across_shards=107731
failed_uids_rows=0
```

But the diversity audit failed:

```text
VECTOR_DIVERSITY_AUDIT_STATUS=FAIL
m2_mean mean_dim_std ~ 3.65e-07
m2_max mean_dim_std ~ 4.20e-07
m2_value_attention mean_dim_std ~ 3.70e-07
m2_projected_256 mean_dim_std ~ 1.47e-07
sample pairwise cosine almost all >= 0.9999
```

This indicates vector collapse / non-discriminative representations.

## Required Next Run Policy

The replacement run must:

1. follow LucaPCycle's official inference and data-conversion logic;
2. avoid manually rewriting or bypassing model branches;
3. start with a small sample only;
4. include tokenization checks, official `BatchConverter` checks, and vector
   diversity checks before any full extraction;
5. run the complete 195,743-enzyme pool only after the small sample passes.
