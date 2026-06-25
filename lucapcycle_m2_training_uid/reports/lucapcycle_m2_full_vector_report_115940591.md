# LucaPCycle M2 Full Vector-Only Extraction Report

Date: Thu Jun 25 00:53:45 CST 2026
Host: f13r4n00
SLURM_JOB_ID: 115940591

## 1. Boundary

Vector-only full extraction.
No token-level M2 matrix is saved.
No ESM/ESM-C/ESM2 model is loaded.
No training is run.

## 2. Environment

Currently Loaded Modulefiles:
  1) compiler/devtoolset/7.3.1   3) compiler/rocm/dtk-22.10.1
  2) mpi/hpcx/2.11.0/gcc-7.3.1   4) compiler/rocm/dtk-23.10
python: /public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/python
Python 3.9.23
torch_version: 1.13.1
torch_cuda_is_available: True
torch_cuda_device_count: 1

## 3. Input Table Search

CANDIDATE_1=/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
CANDIDATE_2=/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
CANDIDATE_3=

## 4. Run Full Vector Extraction

[2026-06-25 00:54:10] input_csv=/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
[2026-06-25 00:54:10] total_unique_input=107731
[2026-06-25 00:54:10] already_completed=0
[2026-06-25 00:54:10] todo=107731
[2026-06-25 00:54:12] filtered_allowed_keys=['loss_fct.pos_weight']
[2026-06-25 00:54:56] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000000.npz rows=1000 processed_new=1000
[2026-06-25 00:55:10] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000001.npz rows=1000 processed_new=2000
[2026-06-25 00:55:28] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000002.npz rows=1000 processed_new=3000
[2026-06-25 00:55:46] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000003.npz rows=1000 processed_new=4000
[2026-06-25 00:56:03] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000004.npz rows=1000 processed_new=5000
[2026-06-25 00:56:24] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000005.npz rows=1000 processed_new=6000
[2026-06-25 00:56:40] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000006.npz rows=1000 processed_new=7000
[2026-06-25 00:57:01] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000007.npz rows=1000 processed_new=8000
[2026-06-25 00:57:20] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000008.npz rows=1000 processed_new=9000
[2026-06-25 00:57:36] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000009.npz rows=1000 processed_new=10000
[2026-06-25 00:57:56] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000010.npz rows=1000 processed_new=11000
[2026-06-25 00:58:18] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000011.npz rows=1000 processed_new=12000
[2026-06-25 00:58:41] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000012.npz rows=1000 processed_new=13000
[2026-06-25 00:58:56] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000013.npz rows=1000 processed_new=14000
[2026-06-25 00:59:14] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000014.npz rows=1000 processed_new=15000
[2026-06-25 00:59:44] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000015.npz rows=1000 processed_new=16000
[2026-06-25 01:00:02] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000016.npz rows=1000 processed_new=17000
[2026-06-25 01:00:11] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000017.npz rows=1000 processed_new=18000
[2026-06-25 01:00:25] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000018.npz rows=1000 processed_new=19000
[2026-06-25 01:00:53] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000019.npz rows=1000 processed_new=20000
[2026-06-25 01:01:39] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000020.npz rows=1000 processed_new=21000
[2026-06-25 01:01:53] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000021.npz rows=1000 processed_new=22000
[2026-06-25 01:02:12] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000022.npz rows=1000 processed_new=23000
[2026-06-25 01:02:29] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000023.npz rows=1000 processed_new=24000
[2026-06-25 01:02:50] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000024.npz rows=1000 processed_new=25000
[2026-06-25 01:03:06] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000025.npz rows=1000 processed_new=26000
[2026-06-25 01:03:25] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000026.npz rows=1000 processed_new=27000
[2026-06-25 01:03:43] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000027.npz rows=1000 processed_new=28000
[2026-06-25 01:04:03] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000028.npz rows=1000 processed_new=29000
[2026-06-25 01:04:16] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000029.npz rows=1000 processed_new=30000
[2026-06-25 01:04:37] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000030.npz rows=1000 processed_new=31000
[2026-06-25 01:04:54] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000031.npz rows=1000 processed_new=32000
[2026-06-25 01:05:11] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000032.npz rows=1000 processed_new=33000
[2026-06-25 01:05:28] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000033.npz rows=1000 processed_new=34000
[2026-06-25 01:05:51] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000034.npz rows=1000 processed_new=35000
[2026-06-25 01:06:12] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000035.npz rows=1000 processed_new=36000
[2026-06-25 01:06:28] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000036.npz rows=1000 processed_new=37000
[2026-06-25 01:06:50] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000037.npz rows=1000 processed_new=38000
[2026-06-25 01:07:12] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000038.npz rows=1000 processed_new=39000
[2026-06-25 01:07:37] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000039.npz rows=1000 processed_new=40000
[2026-06-25 01:07:55] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000040.npz rows=1000 processed_new=41000
[2026-06-25 01:08:13] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000041.npz rows=1000 processed_new=42000
[2026-06-25 01:08:30] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000042.npz rows=1000 processed_new=43000
[2026-06-25 01:08:51] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000043.npz rows=1000 processed_new=44000
[2026-06-25 01:09:14] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000044.npz rows=1000 processed_new=45000
[2026-06-25 01:09:34] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000045.npz rows=1000 processed_new=46000
[2026-06-25 01:09:49] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000046.npz rows=1000 processed_new=47000
[2026-06-25 01:10:03] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000047.npz rows=1000 processed_new=48000
[2026-06-25 01:10:26] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000048.npz rows=1000 processed_new=49000
[2026-06-25 01:10:41] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000049.npz rows=1000 processed_new=50000
[2026-06-25 01:11:02] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000050.npz rows=1000 processed_new=51000
[2026-06-25 01:11:18] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000051.npz rows=1000 processed_new=52000
[2026-06-25 01:11:36] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000052.npz rows=1000 processed_new=53000
[2026-06-25 01:11:58] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000053.npz rows=1000 processed_new=54000
[2026-06-25 01:12:11] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000054.npz rows=1000 processed_new=55000
[2026-06-25 01:12:30] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000055.npz rows=1000 processed_new=56000
[2026-06-25 01:12:52] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000056.npz rows=1000 processed_new=57000
[2026-06-25 01:13:20] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000057.npz rows=1000 processed_new=58000
[2026-06-25 01:13:43] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000058.npz rows=1000 processed_new=59000
[2026-06-25 01:13:59] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000059.npz rows=1000 processed_new=60000
[2026-06-25 01:14:14] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000060.npz rows=1000 processed_new=61000
[2026-06-25 01:14:39] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000061.npz rows=1000 processed_new=62000
[2026-06-25 01:15:01] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000062.npz rows=1000 processed_new=63000
[2026-06-25 01:15:22] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000063.npz rows=1000 processed_new=64000
[2026-06-25 01:15:37] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000064.npz rows=1000 processed_new=65000
[2026-06-25 01:16:08] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000065.npz rows=1000 processed_new=66000
[2026-06-25 01:16:29] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000066.npz rows=1000 processed_new=67000
[2026-06-25 01:16:50] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000067.npz rows=1000 processed_new=68000
[2026-06-25 01:17:14] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000068.npz rows=1000 processed_new=69000
[2026-06-25 01:17:34] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000069.npz rows=1000 processed_new=70000
[2026-06-25 01:17:50] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000070.npz rows=1000 processed_new=71000
[2026-06-25 01:18:07] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000071.npz rows=1000 processed_new=72000
[2026-06-25 01:18:19] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000072.npz rows=1000 processed_new=73000
[2026-06-25 01:18:30] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000073.npz rows=1000 processed_new=74000
[2026-06-25 01:18:56] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000074.npz rows=1000 processed_new=75000
[2026-06-25 01:19:18] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000075.npz rows=1000 processed_new=76000
[2026-06-25 01:19:41] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000076.npz rows=1000 processed_new=77000
[2026-06-25 01:19:56] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000077.npz rows=1000 processed_new=78000
[2026-06-25 01:20:20] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000078.npz rows=1000 processed_new=79000
[2026-06-25 01:20:36] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000079.npz rows=1000 processed_new=80000
[2026-06-25 01:20:57] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000080.npz rows=1000 processed_new=81000
[2026-06-25 01:21:15] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000081.npz rows=1000 processed_new=82000
[2026-06-25 01:21:29] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000082.npz rows=1000 processed_new=83000
[2026-06-25 01:21:47] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000083.npz rows=1000 processed_new=84000
[2026-06-25 01:22:18] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000084.npz rows=1000 processed_new=85000
[2026-06-25 01:22:39] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000085.npz rows=1000 processed_new=86000
[2026-06-25 01:22:55] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000086.npz rows=1000 processed_new=87000
[2026-06-25 01:23:12] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000087.npz rows=1000 processed_new=88000
[2026-06-25 01:23:27] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000088.npz rows=1000 processed_new=89000
[2026-06-25 01:23:39] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000089.npz rows=1000 processed_new=90000
[2026-06-25 01:23:54] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000090.npz rows=1000 processed_new=91000
[2026-06-25 01:24:19] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000091.npz rows=1000 processed_new=92000
[2026-06-25 01:24:39] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000092.npz rows=1000 processed_new=93000
[2026-06-25 01:24:57] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000093.npz rows=1000 processed_new=94000
[2026-06-25 01:25:13] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000094.npz rows=1000 processed_new=95000
[2026-06-25 01:25:38] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000095.npz rows=1000 processed_new=96000
[2026-06-25 01:25:52] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000096.npz rows=1000 processed_new=97000
[2026-06-25 01:26:09] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000097.npz rows=1000 processed_new=98000
[2026-06-25 01:26:34] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000098.npz rows=1000 processed_new=99000
[2026-06-25 01:26:52] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000099.npz rows=1000 processed_new=100000
[2026-06-25 01:27:06] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000100.npz rows=1000 processed_new=101000
[2026-06-25 01:27:29] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000101.npz rows=1000 processed_new=102000
[2026-06-25 01:27:59] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000102.npz rows=1000 processed_new=103000
[2026-06-25 01:28:10] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000103.npz rows=1000 processed_new=104000
[2026-06-25 01:28:21] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000104.npz rows=1000 processed_new=105000
[2026-06-25 01:28:50] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000105.npz rows=1000 processed_new=106000
[2026-06-25 01:29:07] wrote_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000106.npz rows=1000 processed_new=107000
[2026-06-25 01:29:27] wrote_final_shard=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features/m2_vectors_part_000107.npz rows=731 processed_new=107731
{
  "FULL_VECTOR_STATUS": "PASS",
  "input_csv": "/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv",
  "out_root": "/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only",
  "total_unique_input": 107731,
  "already_completed_at_start": 0,
  "todo_at_start": 107731,
  "processed_new_this_run": 107731,
  "completed_total": 107731,
  "failed_total": 0,
  "shard_file_count": 108,
  "batch_size": 4,
  "shard_size": 1000,
  "elapsed_seconds": 2110.67,
  "device": "cuda",
  "torch_version": "1.13.1",
  "torch_cuda_is_available": true,
  "filtered_allowed_keys": [
    "loss_fct.pos_weight"
  ],
  "token_matrix_saved": false
}

## 5. Output Summary

Top-level files:
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/audit_summary.json
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/extraction_config.json
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/extract_lucapcycle_m2_full_vector_only.py
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/input_uid_sequence_manifest.csv
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/lucapcycle_m2_full_vector_only.sbatch
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/README.md
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/uid_to_shard.csv

Shard count:
108

Audit summary:
{
  "FULL_VECTOR_STATUS": "PASS",
  "input_csv": "/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv",
  "out_root": "/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only",
  "total_unique_input": 107731,
  "already_completed_at_start": 0,
  "todo_at_start": 107731,
  "processed_new_this_run": 107731,
  "completed_total": 107731,
  "failed_total": 0,
  "shard_file_count": 108,
  "batch_size": 4,
  "shard_size": 1000,
  "elapsed_seconds": 2110.67,
  "device": "cuda",
  "torch_version": "1.13.1",
  "torch_cuda_is_available": true,
  "filtered_allowed_keys": [
    "loss_fct.pos_weight"
  ],
  "token_matrix_saved": false
}
## 6. Final Boundary

No token-level M2 matrix was saved.
No ESM/ESM-C/ESM2 model was loaded.
No training was performed.
