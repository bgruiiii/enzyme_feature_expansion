shard_count: 108
  pass1: 30/108
  pass1: 60/108
  pass1: 90/108

## Basic Counts
total_rows: 107731
unique_uid_count: 107731
uid_duplicate_count: 0
uid_sample_first20: ['P08159', 'P38999', 'O59711', 'Q9P4R4', 'A0A499UB99', 'P80324', 'Q75WF1', 'C4R6B0', 'P56216', 'P22255', 'P26264', 'P59735', 'Q8FAG5', 'Q8XCG6', 'Q8Z153', 'P57624', 'P65164', 'P9WKJ0', 'P9WKJ1', 'P44332']

sample_indices_picked: 2000
  pass2: 30/108
  pass2: 60/108
  pass2: 90/108

## Feature Diversity Summary
  cosine for m2_mean (2000 vectors)...
{
  "m2_mean": {
    "shape_dim": 1024,
    "sample_vector_count": 2000,
    "mean_of_dim_means": 0.001064268407907451,
    "mean_dim_std": 3.652241395361604e-07,
    "median_dim_std": 2.92617439843111e-07,
    "min_dim_std": 0.0,
    "max_dim_std": 3.454242158600274e-06,
    "zero_std_dims_lt_1e_8": 1,
    "low_std_dims_lt_1e_5": 1024,
    "zero_range_dims_lt_1e_8": 0,
    "global_min": -4.84345006942749,
    "global_max": 5.140353679656982,
    "cosine_sample": {
      "sample_n": 2000,
      "pair_count": 1999000,
      "cos_min": 0.9999996423721313,
      "cos_p01": 0.9999997615814209,
      "cos_p05": 0.9999998211860657,
      "cos_p50": 0.9999999403953552,
      "cos_p95": 1.0,
      "cos_p99": 1.0,
      "cos_max": 1.0000001192092896,
      "frac_cos_gt_0_999": 1.0,
      "frac_cos_gt_0_9999": 1.0
    }
  }
}
  cosine for m2_max (2000 vectors)...
{
  "m2_max": {
    "shape_dim": 1024,
    "sample_vector_count": 2000,
    "mean_of_dim_means": 0.0010657875312224396,
    "mean_dim_std": 4.2042325811174203e-07,
    "median_dim_std": 3.2390242391274204e-07,
    "min_dim_std": 3.988681822238055e-08,
    "max_dim_std": 4.1329707678221975e-06,
    "zero_std_dims_lt_1e_8": 0,
    "low_std_dims_lt_1e_5": 1024,
    "zero_range_dims_lt_1e_8": 0,
    "global_min": -4.84344482421875,
    "global_max": 5.140360355377197,
    "cosine_sample": {
      "sample_n": 2000,
      "pair_count": 1999000,
      "cos_min": 0.9999996423721313,
      "cos_p01": 0.9999998211860657,
      "cos_p05": 0.9999998807907104,
      "cos_p50": 1.0,
      "cos_p95": 1.0,
      "cos_p99": 1.0000001192092896,
      "cos_max": 1.000000238418579,
      "frac_cos_gt_0_999": 1.0,
      "frac_cos_gt_0_9999": 1.0
    }
  }
}
  cosine for m2_value_attention (2000 vectors)...
{
  "m2_value_attention": {
    "shape_dim": 1024,
    "sample_vector_count": 2000,
    "mean_of_dim_means": 0.001064268743389711,
    "mean_dim_std": 3.706225678512763e-07,
    "median_dim_std": 2.935230117825103e-07,
    "min_dim_std": 2.1675770146562112e-08,
    "max_dim_std": 3.5548561933632957e-06,
    "zero_std_dims_lt_1e_8": 0,
    "low_std_dims_lt_1e_5": 1024,
    "zero_range_dims_lt_1e_8": 0,
    "global_min": -4.843449592590332,
    "global_max": 5.140351295471191,
    "cosine_sample": {
      "sample_n": 2000,
      "pair_count": 1999000,
      "cos_min": 0.9999996423721313,
      "cos_p01": 0.9999997615814209,
      "cos_p05": 0.9999997615814209,
      "cos_p50": 0.9999998807907104,
      "cos_p95": 1.0,
      "cos_p99": 1.0,
      "cos_max": 1.000000238418579,
      "frac_cos_gt_0_999": 1.0,
      "frac_cos_gt_0_9999": 1.0
    }
  }
}
  cosine for m2_projected_256 (2000 vectors)...
{
  "m2_projected_256": {
    "shape_dim": 256,
    "sample_vector_count": 2000,
    "mean_of_dim_means": -0.04559504786156869,
    "mean_dim_std": 1.46794355104749e-07,
    "median_dim_std": 0.0,
    "min_dim_std": 0.0,
    "max_dim_std": 2.6041608624574504e-06,
    "zero_std_dims_lt_1e_8": 132,
    "low_std_dims_lt_1e_5": 256,
    "zero_range_dims_lt_1e_8": 181,
    "global_min": -1.0,
    "global_max": 1.0,
    "cosine_sample": {
      "sample_n": 2000,
      "pair_count": 1999000,
      "cos_min": 1.0,
      "cos_p01": 1.0000001192092896,
      "cos_p05": 1.0000001192092896,
      "cos_p50": 1.000000238418579,
      "cos_p95": 1.0000004768371582,
      "cos_p99": 1.0000004768371582,
      "cos_max": 1.0000005960464478,
      "frac_cos_gt_0_999": 1.0,
      "frac_cos_gt_0_9999": 1.0
    }
  }
}

## Final Status
VECTOR_DIVERSITY_AUDIT_STATUS=FAIL
error_count: 4
warning_count: 4
  ERROR: m2_mean mean_dim_std near zero
  ERROR: m2_max mean_dim_std near zero
  ERROR: m2_value_attention mean_dim_std near zero
  ERROR: m2_projected_256 mean_dim_std near zero
  WARNING: m2_mean extremely similar: frac_cos_gt_0_9999=1.0
  WARNING: m2_max extremely similar: frac_cos_gt_0_9999=1.0
  WARNING: m2_value_attention extremely similar: frac_cos_gt_0_9999=1.0
  WARNING: m2_projected_256 extremely similar: frac_cos_gt_0_9999=1.0

## 4. Final Boundary
Read-only audit finished. Do not start 195,743-UID extraction until this report is reviewed.
