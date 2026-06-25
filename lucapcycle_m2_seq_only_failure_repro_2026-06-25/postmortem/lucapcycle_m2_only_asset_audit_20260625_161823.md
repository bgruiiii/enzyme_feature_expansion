# LucaPCycle M2-Only Asset Audit

Date: Thu Jun 25 16:18:23 CST 2026
Host: login04

## 1. Boundary

Read-only asset audit.
No prediction.
No feature extraction.
No model weight loading.
No ESM/ESM-C/ESM2 loading.
No source modification.

## 2. Directory Overview

OK: /public/home/acfbwjsi7s/LucaPCycle-3
total 71M
-rwxr-xr-x  1 acfbwjsi7s acfbwjsi7s  71M Jun 24 16:29 all_enzymes.csv
drwxr-xr-x 10 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 LucaPCycle-3
-rw-rw-r--  1 acfbwjsi7s acfbwjsi7s  11K Jun 24 20:39 lucapcycle_m2_asset_check_20260624_203846.md
-rw-rw-r--  1 acfbwjsi7s acfbwjsi7s    0 Jun 24 20:49 lucapcycle_m2_compute_smoke_115927754.err
-rw-rw-r--  1 acfbwjsi7s acfbwjsi7s 4.6K Jun 24 20:50 lucapcycle_m2_compute_smoke_115927754.out
-rw-rw-r--  1 acfbwjsi7s acfbwjsi7s 4.5K Jun 24 20:50 lucapcycle_m2_compute_smoke_REPORT.md
-rw-rw-r--  1 acfbwjsi7s acfbwjsi7s 4.1K Jun 24 20:49 lucapcycle_m2_compute_smoke.sbatch
-rw-rw-r--  1 acfbwjsi7s acfbwjsi7s 6.8K Jun 25 10:33 lucapcycle_m2_full_enzyme_input_audit_20260625_103251.md
-rw-rw-r--  1 acfbwjsi7s acfbwjsi7s  305 Jun 25 16:18 lucapcycle_m2_only_asset_audit_20260625_161823.md
drwxrwxr-x  3 acfbwjsi7s acfbwjsi7s 4.0K Jun 25 00:09 m2_sample10
-rw-rw-r--  1 acfbwjsi7s acfbwjsi7s 4.8K Jun 25 16:18 run_m2_audit.sh
drwxr-xr-x  4 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 TrainedCheckPoint
-rw-rw-r--  1 acfbwjsi7s acfbwjsi7s 6.5K Jun 25 16:16 指令.md

OK: /public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
total 58K
drwxr-xr-x 3 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 config
drwxr-xr-x 3 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 data
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s  12K Jun 24 16:59 LICENSE
drwxr-xr-x 4 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 logs
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s  338 Jun 24 16:59 LucaPCycleV3.iml
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s  396 Jun 24 16:59 NOTICE
drwxr-xr-x 2 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 pics
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s  13K Jun 24 16:59 README.md
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 1016 Jun 24 16:59 requirements.txt
drwxr-xr-x 9 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 20:39 src
drwxr-xr-x 6 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 subword
drwxr-xr-x 2 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 test_data
drwxr-xr-x 6 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 vocab

OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint
total 8.0K
drwxr-xr-x 6 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 logs
drwxr-xr-x 6 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 models

OK: /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models
total 16K
drwxr-xr-x 3 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 extra_p_2_class_v2
drwxr-xr-x 3 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 extra_p_2_class_v3
drwxr-xr-x 3 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 extra_p_31_class_v2
drwxr-xr-x 3 acfbwjsi7s acfbwjsi7s 4.0K Jun 24 18:49 extra_p_31_class_v3

## 3. Checkpoint Directory Search

Limited to CKPT_ROOT/models only.

/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v2/protein/binary_class/lucaprot/seq_matrix/20240120061735/checkpoint-955872
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v2/protein/multi_class/lucaprot/seq_matrix/20240120061524/checkpoint-294536
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250

## 4. Input-Type Directory Search

Directories named seq / matrix / seq_matrix / seq_vector / vector:
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v2/protein/binary_class/lucaprot/seq_matrix
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v2/protein/multi_class/lucaprot/seq_matrix
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix

## 5. Config JSON Scan

