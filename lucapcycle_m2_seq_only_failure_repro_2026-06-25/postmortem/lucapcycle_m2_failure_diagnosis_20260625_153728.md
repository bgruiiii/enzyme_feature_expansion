# LucaPCycle M2 Failure Diagnosis

Date: Thu Jun 25 15:37:28 CST 2026
Host: f15r1n03
SLURM_JOB_ID: 115981987

## 1. Boundary

Small-sample diagnosis only. No full extraction. No 195,743-UID job. No training. No ESM/ESM-C/ESM2.

## 2. Known Failure

Current 107,731-UID vector result failed diversity audit.

## 3. Python Diagnosis
### 3.1 Load Config / Tokenizer
hidden_size: 1024
num_hidden_layers: 4
num_attention_heads: 8
vocab_size: 19988
seq_fc_size: [256]
embedding_input_size: 2560
embedding_fc_size: [256]
seq_pooling_type: value_attention
matrix_pooling_type: value_attention
seq_max_length: 3072
input_type: None
no_position_embeddings: True
no_token_type_embeddings: True
tokenizer_vocab_size: 19988
special ids: {'pad': 0, 'unk': 1, 'cls': 2, 'sep': 3, 'mask': 4}

### 3.2 Sample UID Set
UniprotID  sequence_length
   P08159              458
   P38999              446
   O59711              450
   Q9P4R4              450
   P20903               20
   P11726               30
   P53398               36
   P22661               38
   O74945             1000
   Q6CPV1             1000
   O74465              999
   Q9S3V0              998

### 3.3 Manual Tokenization / UNK Audit
UID=P08159 seq_len=458 bpe_pieces=162 token_ids=164 unique_core_ids=145 unk_count=3 unk_ratio=0.0185
  first20_pieces: ['MSS', 'KL', 'ATPL', 'SI', 'QGEV', 'IYP', 'DD', 'SGFD', 'AIAN', 'IW', 'DG', 'RHL', 'Q', 'RPSL', 'IAR', 'CL', 'SAG', 'DVAK', 'SV', 'RY']
  first30_ids: [2, 2460, 180, 6425, 294, 13682, 1962, 71, 16302, 5074, 170, 74, 3056, 21, 15115, 1654, 60, 3301, 7503, 304, 286, 32, 80, 1, 304, 15350, 1530, 2570, 47, 212]
  first20_tokens: ['[CLS]', 'MSS', 'KL', 'ATPL', 'SI', 'QGEV', 'IYP', 'DD', 'SGFD', 'AIAN', 'IW', 'DG', 'RHL', 'Q', 'RPSL', 'IAR', 'CL', 'SAG', 'DVAK', 'SV']
UID=P38999 seq_len=446 bpe_pieces=165 token_ids=167 unique_core_ids=140 unk_count=9 unk_ratio=0.0545
  first20_pieces: ['MG', 'KNV', 'LLLG', 'SG', 'FVAQ', 'PV', 'IDTL', 'AAN', 'DD', 'INV', 'TV', 'AC', 'RTL', 'AN', 'AQAL', 'AK', 'PSG', 'SK', 'AISL', 'DVT']
  first30_ids: [2, 196, 1, 11731, 292, 8600, 245, 9343, 395, 71, 1835, 324, 32, 3234, 42, 5836, 39, 2760, 295, 5177, 1053, 71, 3305, 77, 18892, 12188, 1901, 164, 4149, 1543]
  first20_tokens: ['[CLS]', 'MG', '[UNK]', 'LLLG', 'SG', 'FVAQ', 'PV', 'IDTL', 'AAN', 'DD', 'INV', 'TV', 'AC', 'RTL', 'AN', 'AQAL', 'AK', 'PSG', 'SK', 'AISL']
