# LucaPCycle M2 Full Enzyme Input Audit

Date: 2026年 06月 25日 星期四 10:32:51 CST
Host: login03

## 1. Boundary

Input and coverage audit only.
No M2 extraction is run.
No SLURM job is submitted.
No training is run.
No ESM/ESM-C/ESM2 model is loaded.

## 2. Candidate Full Enzyme Tables

MISSING: /public/home/acfbwjsi7s/data/processed/rhea/2026-01-21/all_enzymes.csv
MISSING: /public/home/acfbwjsi7s/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv
FOUND: /public/home/acfbwjsi7s/LucaPCycle-3/all_enzymes.csv
-rwxr-xr-x 1 acfbwjsi7s acfbwjsi7s 71M 6月  24 16:29 /public/home/acfbwjsi7s/LucaPCycle-3/all_enzymes.csv
MISSING: /public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/processed/rhea/2026-01-21/all_enzymes.csv

SELECTED_FULL_TABLE=/public/home/acfbwjsi7s/LucaPCycle-3/all_enzymes.csv

## 3. Existing M2 Output Checks

OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
drwxrwxr-x 4 acfbwjsi7s acfbwjsi7s 4.0K 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/audit_summary.json
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 741 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/audit_summary.json
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/input_uid_sequence_manifest.csv
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 44M 6月  25 00:54 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/input_uid_sequence_manifest.csv
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/uid_to_shard.csv
-rw-rw-r-- 1 acfbwjsi7s acfbwjsi7s 12M 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/uid_to_shard.csv
OK: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features
drwxrwxr-x 2 acfbwjsi7s acfbwjsi7s 4.0K 6月  25 01:29 /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features

## 4. Python UID Coverage Audit

selected_full_table: /public/home/acfbwjsi7s/LucaPCycle-3/all_enzymes.csv
training_table: /public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
current_m2_out: /public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
current_FULL_VECTOR_STATUS: PASS
current_total_unique_input: 107731
current_completed_total: 107731
current_failed_total: 0
training_rows: 145607
training_unique_uid: 107731
current_m2_uid_to_shard_rows: 107731
current_m2_unique_uid: 107731
current_m2_duplicate_uid_count: 0
full_columns: ['UniprotID', 'sequence']
full_rows_after_nonnull_sequence: 195743
full_unique_uid: 195743
full_duplicate_uid_count: 0
full_min_sequence_length: 4
full_max_sequence_length: 1000
full_head:
 UniprotID                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               sequence