/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v2/protein/binary_class/lucaprot/seq_matrix/20240120061735/checkpoint-955872/config.json | inferred_dir_input_type=seq_matrix | config_input_type=None | hidden_size=2560 | seq_fc_size=[1280] | embedding_input_size=2560 | embedding_fc_size=[1280] | seq_pooling_type=value_attention | matrix_pooling_type=value_attention
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/config.json | inferred_dir_input_type=seq_matrix | config_input_type=None | hidden_size=1024 | seq_fc_size=[256] | embedding_input_size=2560 | embedding_fc_size=[256] | seq_pooling_type=value_attention | matrix_pooling_type=value_attention
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v2/protein/multi_class/lucaprot/seq_matrix/20240120061524/checkpoint-294536/config.json | inferred_dir_input_type=seq_matrix | config_input_type=None | hidden_size=2560 | seq_fc_size=[1280] | embedding_input_size=2560 | embedding_fc_size=[1280] | seq_pooling_type=value_attention | matrix_pooling_type=value_attention
/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/config.json | inferred_dir_input_type=seq_matrix | config_input_type=None | hidden_size=1024 | seq_fc_size=[256] | embedding_input_size=2560 | embedding_fc_size=[256] | seq_pooling_type=value_attention | matrix_pooling_type=value_attention

config_file_count: 4
seq_like_config_count: 4
seq_matrix_like_config_count: 4

## 6. Training Args Scan

NOTE: torch.load failed on login node (ROCm/HIP lib issue). Values extracted via `strings` from raw binary.

### v2_binary (extra_p_2_class_v2 / checkpoint-955872)

| key | value |
|-----|-------|
| dataset_name | extra_p_2_class_v2 |
| dataset_type | protein |
| task_type | binary_class |
| model_type | lucaprot |
| input_type | seq_matrix |
| input_mode | single |
| seq_pooling_type | value_attention |
| matrix_pooling_type | value_attention |
| llm_type | esm |
| llm_version | esm2 |

### v3_binary (extra_p_2_class_v3 / checkpoint-264284)

| key | value |
|-----|-------|
| dataset_name | extra_p_2_class_v3 |
| dataset_type | protein |
| task_type | binary_class |
| model_type | lucaprot |
| input_type | seq_matrix |
| input_mode | single |
| seq_subword | extra_p_2_class |
| seq_pooling_type | value_attention |
| matrix_pooling_type | value_attention |
| llm_type | esm |
| llm_version | esm2 |

### v2_multi (extra_p_31_class_v2 / checkpoint-294536)

| key | value |
|-----|-------|
| dataset_name | extra_p_31_class_v2 |
| dataset_type | protein |
| task_type | multi_class |
| model_type | lucaprot |
| input_type | seq_matrix |
| input_mode | single |
| llm_type | esm |
| llm_version | esm2 |

### v3_multi (extra_p_31_class_v3 / checkpoint-8569250)

| key | value |
|-----|-------|
| dataset_name | extra_p_31_class_v3 |
| dataset_type | protein |
| task_type | multi_class |
| model_type | lucaprot |
| input_type | seq_matrix |
| input_mode | single |
| seq_subword | extra_p_31_class |
| seq_pooling_type | value_attention |
| matrix_pooling_type | value_attention |
| llm_type | esm |
| llm_version | esm2 |


## 7. Official Code Route Search

