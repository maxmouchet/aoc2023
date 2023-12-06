WITH input AS (
  SELECT i, SPLIT(line, ":")[0] AS kind, CAST(n AS INT64) AS n
  FROM aoc2023.d6, UNNEST(REGEXP_EXTRACT_ALL(line, r'\d+')) n WITH OFFSET i
), records AS (
  SELECT a.i, a.n AS time, b.n AS record
  FROM input a
  JOIN input b ON a.Kind = 'Time' AND b.Kind = 'Distance' AND a.i = b.i
), distances AS (
  SELECT *, press * (time - press) dist
  FROM records, UNNEST(GENERATE_ARRAY(1, time - 1)) press
)
SELECT ROUND(EXP(SUM(LN(c))))
FROM (
  SELECT i, COUNT(*) c
  FROM distances
  WHERE dist > record
  GROUP BY i
)