A0A009IHW8                                                                                                                                                                                                                                                                          MSLEQKKGADIISKILQIQNSIGKTTSPSTLKTKLSEISRKEQENARIQSKLSDLQKKKIDIDNKLLKEKQNLIKEEILERKKLEVLTKKQQKDEIEHQKKLKREIDAIKASTQYITDVSISSYNNTIPETEPEYDLFISHASEDKEDFVRPLAETLQQLGVNVWYDEFTLKVGDSLRQKIDSGLRNSKYGTVVLSTDFIKKDWTNYELDGLVAREMNGHKMILPIWHKITKNDVLDYSPNLADKVALNTSVNSIEEIAHQLADVILNR
A0A011QK89                                                                                                                                                   MESIEAVVIGAGVVGLACARELARRGFETVILERHGAFGTETSARNSEVIHAGLYYPTDSLKARLCVAGRQQLYAFCATHAISHQRCGKLVVATSPAQESRLAALQKQGEANGVDDLQRLSAAEARALEPGLACTAALLSPSTGIVDSHGLMLALLGDAETAGAALALHSPLLRGSLDANTPGIVLESGGADGLRFKARRVINAAGLWAPQVAASLAGFPRTLIPANFHAKGSYYALTGRTPFSRLVYPLPEAGGLGVHLTLDLGGQARFGPDVEWLPDPTPGQPIDEPDYRVDPARADAFYAEIRRYWPALPDAALTPAYAGIRPKIVGPGAPAADFLIQGPAQHGIAGLVNLFGIESPGLTACLAIAERAADAADGTRERQFRAHG
A0A017SP50                                                                                                                      MPSEVLTSYYDYPTHDQEAWWRDTGPLFGRFLKGAGYDVHTQYQYLVFFIKNILPSLGPYPARWRSTITPTGLPIEYSLNFQLNSRPLLRIGFEPLSRFSGTPQDPYNKIAAADLLNQLSKLQLHEFDTQLFNHFTNEFELSKSESESLQKQGGINGKSTVRSQTAFGFDLKGGRVAVKGYAFAGLKNRATGTPVGQLISNSIRNLEPQMHCWDSFSILNSYMEESDGWNEYSFVSWDCVDIERSRLKLYGVHNAVTWDKVKEMWTLGGRIENNATIKTGLELLQHMWSLLQINEGDRDYKGGFAADNGGKTLPIIWNYELNKGSPHPAPKFYFPVHGENDLQVSKSISEFFTHLGWQDHARQYPHLLRQIYPNQNISQTERLQAWISFAYNERTGPYLSVYYYSAERPPWGSDQVK
A0A017SPL2                                                                                                                               MQPYHTLSRVLPFPDANQKAWWDKLGPMLLKAMQSQGYDTEAQYAQLGMVYKCVLPYLGEFPTVENDATRWKSFLCPYGIPIEPSLNISQGILRYAFEPIGPDVGTEKDPQNMNIIQDCLKGLTQHDDRIDTTLHAEFSSRLLLTEEESRQFATTGQFNFGPGQGMHGFAVDLKGSRPMFKGYFCAGIKSVVTGIPTGKLMLDAVREVDTEGRITQPLDKLEEYSANGIGKLMLCFMSVDMVNPHDARIKMYGLQQEVSREGIVDLWTLGGRVNTPTNQEGLELLLELWDLLQIPAGPRSVAISHCSVGQPPEYMLPTLVNWTLLPGHSDPMPQVYLVPFGLPDSHISDCLVTFFERRGWTDLARDYKKNLASYFPDIDFTQSRHVQEAISFSFRKGKPYLSIYMSLF
A0A017SR40 MWDSPIIFTTMRELVQSVSPAALSWAVVAIYLGTFFWLRSRSSKQRLPLPPGPRGLPLIGNSLQTPAVNPWEKYKEWSDEYGPVMTLSLGLTTTIILSSHQVANDLMEKKSTIYSSRPQLVMFNRLSGGMNSSGMEYGKRWRDHRSLQASVLRPWMTQRYTALRDVETKQLLAELLNTDDFSSCFKRMVASLFMTLAYGKRVQYPDDPEIRGMEELVRVKSEAGEASFRATGQLVEYIPLLQYLPSFLTPWKEMCDRICEQFNKTFVDRLRDGINAPAWTWAKEVSKHKVARPMSELEISYTLGTLYEASLTSQQILRIIVLVAALYPEKTAKAQEELDRVVGTGRLPAAADARNLPYIDAFVKEALRWRPFAPLGAPRESIRDVEYNGYLIPKGATILVNQWALDYNEDMFPEPFSFLPERWVANPNLPFSTFGFGQRGCPGRYFAQDSLFISTARLLWAFNIRTASPVEVEDMLRNPSAGAFLSPIPEFDATFTARDAQRKALIEKEWEISPKESYAILQEVEKELISEGAE
overlap_full_vs_current_m2: 107731
missing_from_current_m2_if_full_needed: 88012
extra_current_m2_not_in_full: 0
overlap_full_vs_training: 107731
training_uids_missing_from_full: 0
full_uids_not_in_training: 88012
first_20_missing_from_current_m2: ['A0A009IHW8', 'A0A017SPL2', 'A0A023GS28', 'A0A023GS29', 'A0A023W421', 'A0A023YYV9', 'A0A024BTN9', 'A0A059TC02', 'A0A059WGE7', 'A0A059WI14', 'A0A060X6Z0', 'A0A061AE05', 'A0A061FBW2', 'A0A061FDP1', 'A0A061FKL9', 'A0A061FKM4', 'A0A061FLA2', 'A0A061FMF5', 'A0A061FTC2', 'A0A061I403']

FULL_ENZYME_INPUT_AUDIT_STATUS=PASS_FULL_TABLE_FOUND
error_count: 0

## 5. Final Recommendation Boundary

Do not run full enzyme M2 extraction until this audit is reviewed.

REPORT_WRITTEN=/public/home/acfbwjsi7s/LucaPCycle-3/lucapcycle_m2_full_enzyme_input_audit_20260625_103251.md