Search only CODE_ROOT README/docs/src for M2/export/input_type references.
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/README.md:68:    --emb_dir ../../test_data/examples/embedding/lucapcyclev3/ \
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/README.md:77:    --input_type seq_matrix \
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/README.md:94:    --emb_dir ../../test_data/example_positives/embedding/lucapcyclev3/ \
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/README.md:103:    --input_type seq_matrix \
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/README.md:127:   * input_type: `str`, the model channels, default: `seq_matrix`
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:9:@file: predict_embedding
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:10:@desc: inference the embedding by ESM2
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:19:from esm import BatchConverter, pretrained
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:153:def complete_embedding_matrix(seq_id, seq_type, seq, truncation_seq_length, init_emb, model_args, embedding_type):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:154:    if init_emb is not None and model_args.embedding_complete and ("representations" in embedding_type or "matrix" in embedding_type):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:172:        if model_args.embedding_complete_seg_overlap:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:174:            print("Embedding Complete Seg Overlap: %r, ori seq len: %d, segment len: %d, init sliding windown: %d" % (model_args.embedding_complete_seg_overlap,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:188:                            seg_emb, seg_processed_seq_len = predict_embedding(sample=[seq_id + "_seg_%d" % seg_idx, seq_type, seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:190:                                                                           embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:206:                            seg_emb, seg_processed_seq_len = predict_embedding(sample=[seq_id + "_seg_%d" % seg_idx, seq_type, seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:208:                                                                           embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:227:                            seg_emb, seg_processed_seq_len = predict_embedding(sample=[seq_id + "_seg_%d" % seg_idx, seq_type, seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:229:                                                                           embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:245:                            seg_emb, seg_processed_seq_len = predict_embedding(sample=[seq_id + "_seg_%d" % seg_idx, seq_type, seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:247:                                                                           embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:278:                        seg_emb, seg_processed_seq_len = predict_embedding(
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:281:                            embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:305:                        last_seg_emb, last_seg_processed_seq_len = predict_embedding(
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:308:                            embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:323:                        first_seg_emb, first_seg_processed_seq_len = predict_embedding(sample=[seq_id + "_seg_0", seq_type, first_seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:325:                                                                                   embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:347:        print("seq len: %d, seq embedding matrix len: %d" % (ori_seq_len, complete_emb.shape[0] + (2 if model_args.matrix_add_special_token else 0)))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:356:def predict_embedding(sample,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:358:                      embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:365:    use sequence to predict protein embedding matrix or vector(bos)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:368:    :param embedding_type: bos or representations
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:374:    :return: embedding, processed_seq_len
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:377:    assert "bos" in embedding_type or "representations" in embedding_type \
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:378:           or "matrix" in embedding_type or "vector" in embedding_type or "contacts" in embedding_type
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:431:    converter = BatchConverter(global_alphabet, truncation_seq_length)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:433:    embeddings = {}
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:441:            if "representations" in embedding_type or "matrix" in embedding_type:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:443:                    embedding = out["representations"][global_layer_size].to(device="cpu")[0, 1: truncate_len + 1].clone().numpy()
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:445:                    embedding = out["representations"][global_layer_size].to(device="cpu")[0, 1: truncate_len + 1].clone().numpy()
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:446:                embeddings["representations"] = embedding
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:447:            if "bos" in embedding_type or "vector" in embedding_type:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:448:                embedding = out["representations"][global_layer_size].to(device="cpu")[0, 0].clone().numpy()
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:449:                embeddings["bos_representations"] = embedding
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:450:            if "contacts" in embedding_type:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:451:                embedding = out["contacts"][global_layer_size].to(device="cpu")[0, :, :].clone().numpy()
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:452:                embeddings["contacts"] = embedding
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:453:            if len(embeddings) > 1:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:454:                return embeddings, processed_seq_len
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:455:            elif len(embeddings) == 1:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:456:                return list(embeddings.items())[0][1], processed_seq_len
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:467:    parser = argparse.ArgumentParser(description='ESM/ESM2 Embedding')
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:474:    parser.add_argument("--embedding_type", type=str, default="matrix", choices=["matrix", "vector", "contact"],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:475:                        help="llm embedding type.")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:487:                        help="embedding file save path")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:492:    parser.add_argument("--embedding_complete",  action="store_true",
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:493:                        help="when the seq len > inference_max_len, then the embedding matrix is completed by segment")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:494:    parser.add_argument("--embedding_complete_seg_overlap",  action="store_true",
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:497:                        help="whether to add special token embedding in seq representation matrix")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:522:    embedding_type = args.embedding_type
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:544:            emb_filename = calc_emb_filename_by_seq_id(seq_id=seq_id, embedding_type=embedding_type)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:545:            embedding_filepath = os.path.join(save_path, emb_filename)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:546:            if not os.path.exists(embedding_filepath):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:549:                if args.embedding_complete:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:553:                emb, processed_seq_len = predict_embedding(sample=[seq_id, seq_type, seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:555:                                                           embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:563:                    print("%s embedding error, max_len from %d truncate to %d" % (seq_id, truncation_seq_length,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:566:                    emb, processed_seq_len = predict_embedding(sample=[seq_id, seq_type, seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:568:                                                           embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:576:                        emb = complete_embedding_matrix(seq_id=seq_id, seq_type=seq_type, seq=seq, truncation_seq_length=truncation_seq_length, init_emb=emb, model_args=args, embedding_type=embedding_type)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:578:                # print("emb shape:", embedding_info.shape)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:579:                torch.save(emb, embedding_filepath)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:583:                print("embedding done: %d" % done)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:587:        emb, processed_seq_len = predict_embedding(sample=[args.seq_id, seq_type, args.seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/llm/esm/predict_embedding.py:589:                                                   embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:26:class BatchConverter(object):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:34:                 no_position_embeddings,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:35:                 no_token_type_embeddings,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:51:        print("------BatchConverter------")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:52:        print("BatchConverter, kwargs:")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:59:        self.no_position_embeddings = no_position_embeddings
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:60:        self.no_token_type_embeddings = no_token_type_embeddings
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:108:        print("BatchConverter Special Token Idx:")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:145:        print("BatchConverter Special Token Idx:")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:166:        print("BatchConverter: truncation_seq_length=%d, truncation_matrix_length=%d" % (self.truncation_seq_length, self.truncation_matrix_length))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:167:        print("BatchConverter: seq_prepend_bos=%r, seq_append_eos=%r" % (self.seq_prepend_bos, self.seq_append_eos))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:168:        print("BatchConverter: matrix_prepend_bos=%r, matrix_append_eos=%r" % (self.matrix_prepend_bos, self.matrix_append_eos))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:169:        print("BatchConverter: matrix_add_special_token=%r" % self.matrix_add_special_token)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:171:        self.input_type = None
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:172:        if "input_type" in kwargs and kwargs["input_type"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:173:            self.input_type = kwargs["input_type"]
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:178:            print("BatchConverter: trunc_type=%s" % self.trunc_type)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:310:        if not self.no_position_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:321:        if not self.no_position_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:348:        embedding_vector_dim = vectors[0].shape[0]
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:352:                embedding_vector_dim
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:373:        embedding_vector_dim = matrices[0].shape[1]
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:379:                embedding_vector_dim
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:462:                if not self.no_position_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:466:                if not self.no_token_type_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:499:                    # embedding矩阵中有特殊字符，并且模型中需要使用
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:506:                    # embedding矩阵中有特殊字符，但模型中不需要使用（已经进行了裁剪）
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:588:            # embedding 矩阵有特殊字符，如果不使用则去掉首尾的特殊字符
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:636:            # embedding 矩阵有特殊字符，如果不使用则去掉首尾的特殊字符
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/batch_converter.py:702:            # embedding 矩阵有特殊字符，如果不使用则去掉首尾的特殊字符
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:21:    from llm.esm.predict_embedding import predict_embedding as predict_embedding_esm
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:24:    from src.llm.esm.predict_embedding import predict_embedding as predict_embedding_esm
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:31:def complete_embedding_matrix_esm(
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:38:        embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:40:        embedding_complete,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:41:        embedding_complete_seg_overlap,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:44:    if init_emb is not None and embedding_complete and ("representations" in embedding_type or "matrix" in embedding_type):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:62:        if embedding_complete_seg_overlap:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:64:            print("Embedding Complete Seg Overlap: %r, ori seq len: %d, segment len: %d, init sliding windown: %d" % (embedding_complete_seg_overlap,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:78:                            seg_emb, seg_processed_seq_len = predict_embedding_esm(sample=[seq_id + "_seg_%d" % seg_idx, seq_type, seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:80:                                                                               embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:96:                            seg_emb, seg_processed_seq_len = predict_embedding_esm(sample=[seq_id + "_seg_%d" % seg_idx, seq_type, seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:98:                                                                               embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:117:                            seg_emb, seg_processed_seq_len = predict_embedding_esm(sample=[seq_id + "_seg_%d" % seg_idx, seq_type, seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:119:                                                                               embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:135:                            seg_emb, seg_processed_seq_len = predict_embedding_esm(sample=[seq_id + "_seg_%d" % seg_idx, seq_type, seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:137:                                                                               embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:168:                        seg_emb, seg_processed_seq_len = predict_embedding_esm(
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:171:                            embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:195:                        last_seg_emb, last_seg_processed_seq_len = predict_embedding_esm(
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:198:                            embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:213:                        first_seg_emb, first_seg_processed_seq_len = predict_embedding_esm(sample=[seq_id + "_seg_0", seq_type, first_seg_seq],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:215:                                                                                       embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:237:        print("seq len: %d, seq embedding matrix len: %d" % (ori_seq_len, complete_emb.shape[0] + (2 if matrix_add_special_token else 0)))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:246:class Encoder(object):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:250:                 input_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:255:                 vector_dirpath=None,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:256:                 matrix_dirpath=None,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:260:        print("------Encoder------")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:263:        self.input_type = input_type
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:267:        if vector_dirpath and "#" in vector_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:268:            self.vector_dirpath = list(vector_dirpath.split("#"))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:269:        elif vector_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:270:            self.vector_dirpath = [vector_dirpath]
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:272:            self.vector_dirpath = None
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:274:        if matrix_dirpath and "#" in matrix_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:275:            self.matrix_dirpath = list(matrix_dirpath.split("#"))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:276:        elif matrix_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:277:            self.matrix_dirpath = [matrix_dirpath]
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:279:            self.matrix_dirpath = None
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:288:        print("Encoder: prepend_bos=%r, append_eos=%r" % (self.prepend_bos, self.append_eos))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:293:        if "embedding_complete" in kwargs and kwargs["embedding_complete"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:294:            self.embedding_complete = kwargs["embedding_complete"]
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:295:            print("Encoder: embedding_complete=%r" % self.embedding_complete)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:297:            self.embedding_complete = False
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:298:        if "embedding_complete_seg_overlap" in kwargs and kwargs["embedding_complete_seg_overlap"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:299:            self.embedding_complete_seg_overlap = kwargs["embedding_complete_seg_overlap"]
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:300:            print("Encoder: embedding_complete_seg_overlap=%r" % self.embedding_complete_seg_overlap)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:302:            self.embedding_complete_seg_overlap = False
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:304:        if "matrix_embedding_exists" in kwargs and kwargs["matrix_embedding_exists"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:305:            self.matrix_embedding_exists = kwargs["matrix_embedding_exists"]
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:307:            self.matrix_embedding_exists = False
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:315:        print("Encoder device: ", device)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:318:        print("Encoder: prepend_bos=%r, append_eos=%r" % (self.prepend_bos, self.append_eos))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:319:        print("Encoder: matrix_add_special_token=%r, "
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:320:              "embedding_complete=%r, "
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:321:              "embedding_complete_seg_overlap=%r, "
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:322:              "matrix_embedding_exists=%r" %
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:324:               self.embedding_complete,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:325:               self.embedding_complete_seg_overlap,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:326:               self.matrix_embedding_exists)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:330:    def __get_embedding__(self, seq_id, seq_type, seq, embedding_type):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:334:        embedding_info = None
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:338:                dirpath_list = self.vector_dirpath if embedding_type in ["bos", "vector"] else self.matrix_dirpath
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:342:                        embedding_info = torch.load(emb_filepath)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:343:                        return embedding_info
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:346:                embedding_info = None
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:347:        elif embedding_type in ["bos", "vector"] and self.vector_dirpath is not None \
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:348:                or embedding_type not in ["bos", "vector"] and self.matrix_dirpath is not None:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:349:            emb_filename = calc_emb_filename_by_seq_id(seq_id, embedding_type)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:351:                dirpath_list = self.vector_dirpath if embedding_type in ["bos", "vector"] else self.matrix_dirpath
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:355:                        embedding_info = torch.load(emb_filepath)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:357:                        return embedding_info
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:360:                embedding_info = None
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:362:        if embedding_info is None:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:363:            if self.matrix_embedding_exists:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:364:                with open("matrix_embedding_not_exists.txt", "a+") as wfp:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:368:        if embedding_info is None:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:371:                if self.embedding_complete:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:376:                embedding_info, processed_seq_len = predict_embedding_esm(
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:379:                    embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:386:                while embedding_info is None:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:387:                    print("%s embedding error, max_len from %d truncate to %d" % (seq_id,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:393:                    embedding_info, processed_seq_len = predict_embedding_esm(
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:396:                        embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:403:                    if embedding_info is not None and self.embedding_complete:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:404:                        embedding_info = complete_embedding_matrix_esm(
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:409:                            init_emb=embedding_info,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:411:                            embedding_type=embedding_type,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:413:                            embedding_complete=self.embedding_complete,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:414:                            embedding_complete_seg_overlap=self.embedding_complete_seg_overlap,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:419:        if embedding_type in ["bos", "vector"] and self.vector_dirpath is not None \
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:420:                or embedding_type not in ["bos", "vector"] and self.matrix_dirpath is not None:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:421:            emb_filename = calc_emb_filename_by_seq_id(seq_id, embedding_type)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:422:            dirpath_list = self.vector_dirpath if embedding_type in ["bos", "vector"] else self.matrix_dirpath
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:425:            torch.save(embedding_info, emb_filepath)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:427:        return embedding_info
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:438:        # for embedding vector
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:440:        if self.input_type in ["vector", "seq_vector"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:445:                    raise Exception("now not support embedding of the seq_type=%s" % seq_type)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:447:                    vector = self.__get_embedding__(seq_id, seq_type, seq, "vector")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:449:                for vector_dir in self.vector_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:459:        # for embedding matrix
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:461:        if self.input_type in ["matrix", "seq_matrix"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:466:                    raise Exception("now not support embedding of the seq_type=%s" % seq_type)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:468:                    matrix = self.__get_embedding__(seq_id, seq_type, seq, "matrix")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:470:                for matrix_dir in self.matrix_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:506:        # for embedding vector
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:508:        if self.input_type in ["vector", "seq_vector"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:513:                    raise Exception("now not support embedding of the seq_type_a=%s" % seq_type_a)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:515:                    vector_a = self.__get_embedding__(seq_id_a, seq_type_a, seq_a, "vector")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:517:                for vector_dir in self.vector_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:530:                    raise Exception("now not support embedding of the seq_type_b=%s" % seq_type_b)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:532:                    vector_b = self.__get_embedding__(seq_id_b, seq_type_b, seq_b, "vector")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:534:                for vector_dir in self.vector_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:544:        # for embedding matrix
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:546:        if self.input_type in ["matrix", "seq_matrix"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:551:                    raise Exception("now not support embedding of the seq_type_a=%s" % seq_type_a)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:553:                    matrix_a = self.__get_embedding__(seq_id_a, seq_type_a, seq_a, "matrix")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:555:                for matrix_dir in self.matrix_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:568:                    raise Exception("now not support embedding of the seq_type_b=%s" % seq_type_b)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:570:                    matrix_b = self.__get_embedding__(seq_id_b, seq_type_b, seq_b, "matrix")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/encoder.py:572:                for matrix_dir in self.matrix_dirpath:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:282:def prepare_inputs(input_type, embedding_type, batch):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:283:    if input_type == "sequence":
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:293:    elif input_type == "embedding":
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:294:        if embedding_type not in ["vector", "bos"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:296:                "embedding_info_a": batch[0],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:297:                "embedding_attention_mask_a": batch[1],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:298:                "embedding_info_b": batch[2],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:299:                "embedding_attention_mask_b": batch[3],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:304:                "embedding_info_a": batch[0],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:305:                "embedding_attention_mask_a": None,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:306:                "embedding_info_b": batch[1],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:307:                "embedding_attention_mask_b": None,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:310:    elif input_type == "structure":
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:318:    elif input_type == "sefn":
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:319:        if embedding_type not in ["vector", "bos"]:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:324:                "embedding_info_a": batch[4],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:325:                "embedding_attention_mask_a": batch[5],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:329:                "embedding_info_b": batch[10],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:330:                "embedding_attention_mask_b": batch[11],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:338:                "embedding_info_a": batch[4],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:339:                "embedding_attention_mask_a": None,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:343:                "embedding_info_b": batch[9],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:344:                "embedding_attention_mask_b": None,
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:347:    elif input_type == "ssfn":
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:820:def calc_emb_filename_by_seq_id(seq_id, embedding_type):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:824:    :param embedding_type:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:832:        emb_filename = embedding_type + "_" + seq_id.replace(" ", "").replace("/", "_").replace("|", "_") + ".pt"
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:834:        emb_filename = embedding_type + "_" + seq_id.replace(" ", "").replace("/", "_") + ".pt"
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:868:        model_input_type=["seq_matrix", "seq_matrix"],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:886:                model_input_type[model_idx],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/utils.py:894:                model_input_type[model_idx],
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:162:        if m_name[-11:] == "_embeddings":
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:178:    """Construct the embeddings from word, position and token_type embeddings."""
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:182:        if hasattr(config, "use_rotary_position_embeddings"):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:183:            self.use_rotary_position_embeddings = config.use_rotary_position_embeddings
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:185:            self.use_rotary_position_embeddings = False
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:187:        if hasattr(config, "no_token_embeddings"):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:188:            self.no_token_embeddings = config.no_token_embeddings
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:190:            self.no_token_embeddings = False
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:191:        if not self.no_token_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:192:            self.word_embeddings = nn.Embedding(config.vocab_size, config.hidden_size, padding_idx=config.pad_token_id)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:194:        if self.use_rotary_position_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:195:            self.no_position_embeddings = True
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:197:            if hasattr(config, "no_position_embeddings"):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:198:                self.no_position_embeddings = config.no_position_embeddings
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:200:                self.no_position_embeddings = False
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:202:        if hasattr(config, "no_token_type_embeddings"):
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:203:            self.no_token_type_embeddings = config.no_token_type_embeddings
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:205:            self.no_token_type_embeddings = False
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:207:        if not self.no_position_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:208:            self.position_embeddings = nn.Embedding(config.max_position_embeddings, config.hidden_size)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:209:        if not self.no_token_type_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:210:            self.token_type_embeddings = nn.Embedding(config.type_vocab_size, config.hidden_size)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:217:        if not self.no_position_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:218:            self.position_embedding_type = getattr(config, "position_embedding_type", "absolute")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:219:            self.register_buffer("position_ids", torch.arange(config.max_position_embeddings).expand((1, -1)))
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:220:        if not self.no_token_type_embeddings and not self.no_position_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:243:        if not self.no_position_embeddings and position_ids is None :
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:249:        if not self.no_token_type_embeddings and token_type_ids is None:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:256:        if self.no_token_embeddings and inputs_embeds is None:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:257:            raise Exception("The model has not token_embeddings layer, the inputs_embeds cannot None")
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:260:            inputs_embeds = self.word_embeddings(input_ids)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:261:        embeddings = inputs_embeds
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:263:        if not self.no_token_type_embeddings:
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:264:            token_type_embeddings = self.token_type_embeddings(token_type_ids)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:265:            embeddings += token_type_embeddings
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:267:        if not self.no_position_embeddings and self.position_embedding_type == "absolute":
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:268:            position_embeddings = self.position_embeddings(position_ids)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:269:            embeddings += position_embeddings
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:271:        embeddings = self.LayerNorm(embeddings)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:272:        embeddings = self.dropout(embeddings)
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:273:        return embeddings
/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/src/common/modeling_bert.py:277:    def __init__(self, config, position_embedding_type=None):

## 8. Final Assessment

M2_ONLY_ASSET_AUDIT_STATUS=NO_M2_ONLY_FOUND

m2_only_checkpoint_paths=none

seq_matrix_checkpoint_paths=
- /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v2/protein/binary_class/lucaprot/seq_matrix/20240120061735/checkpoint-955872
- /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
- /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v2/protein/multi_class/lucaprot/seq_matrix/20240120061524/checkpoint-294536
- /public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250

official_m2_only_export_entrypoint=none

requires_esm_or_matrix_for_official_prediction=yes

recommendation=do not run

### Evidence Summary

1. **Checkpoint inventory**: All 4 checkpoints are `seq_matrix` type. No `seq`, `matrix`, `vector`, or `seq_vector` checkpoint directories exist.
2. **Training args**: All 4 checkpoints confirm `llm_type=esm`, `llm_version=esm2`, `input_type=seq_matrix`.
3. **Code analysis** (`src/encoder.py` L369-L418): When `matrix_filename=None` and embedding cache miss, `Encoder.__get_embedding__()` unconditionally calls `predict_embedding_esm(... version="3B" ...)` which loads `esm2_t36_3B_UR50D` (ESM2 3B model).
4. **Code analysis** (`src/prediction_v2.py` L691-L710): `run()` pre-generates ESM embeddings via `encoder.__get_embedding__()` for all sequences before prediction, when `matrix_embedding_exists=False` and `gpu_id > -1`.
5. **ESM package**: `fair-esm` is NOT installed in the conda env (`/public/home/acfbwjsi7s/envs/lucapcycle_m2` → `nis` env). `import esm` fails with `ModuleNotFoundError`.
6. **ESM model cache**: No ESM2 model weights cached under `~/.cache/torch/hub/checkpoints/` (directory does not exist).
7. **No alternative route**: No seq-only checkpoint, no M2-only export script, no code path that bypasses ESM for seq_matrix input type.