UID=O59711 seq_len=450 bpe_pieces=166 token_ids=168 unique_core_ids=150 unk_count=5 unk_ratio=0.0301
  first20_pieces: ['MP', 'SI', 'LLLG', 'SGFV', 'AHP', 'TLE', 'YL', 'SRR', 'KENN', 'ITV', 'AC', 'RTL', 'SK', 'AEAF', 'ING', 'IPN', 'SK', 'AIAL', 'DVN', 'DE']
  first30_ids: [2, 203, 294, 11731, 16307, 502, 3710, 375, 3557, 10833, 1927, 32, 3234, 295, 4531, 1825, 1848, 295, 5072, 1049, 72, 393, 94, 6617, 1409, 18284, 164, 381, 372, 687]
  first20_tokens: ['[CLS]', 'MP', 'SI', 'LLLG', 'SGFV', 'AHP', 'TLE', 'YL', 'SRR', 'KENN', 'ITV', 'AC', 'RTL', 'SK', 'AEAF', 'ING', 'IPN', 'SK', 'AIAL', 'DVN']
UID=Q9P4R4 seq_len=450 bpe_pieces=168 token_ids=170 unique_core_ids=154 unk_count=6 unk_ratio=0.0357
  first20_pieces: ['MAT', 'KSVL', 'MLG', 'SG', 'FVT', 'RP', 'TLD', 'VLTD', 'SG', 'IKV', 'TV', 'AC', 'RTLE', 'SAK', 'KL', 'SAG', 'VQ', 'HST', 'PI', 'SL']
  first30_ids: [2, 2215, 11521, 2348, 292, 1291, 279, 3709, 19024, 292, 1792, 324, 32, 1, 3304, 180, 3301, 336, 1593, 235, 296, 1049, 71, 4264, 452, 39, 1409, 331, 16826, 381]
  first20_tokens: ['[CLS]', 'MAT', 'KSVL', 'MLG', 'SG', 'FVT', 'RP', 'TLD', 'VLTD', 'SG', 'IKV', 'TV', 'AC', '[UNK]', 'SAK', 'KL', 'SAG', 'VQ', 'HST', 'PI']
UID=P20903 seq_len=20 bpe_pieces=8 token_ids=10 unique_core_ids=8 unk_count=0 unk_ratio=0.0000
  first20_pieces: ['SDN', 'SVVL', 'RYG', 'DGE', 'Y', 'SYP', 'VV', 'D']
  first30_ids: [2, 3341, 17901, 3282, 971, 29, 3642, 340, 8, 3]
  first20_tokens: ['[CLS]', 'SDN', 'SVVL', 'RYG', 'DGE', 'Y', 'SYP', 'VV', 'D', '[SEP]']
UID=P11726 seq_len=30 bpe_pieces=12 token_ids=14 unique_core_ids=12 unk_count=1 unk_ratio=0.0833
  first20_pieces: ['AF', 'NLRN', 'RNFL', 'KLL', 'DF', 'TP', 'RE', 'IQY', 'MI', 'DL', 'AID', 'L']
  first30_ids: [2, 35, 1, 15025, 2075, 73, 319, 270, 1873, 198, 78, 510, 16, 3]
  first20_tokens: ['[CLS]', 'AF', '[UNK]', 'RNFL', 'KLL', 'DF', 'TP', 'RE', 'IQY', 'MI', 'DL', 'AID', 'L', '[SEP]']
UID=P53398 seq_len=36 bpe_pieces=13 token_ids=15 unique_core_ids=13 unk_count=0 unk_ratio=0.0000
  first20_pieces: ['MRI', 'VL', 'VGP', 'PGAG', 'KGTQ', 'AAYL', 'AQ', 'NL', 'SIP', 'HI', 'ATG', 'DLF', 'R']
  first30_ids: [2, 2433, 333, 3821, 13015, 10942, 4347, 44, 219, 3430, 141, 676, 994, 22, 3]
  first20_tokens: ['[CLS]', 'MRI', 'VL', 'VGP', 'PGAG', 'KGTQ', 'AAYL', 'AQ', 'NL', 'SIP', 'HI', 'ATG', 'DLF', 'R', '[SEP]']
UID=P22661 seq_len=38 bpe_pieces=14 token_ids=16 unique_core_ids=14 unk_count=0 unk_ratio=0.0000
  first20_pieces: ['ST', 'KLV', 'IDPV', 'TR', 'IEG', 'HG', 'KVTV', 'HLDD', 'NNN', 'VVD', 'AHL', 'H', 'VVE', 'F']
  first30_ids: [2, 303, 2082, 9316, 321, 1694, 139, 11666, 9040, 2607, 3864, 499, 12, 3865, 10, 3]
  first20_tokens: ['[CLS]', 'ST', 'KLV', 'IDPV', 'TR', 'IEG', 'HG', 'KVTV', 'HLDD', 'NNN', 'VVD', 'AHL', 'H', 'VVE', 'F', '[SEP]']
