WITH maps AS (
  SELECT
    SPLIT(map, ' ')[0] AS map,
    CAST(SPLIT(line, ' ')[0] AS INT64) AS dst_start,
    CAST(SPLIT(line, ' ')[1] AS INT64) AS src_start,
    CAST(SPLIT(line, ' ')[2] AS INT64) AS length
  FROM (
    SELECT line, LAST_VALUE(IF(line LIKE '%map%', line, NULL) IGNORE NULLS) OVER (ORDER BY i) AS map
    FROM aoc2023.d5p1
  )
  WHERE line NOT LIKE ANY ('%map%', '%seeds%')
), seeds AS (
  SELECT CAST(seed AS INT64) AS seed
  FROM aoc2023.d5p1, UNNEST(REGEXP_EXTRACT_ALL(line, r'\d+')) seed
  WHERE line LIKE '%seeds%'
), stage1 AS (
  SELECT seed, COALESCE(seed - src_start + dst_start, seed) soil
  FROM seeds
  LEFT JOIN maps ON map = 'seed-to-soil' AND seed BETWEEN src_start AND src_start + length - 1
), stage2 AS (
  SELECT seed, soil, COALESCE(soil - src_start + dst_start, soil) fertilizer
  FROM stage1
  LEFT JOIN maps ON map = 'soil-to-fertilizer' AND soil BETWEEN src_start AND src_start + length - 1
), stage3 AS (
  SELECT seed, soil, fertilizer, COALESCE(fertilizer - src_start + dst_start, fertilizer) water
  FROM stage2
  LEFT JOIN maps ON map = 'fertilizer-to-water' AND fertilizer BETWEEN src_start AND src_start + length - 1
), stage4 AS (
  SELECT seed, soil, fertilizer, water, COALESCE(water - src_start + dst_start, water) light
  FROM stage3
  LEFT JOIN maps ON map = 'water-to-light' AND water BETWEEN src_start AND src_start + length - 1
), stage5 AS (
  SELECT seed, soil, fertilizer, water, light, COALESCE(light - src_start + dst_start, light) temperature
  FROM stage4
  LEFT JOIN maps ON map = 'light-to-temperature' AND light BETWEEN src_start AND src_start + length - 1
), stage6 AS (
  SELECT seed, soil, fertilizer, water, light, temperature, COALESCE(temperature - src_start + dst_start, temperature) humidity
  FROM stage5
  LEFT JOIN maps ON map = 'temperature-to-humidity' AND temperature BETWEEN src_start AND src_start + length - 1
), stage7 AS (
  SELECT seed, soil, fertilizer, water, light, temperature, humidity, COALESCE(humidity - src_start + dst_start, humidity) location
  FROM stage6
  LEFT JOIN maps ON map = 'humidity-to-location' AND humidity BETWEEN src_start AND src_start + length - 1
)
SELECT MIN(location)
FROM stage7
