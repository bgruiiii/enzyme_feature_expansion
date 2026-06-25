# LucaPCycle M2 酶特征提取阶段性结果说明

日期：2026-06-25

## 0. 重要更正：本次结果已判定作废

本报告原本记录了 LucaPCycle M2 训练 UID 版本的 vector-only 提取过程。后续补充的向量区分度审计显示，该结果虽然文件结构、UID 覆盖和 shape 审计通过，但向量数值几乎塌缩为常量，不能用于训练或下游分析。

作废原因：

```text
本次提取没有完整遵循 LucaPCycle 官方 seq_matrix 推理路径，而是手动拆出 sequence branch：
sequence -> BPE/subword tokens -> seq_encoder -> pooled vectors

但所选 checkpoint 是 seq_matrix 模型，官方逻辑还包含 matrix/embedding 分支，并通过 Encoder / BatchConverter 组织输入。
因此该 seq-only vector-only 提取路线与官方模型逻辑不一致。
```

失败证据：

```text
VECTOR_DIVERSITY_AUDIT_STATUS=FAIL
m2_mean mean_dim_std ~ 3.65e-07
m2_max mean_dim_std ~ 4.20e-07
m2_value_attention mean_dim_std ~ 3.70e-07
m2_projected_256 mean_dim_std ~ 1.47e-07
sample pairwise cosine almost all >= 0.9999
```

结论：

```text
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
```

该目录中的向量结果仅保留为失败记录和诊断依据，不能作为有效 M2 特征使用。下一轮必须严格按 LucaPCycle 官方推理和数据转换流程重跑，并在小样本阶段加入向量区分度审计。

## 1. 本次目的

本次工作的目的是验证并完成 LucaPCycle 中 M2 酶序列特征的提取流程，先为后续 EnzymeCAGE 风格的酶检索模型融合训练准备一套可审计的固定长度 vector 特征。

本次只提取 M2，不重新训练 LucaPCycle，也不加载 ESM/ESM-C/ESM2。M2 的提取路线为：

```text
amino-acid sequence
-> LucaPCycle BPE/subword tokenization
-> LucaPCycle trained Transformer seq_encoder
-> M2 token representation
-> pooled / projected vector features
```

需要特别说明的是，LucaPCycle 论文中的 M1 使用 ESM2-3B；本项目中不使用 3B 模型，而是计划用前期已经在 HPC 上提取好的 ESM-C 600M / ESM600M 酶序列特征替代 M1。因此本次 M2 提取不依赖 ESM。

## 2. 本次数据范围

本次已经完成的是训练表中的唯一酶 UID 集合，不是完整 19 万酶全集。

输入表：

```text
/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
```

数据范围：

| 项目 | 数量 |
|---|---:|
| 训练表反应-酶配对行数 | 145,607 |
| 去重后 UniProt ID 数 | 107,731 |
| 本次成功提取 M2 的 UID 数 | 107,731 |
| 失败 UID 数 | 0 |

本地另有完整酶序列表：

```text
/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv
```

该表包含 `195,743` 个唯一 UniProt ID。完整酶池 M2 特征尚未补跑，计划在老师确认本次训练 UID 版本的数据结构和提取路线可行后，再单独启动完整酶池提取。

## 3. 使用的代码、模型和权重

LucaPCycle 代码路径：

```text
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
```

使用的 checkpoint：

```text
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
```

使用的 BPE codes：

```text
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword/extra_p/extra_p_50_codes_20000.txt
```

环境与计算：

| 项目 | 内容 |
|---|---|
| Python | 3.9.23 |
| PyTorch | 1.13.1 |
| 计算设备 | DCU/ROCm 环境，PyTorch 中显示为 `cuda` |
| `torch_cuda_is_available` | `True` |
| batch size | 4 |
| shard size | 1000 UID/shard |
| 总耗时 | 2110.67 秒 |

模型加载时仅过滤了 checkpoint 中的 `loss_fct.pos_weight`。该 key 是 loss function 的类别权重，不属于 M2 encoder/pooler/linear 主体权重；其余模型权重按严格匹配加载。

## 4. 输出路径和文件结构

输出目录：

```text
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
```

输出目录大小：

```text
899M
```

主要文件：

```text
README.md
extraction_config.json
input_uid_sequence_manifest.csv
uid_to_shard.csv
audit_summary.json
vector_features/
  m2_vectors_part_000000.npz
  ...
  m2_vectors_part_000107.npz
logs/
  lucapcycle_m2_full_vector_report_115940591.md
  lucapcycle_m2_full_vector_output_audit_20260625_102103.md
```