UID=O74945 seq_len=1000 bpe_pieces=352 token_ids=354 unique_core_ids=296 unk_count=21 unk_ratio=0.0597
  first20_pieces: ['MPV', 'IPPE', 'KLV', 'SLQ', 'KN', 'QE', 'NIRN', 'FTLL', 'AHVD', 'HG', 'KTTL', 'AD', 'SLL', 'ASNG', 'IISS', 'KL', 'AGTV', 'RFL', 'DF', 'RE']
  first30_ids: [2, 2407, 10171, 2082, 3467, 182, 250, 1, 8568, 5057, 139, 11581, 33, 3463, 6236, 9782, 180, 4977, 3020, 73, 270, 6944, 14555, 199, 302, 5177, 105, 188, 1905, 18]
  first20_tokens: ['[CLS]', 'MPV', 'IPPE', 'KLV', 'SLQ', 'KN', 'QE', '[UNK]', 'FTLL', 'AHVD', 'HG', 'KTTL', 'AD', 'SLL', 'ASNG', 'IISS', 'KL', 'AGTV', 'RFL', 'DF']
UID=Q6CPV1 seq_len=1000 bpe_pieces=359 token_ids=361 unique_core_ids=303 unk_count=17 unk_ratio=0.0474
  first20_pieces: ['MVI', 'ASLE', 'ST', 'HAI', 'STSI', 'VLSS', 'DLW', 'TE', 'FYG', 'TE', 'SVSS', 'ASPN', 'YV', 'KL', 'TLP', 'SY', 'NKW', 'HH', 'QAL', 'ISH']
  first30_ids: [2, 2489, 6219, 303, 1388, 17716, 19020, 1007, 310, 1, 310, 17883, 6248, 382, 180, 3719, 307, 2581, 140, 2793, 1898, 1, 71, 3466, 106, 15706, 244, 214, 1789, 3541]
  first20_tokens: ['[CLS]', 'MVI', 'ASLE', 'ST', 'HAI', 'STSI', 'VLSS', 'DLW', 'TE', '[UNK]', 'TE', 'SVSS', 'ASPN', 'YV', 'KL', 'TLP', 'SY', 'NKW', 'HH', 'QAL']
UID=O74465 seq_len=999 bpe_pieces=368 token_ids=370 unique_core_ids=305 unk_count=20 unk_ratio=0.0543
  first20_pieces: ['ME', 'QVQ', 'DE', 'IW', 'KL', 'STLD', 'AWE', 'MVN', 'KN', 'TEVV', 'FDE', 'IPE', 'PE', 'TLSE', 'MK', 'RH', 'PLY', 'SN', 'IFN', 'AD']
  first30_ids: [2, 194, 2933, 72, 170, 180, 17673, 710, 2493, 182, 18134, 1, 1840, 231, 18407, 199, 273, 2736, 298, 1718, 33, 221, 323, 291, 3673, 1704, 3363, 3451, 249, 16021]
  first20_tokens: ['[CLS]', 'ME', 'QVQ', 'DE', 'IW', 'KL', 'STLD', 'AWE', 'MVN', 'KN', 'TEVV', '[UNK]', 'IPE', 'PE', 'TLSE', 'MK', 'RH', 'PLY', 'SN', 'IFN']
UID=Q9S3V0 seq_len=998 bpe_pieces=364 token_ids=366 unique_core_ids=309 unk_count=12 unk_ratio=0.0330
  first20_pieces: ['MS', 'ILD', 'FP', 'RI', 'HF', 'RGW', 'ARVN', 'APT', 'AN', 'RDP', 'HG', 'HID', 'M', 'ASN', 'TVAM', 'AGEP', 'FDL', 'AR', 'HP', 'TEF']
  first30_ids: [2, 206, 1796, 113, 274, 138, 3046, 6110, 613, 42, 2987, 139, 1477, 17, 663, 1, 4871, 1160, 45, 146, 3665, 148, 143, 3215, 129, 271, 8831, 2944, 12916, 1265]
  first20_tokens: ['[CLS]', 'MS', 'ILD', 'FP', 'RI', 'HF', 'RGW', 'ARVN', 'APT', 'AN', 'RDP', 'HG', 'HID', 'M', 'ASN', '[UNK]', 'AGEP', 'FDL', 'AR', 'HP']
