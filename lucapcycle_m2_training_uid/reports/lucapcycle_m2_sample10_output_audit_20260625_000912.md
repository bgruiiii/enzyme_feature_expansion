# LucaPCycle M2 Sample10 Output Audit

Date: Thu Jun 25 00:09:12 CST 2026
Host: login07
OUT_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10

## 1. File Listing

/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/extract_lucapcycle_m2_sample10.py
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/lucapcycle_m2_sample10_output_audit_20260625_000912.md
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/lucapcycle_m2_sample10_report_115936042.md
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/lucapcycle_m2_sample10_report_115936581.md
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/lucapcycle_m2_sample10.sbatch
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/lucap_m2_sample10_115936042.err
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/lucap_m2_sample10_115936042.out
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/lucap_m2_sample10_115936581.err
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/lucap_m2_sample10_115936581.out
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_summary.json
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/A0A499UB99.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/C4R6B0.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/O59711.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/O74945.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/P08159.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/P38999.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/P80324.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/Q6CPV1.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/Q75WF1.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices/Q9P4R4.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_vectors.npz
/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/sample_uid_sequences_10.csv

## 2. Output Audit

sample_csv: /public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/sample_uid_sequences_10.csv
vectors_npz: /public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_vectors.npz
summary_json: /public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_summary.json
token_dir: /public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10/m2_sample_token_matrices
sample_rows: 10
sample_unique_uids: 10
vector_keys: ['bpe_token_count_without_special', 'm2_max', 'm2_mean', 'm2_projected_256', 'm2_value_attention', 'sequence_length', 'sequence_sha256', 'token_count_with_special', 'uid']
m2_mean: shape=(10, 1024), dtype=float32, nan=0, inf=0
m2_max: shape=(10, 1024), dtype=float32, nan=0, inf=0
m2_value_attention: shape=(10, 1024), dtype=float32, nan=0, inf=0
m2_projected_256: shape=(10, 256), dtype=float32, nan=0, inf=0
vector_uid_count: 10
vector_uids: ['P08159', 'P38999', 'O59711', 'Q9P4R4', 'A0A499UB99', 'P80324', 'Q75WF1', 'C4R6B0', 'O74945', 'Q6CPV1']
token_file_count: 10
token_files: ['A0A499UB99.npz', 'C4R6B0.npz', 'O59711.npz', 'O74945.npz', 'P08159.npz', 'P38999.npz', 'P80324.npz', 'Q6CPV1.npz', 'Q75WF1.npz', 'Q9P4R4.npz']
token_matrix[P08159] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(164, 1024), dtype=float16, ids=(164,), mask_sum=164, nan=0, inf=0
token_matrix[P38999] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(167, 1024), dtype=float16, ids=(167,), mask_sum=167, nan=0, inf=0
token_matrix[O59711] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(168, 1024), dtype=float16, ids=(168,), mask_sum=168, nan=0, inf=0
token_matrix[Q9P4R4] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(170, 1024), dtype=float16, ids=(170,), mask_sum=170, nan=0, inf=0
token_matrix[A0A499UB99] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(143, 1024), dtype=float16, ids=(143,), mask_sum=143, nan=0, inf=0
token_matrix[P80324] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(132, 1024), dtype=float16, ids=(132,), mask_sum=132, nan=0, inf=0
token_matrix[Q75WF1] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(135, 1024), dtype=float16, ids=(135,), mask_sum=135, nan=0, inf=0
token_matrix[C4R6B0] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(144, 1024), dtype=float16, ids=(144,), mask_sum=144, nan=0, inf=0
token_matrix[O74945] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(354, 1024), dtype=float16, ids=(354,), mask_sum=354, nan=0, inf=0
token_matrix[Q6CPV1] keys=['attention_mask', 'input_ids', 'm2_token_matrix_fp16']
  shape=(361, 1024), dtype=float16, ids=(361,), mask_sum=361, nan=0, inf=0

loss_fct.pos_weight note:
The sample extraction reported filtering ['loss_fct.pos_weight']; this is a loss-function weight, not an M2 encoder/pooler/linear model weight. Future full extraction may whitelist-filter only this exact key and must fail on any other unexpected key.

OUTPUT_AUDIT_STATUS=PASS
error_count: 0
