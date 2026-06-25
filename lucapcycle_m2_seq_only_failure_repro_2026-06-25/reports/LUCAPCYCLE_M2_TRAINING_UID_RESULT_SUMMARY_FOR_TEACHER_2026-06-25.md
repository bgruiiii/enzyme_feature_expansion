# LucaPCycle M2 酶特征提取阶段性结果说明

日期：2026-06-25

## 0. 作废声明

本文件保留为审计记录，但其中这批 LucaPCycle M2 vector-only 结果已经判定为
**作废 / 不可用于训练**。

作废原因：

```text
后续 vector diversity audit 发现 107,731 条 UID 的向量几乎完全坍缩；
同时复核 LucaPCycle 官方代码后确认，前一次提取手动只走了 seq_encoder
分支，没有按官方 seq_matrix checkpoint 的完整 inference 路线运行
Encoder + BatchConverter + model(**batch_features)。
```

关键失败证据：

```text
VECTOR_DIVERSITY_AUDIT_STATUS=FAIL
m2_mean mean_dim_std ~ 3.65e-07
m2_max mean_dim_std ~ 4.20e-07
m2_value_attention mean_dim_std ~ 3.70e-07
m2_projected_256 mean_dim_std ~ 1.47e-07
sample pairwise cosine almost all >= 0.9999
```

因此，以下内容只能作为“第一次错误尝试的结构和审计记录”，不能作为老师可采用
的最终特征结果。下一步必须按官方 LucaPCycle `prediction.py` / `Encoder` /
`BatchConverter` / `model(**batch_features)` 路线重新做小样本验证。

## 1. 本次目的

本次工作的原目的，是验证并完成 LucaPCycle 中 M2 酶序列特征的提取流程，先为后续 EnzymeCAGE 风格的酶检索模型融合训练准备一套可审计的固定长度 vector 特征。该目的没有问题，但本次具体执行路线已经判定不正确。

本次错误尝试中实际采用的路线为：

```text
amino-acid sequence
-> LucaPCycle BPE/subword tokenization
-> LucaPCycle trained Transformer seq_encoder
-> M2 token representation
-> pooled / projected vector features
```

后续复核发现：该路线不等同于 LucaPCycle 官方 `seq_matrix` checkpoint 推理路线。官方路线还包含 matrix/embedding 分支；如果没有可用缓存 matrix，官方 `Encoder` 可能会调用 ESM 相关矩阵特征生成逻辑。因此“本次 M2 提取不依赖 ESM”这一判断对所选 `seq_matrix` checkpoint 不成立。

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

该表包含 `195,743` 个唯一 UniProt ID。完整酶池 M2 特征尚未补跑，也不应基于本次错误路线补跑。必须先用官方路线通过小样本验证和向量区分度审计。

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

这些示例现在也可以作为失败线索：不同 UID 的前 5 维和投影值高度相似。后续全量 diversity audit 已确认完整向量也发生大规模坍缩。

## 8. 当前结论

本次只完成了训练 UID 范围内的文件结构生成和结构审计：

1. 输入训练 UID 共 `107,731` 个，全部成功提取。
2. 输出采用 108 个 `.npz` shard，结构清晰，便于后续按 UID 映射加载。
3. 每个 UID 目前保存 4 类 vector 特征：3 个 1024 维特征和 1 个 256 维投影特征。
4. 结构审计通过，未发现文件缺失、UID 缺失、重复 UID、失败 UID、NaN/Inf 或 stderr 报错。
5. 本次没有保存 token-level matrix，符合先做训练用 vector 特征的设计。

但是，后续数值区分度审计失败，说明这批 vector 没有可用区分度。因此结论修正为：

```text
这套结果不可作为后续酶特征融合训练输入。
这套结果不可扩展到 195,743 UID 完整酶池。
这套结果只保留为失败审计记录。
```

## 9. 需要老师确认的点

建议向老师说明并确认以下问题：

1. 当前 `107,731` 条 vector-only 结果已作废，仅保留为失败记录。
2. 下一次是否仍使用 LucaPCycle 官方 `seq_matrix` checkpoint 作为特征来源。
3. 如果继续使用 LucaPCycle 官方 `seq_matrix` 路线，是否允许按官方逻辑加载或生成 matrix/ESM 相关输入。
4. 最终特征应优先导出官方模型分类器前的 `seq + matrix` 拼接表示，而不是只导出 seq 分支。

## 10. 下一步建议

建议按以下顺序继续：

1. 等待并审阅 HPC 已执行的小样本失败诊断报告。
2. 用官方 LucaPCycle `prediction.py` 跑 10-20 条小样本，确认官方推理路径能完整运行。
3. 只在官方推理路径通过后，再设计特征导出 wrapper；wrapper 必须调用官方 `Encoder`、`BatchConverter` 和 `model(**batch_features)`。
4. 小样本导出的特征必须通过 shape/dtype/NaN/Inf/UID 覆盖和 vector diversity 审计。
5. 只有小样本通过并经用户确认后，才能启动 `107,731` 或 `195,743` UID 的全量重跑。

## 11. GitHub 展示建议

由于当前完整输出目录约 `899M` 且结果已经作废，不应把 `.npz` shard 作为可用数据上传到 GitHub。更合适的展示方式是：

- 上传作废声明；
- 上传失败原因说明；
- 上传结构审计报告和 diversity failure 报告；
- 明确写出 invalid HPC output root，仅作为审计留档；
- 不上传作废 `.npz` shard 作为结果示例。

GitHub 当前应展示“为什么第一次失败、为什么不能用、下一步如何按官方路线重跑”，而不是把这批 vector 包装成阶段性可用成果。