manual_input_ids_shape: (12, 370)
manual_global_unique_input_ids: 1247
manual_global_unk_ratio_nonpad: 0.0432183908045977

### 3.4 Official BatchConverter Tokenization Comparison
------BatchConverter------
BatchConverter, kwargs:
{}
BatchConverter Special Token Idx:
padding_idx=0, unk_idx=1, cls_idx=2, eos_idx=3, mask_idx=4
BatchConverter Special Token Idx:
padding_idx=0, unk_idx=1, cls_idx=2, eos_idx=3, mask_idx=4
BatchConverter: truncation_seq_length=3070, truncation_matrix_length=3072
BatchConverter: seq_prepend_bos=True, seq_append_eos=True
BatchConverter: matrix_prepend_bos=False, matrix_append_eos=False
BatchConverter: matrix_add_special_token=False
--------------------------------------------------
official_input_ids_shape: (12, 370)
official_seq_mask_sum: [164, 167, 168, 170, 10, 14, 15, 16, 354, 361, 370, 366]
manual_mask_sum: [164, 167, 168, 170, 10, 14, 15, 16, 354, 361, 370, 366]
manual_vs_official_ids_equal: True
official_global_unique_input_ids: 1247
official_global_unk_ratio_nonpad: 0.0432183908045977
official_token_type_unique: None
official_position_first_row: None

### 3.5 Load Model
binary_class pos_weight:
tensor([4.], device='cuda:0')
filtered_keys: ['loss_fct.pos_weight']
missing: ['loss_fct.pos_weight']
unexpected: []
device: cuda

### 3.6 Seq Encoder Diversity: Manual vs Official Inputs
emb_mean_manual_before_transformer: shape=(12, 1024), dtype=float32
  global_min=-1.20846379, global_max=0.87193668
  mean_dim_std=0.146740138531, median_dim_std=0.143552646041, max_dim_std=0.376887351274
  row_norm_min=2.25663638, row_norm_max=10.23353863
  cosine_min=0.00917438, cosine_median=0.20083566, cosine_max=0.60516560
m2_token_mean_manual_after_transformer: shape=(12, 1024), dtype=float32
  global_min=-4.84344816, global_max=5.14035034
  mean_dim_std=7.37426432806e-07, median_dim_std=6.38782978513e-07, max_dim_std=3.27435373038e-06
  row_norm_min=28.10415649, row_norm_max=28.10416031
  cosine_min=0.99999988, cosine_median=0.99999994, cosine_max=1.00000000
m2_pooler_manual_nomask: shape=(12, 1024), dtype=float32
  global_min=-4.84344673, global_max=5.14034653
  mean_dim_std=7.83476991728e-07, median_dim_std=6.92364324095e-07, max_dim_std=3.22105324813e-06
  row_norm_min=28.10414696, row_norm_max=28.10415077
  cosine_min=0.99999976, cosine_median=0.99999994, cosine_max=1.00000000
m2_pooler_manual_mask: shape=(12, 1024), dtype=float32
  global_min=-4.84344816, global_max=5.14034748
  mean_dim_std=7.50966137275e-07, median_dim_std=6.87326803472e-07, max_dim_std=3.27382281284e-06
  row_norm_min=28.10414696, row_norm_max=28.10415840
  cosine_min=0.99999976, cosine_median=0.99999988, cosine_max=1.00000000
emb_mean_official_before_transformer: shape=(12, 1024), dtype=float32
  global_min=-1.20846379, global_max=0.87193668
  mean_dim_std=0.146740138531, median_dim_std=0.143552646041, max_dim_std=0.376887351274
  row_norm_min=2.25663638, row_norm_max=10.23353863
  cosine_min=0.00917438, cosine_median=0.20083566, cosine_max=0.60516560