shard 情况：

| 项目 | 数值 |
|---|---:|
| shard 总数 | 108 |
| 完整 shard 数 | 107 |
| 每个完整 shard 行数 | 1000 |
| 最后一个 shard 行数 | 731 |
| 所有 shard 总行数 | 107,731 |

本次没有保存完整 token-level M2 matrix，只保存训练融合更直接使用的固定长度 vector 特征。这样可以显著降低存储量；如果后续老师需要完整矩阵，可以在已验证流程基础上单独跑 token-matrix 分支。

## 5. 输出数据结构

每个 `.npz` shard 都是一个压缩 NumPy 文件，包含以下 key：

```text
uid
sequence_sha256
sequence_length
bpe_token_count_without_special
token_count_with_special
m2_mean
m2_max
m2_value_attention
m2_projected_256
```

每个 shard 的 feature 结构如下，其中 `N` 是该 shard 内 UID 数：

| 字段 | shape | dtype | 含义 |
|---|---:|---|---|
| `uid` | `(N,)` | string | UniProt ID |
| `sequence_sha256` | `(N,)` | string | 蛋白序列 hash，用于一致性校验 |
| `sequence_length` | `(N,)` | int64 | 原始氨基酸序列长度 |
| `bpe_token_count_without_special` | `(N,)` | int64 | 不含 CLS/SEP 的 BPE token 数 |
| `token_count_with_special` | `(N,)` | int64 | 加入 CLS/SEP 后的 token 数 |
| `m2_mean` | `(N, 1024)` | float32 | M2 token representation 的 masked mean pooling |
| `m2_max` | `(N, 1024)` | float32 | M2 token representation 的 masked max pooling |
| `m2_value_attention` | `(N, 1024)` | float32 | LucaPCycle 配置中的 `value_attention` pooling 输出 |
| `m2_projected_256` | `(N, 256)` | float32 | `value_attention` 后再经过 LucaPCycle `seq_linear` 投影得到的 256 维向量 |

后续融合训练时，优先考虑使用 `m2_value_attention` 或 `m2_projected_256`；也可以将 `m2_mean/m2_max` 作为对照特征，比较不同 pooling 方式对检索效果的影响。

## 6. 完整性审计结果

全量提取完成后进行了只读输出审计，审计报告路径：

```text
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/logs/lucapcycle_m2_full_vector_output_audit_20260625_102103.md
```

审计结论：

| 检查项 | 结果 |
|---|---|
| `FULL_VECTOR_OUTPUT_AUDIT_STATUS` | `PASS` |
| error count | 0 |
| `.err` 文件大小 | 0 bytes |
| required files | 全部存在 |
| input manifest rows | 107,731 |
| input manifest unique UID | 107,731 |
| uid_to_shard rows | 107,731 |
| uid_to_shard unique UID | 107,731 |
| UID 重复数 | 0 |
| UID 缺失数 | 0 |
| 额外 UID 数 | 0 |
| failed UID rows | 0 |
| shard index | 0 到 107，连续 |
| total rows across shards | 107,731 |
| token-level matrix | 未保存，符合本次 vector-only 设计 |

全局数值范围审计：

| 特征 | global min | global max | shard mean 均值 |
|---|---:|---:|---:|
| `m2_mean` | -4.843450 | 5.140354 | 0.001064 |
| `m2_max` | -4.843445 | 5.140360 | 0.001066 |
| `m2_value_attention` | -4.843450 | 5.140351 | 0.001064 |
| `m2_projected_256` | -1.000000 | 1.000000 | -0.045595 |

审计过程中未发现 NaN/Inf、shape 错误、dtype 错误或 shard 缺失。

## 7. 结果示例

以下示例来自首个 shard `m2_vectors_part_000000.npz`：

| UID | sequence length | BPE token count | token count with CLS/SEP | `m2_mean` first 5 | `m2_projected_256` first 5 |
|---|---:|---:|---:|---|---|
| P08159 | 458 | 162 | 164 | `[0.009833, 0.007452, 0.491801, -2.422862, 0.598321]` | `[1.0, -1.0, -0.999998, -1.0, 0.999995]` |
| P38999 | 446 | 165 | 167 | `[0.009833, 0.007452, 0.491801, -2.422862, 0.598321]` | `[1.0, -1.0, -0.999998, -1.0, 0.999995]` |
| O59711 | 450 | 166 | 168 | `[0.009833, 0.007453, 0.491801, -2.422862, 0.598321]` | `[1.0, -1.0, -0.999998, -1.0, 0.999995]` |