m2_token_mean_official_after_transformer: shape=(12, 1024), dtype=float32
  global_min=-4.84344816, global_max=5.14035034
  mean_dim_std=7.37426432806e-07, median_dim_std=6.38782978513e-07, max_dim_std=3.27435373038e-06
  row_norm_min=28.10415649, row_norm_max=28.10416031
  cosine_min=0.99999988, cosine_median=0.99999994, cosine_max=1.00000000
m2_pooler_official_nomask: shape=(12, 1024), dtype=float32
  global_min=-4.84344673, global_max=5.14034653
  mean_dim_std=7.83476991728e-07, median_dim_std=6.92364324095e-07, max_dim_std=3.22105324813e-06
  row_norm_min=28.10414696, row_norm_max=28.10415077
  cosine_min=0.99999976, cosine_median=0.99999994, cosine_max=1.00000000
m2_pooler_official_mask: shape=(12, 1024), dtype=float32
  global_min=-4.84344816, global_max=5.14034748
  mean_dim_std=7.50966137275e-07, median_dim_std=6.87326803472e-07, max_dim_std=3.27382281284e-06
  row_norm_min=28.10414696, row_norm_max=28.10415840
  cosine_min=0.99999976, cosine_median=0.99999988, cosine_max=1.00000000

### 3.7 Current Saved Shard Cross-Check
shard0 keys: ['bpe_token_count_without_special', 'm2_max', 'm2_mean', 'm2_projected_256', 'm2_value_attention', 'sequence_length', 'sequence_sha256', 'token_count_with_special', 'uid']
shard0 first_uids: ['P08159', 'P38999', 'O59711', 'Q9P4R4', 'A0A499UB99', 'P80324', 'Q75WF1', 'C4R6B0', 'P56216', 'P22255', 'P26264', 'P59735']
saved_shard0_m2_mean_first12: shape=(12, 1024), dtype=float32
  global_min=-4.84344864, global_max=5.14034986
  mean_dim_std=3.32383905288e-07, median_dim_std=2.99393434489e-07, max_dim_std=1.62267247106e-06
  row_norm_min=28.10415840, row_norm_max=28.10415840
  cosine_min=0.99999988, cosine_median=1.00000000, cosine_max=1.00000012
saved_shard0_m2_max_first12: shape=(12, 1024), dtype=float32
  global_min=-4.84344149, global_max=5.14035654
  mean_dim_std=3.8900753907e-07, median_dim_std=3.34047769002e-07, max_dim_std=1.69847089637e-06
  row_norm_min=28.10415840, row_norm_max=28.10416031
  cosine_min=0.99999982, cosine_median=0.99999994, cosine_max=1.00000000
saved_shard0_m2_value_attention_first12: shape=(12, 1024), dtype=float32
  global_min=-4.84344673, global_max=5.14034796
  mean_dim_std=3.38828954227e-07, median_dim_std=3.06395151028e-07, max_dim_std=2.02304863706e-06
  row_norm_min=28.10414886, row_norm_max=28.10415077
  cosine_min=0.99999976, cosine_median=0.99999988, cosine_max=1.00000000
saved_shard0_m2_projected_256_first12: shape=(12, 256), dtype=float32
  global_min=-1.00000000, global_max=1.00000000
  mean_dim_std=1.6366965383e-07, median_dim_std=1.19209289551e-07, max_dim_std=2.76563559964e-06
  row_norm_min=13.70957470, row_norm_max=13.70957565
  cosine_min=1.00000012, cosine_median=1.00000024, cosine_max=1.00000036

### 3.8 Diagnosis Interpretation
DIAGNOSIS_STATUS=COMPLETED_SMALL_SAMPLE
If UNK ratio is high, tokenization/vocab mismatch is likely.
If embedding before Transformer is diverse but M2 after Transformer collapses, seq branch/checkpoint is not usable as standalone M2.
If official BatchConverter differs from manual input and official M2 is diverse, rerun using BatchConverter.
If seq branch remains collapsed even with official BatchConverter, do not run 195,743 seq-only extraction; investigate matrix/ESM branch or a different checkpoint.

## 4. Final Boundary
Diagnosis finished. Do not start complete enzyme-pool extraction until this report is reviewed.