以下示例来自最后一个 shard `m2_vectors_part_000107.npz`：

| UID | sequence length | BPE token count | token count with CLS/SEP | `m2_mean` first 5 | `m2_projected_256` first 5 |
|---|---:|---:|---:|---|---|
| Q60099 | 253 | 92 | 94 | `[0.009833, 0.007453, 0.491801, -2.422862, 0.598321]` | `[1.0, -1.0, -0.999998, -1.0, 0.999995]` |
| P72542 | 292 | 104 | 106 | `[0.009833, 0.007453, 0.491801, -2.422862, 0.598321]` | `[1.0, -1.0, -0.999998, -1.0, 0.999995]` |
| Q3ZAB8 | 554 | 212 | 214 | `[0.009833, 0.007452, 0.491801, -2.422862, 0.598321]` | `[1.0, -1.0, -0.999998, -1.0, 0.999995]` |

这些示例主要用于说明文件结构、字段含义和维度。由于这里只展示前 5 维，不能单独判断完整向量的区分度。下一步进入训练前，建议补充一次向量方差、重复率和 pairwise cosine similarity 分布审计。

## 8. 当前结论

本次已经完成并验证了训练 UID 范围内的 LucaPCycle M2 vector-only 特征提取：

1. 输入训练 UID 共 `107,731` 个，全部成功提取。
2. 输出采用 108 个 `.npz` shard，结构清晰，便于后续按 UID 映射加载。
3. 每个 UID 目前保存 4 类 vector 特征：3 个 1024 维特征和 1 个 256 维投影特征。
4. 全量审计通过，未发现文件缺失、UID 缺失、重复 UID、失败 UID、NaN/Inf 或 stderr 报错。
5. 本次没有保存 token-level matrix，符合先做训练用 vector 特征的设计。

因此，这套结果可以作为后续酶特征融合训练的候选输入之一，与已有的 ESM-C 600M / ESM600M 特征、GVP 结构特征和口袋特征一起进入下一轮对照实验。

## 9. 需要老师确认的点

建议老师先确认以下问题：

1. 本次先使用训练 UID 的 `107,731` 条 M2 vector 结果是否可作为下一步融合训练输入。
2. 后续是否需要将 M2 提取范围扩展到完整酶池 `195,743` 条 UniProt 序列。
3. 训练融合时优先使用哪类 M2 向量：
   - `m2_value_attention`：最接近 LucaPCycle 当前 checkpoint 配置的 pooling 输出；
   - `m2_projected_256`：已经过 LucaPCycle 内部线性投影，维度更小；
   - `m2_mean/m2_max`：可作为 pooling 对照。
4. 是否需要补充保存 token-level M2 matrix。该矩阵更接近逐 token 表征，但体积会明显大于 vector-only 结果。

## 10. 下一步建议

在老师确认本次数据结构和路线可行后，建议按以下顺序继续：

1. 对当前 `107,731` 条 M2 vector 做一次数值区分度审计，包括向量方差、唯一向量数量、随机 pairwise cosine similarity 分布，以及是否存在大规模重复向量。
2. 如确认需要完整酶池，则基于 `all_enzymes.csv` 重新提取 `195,743` 条完整酶 M2 vector，并单独输出到新目录，避免与当前训练 UID 版本混淆。
3. 将 M2 特征加入后续酶检索训练候选特征组，与已有 ESM-C 600M / ESM600M、GVP 和口袋特征做融合或消融对照。
4. 若结果稳定，再考虑是否补充 token-level M2 matrix 分支。

## 11. GitHub 展示建议

由于当前完整输出目录约 `899M`，不建议直接把全部 `.npz` shard 普通方式上传到 GitHub。更合适的展示方式是：

- 上传本说明文档；
- 上传全量提取报告和输出审计报告；
- 上传 `extraction_config.json`、`audit_summary.json`、`README.md`；
- 上传一个小型示例 shard 或抽样 `.npz`；
- 全量 `.npz` 结果保留在 HPC，或后续使用 Git LFS / release asset / 网盘链接单独管理。

这样既能让老师看到执行路径、数据结构和审计结论，也不会让 GitHub 仓库过大。
