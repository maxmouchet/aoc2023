-- Just bruteforce it :-)
CREATE TEMP FUNCTION generate_large_array(n INT64) AS ((
  SELECT ARRAY_AGG(a * 1000 + b)
  FROM
    UNNEST(GENERATE_ARRAY(0, DIV(n, 1000))) a,
    UNNEST(GENERATE_ARRAY(1, 1000)) b
));

WITH input AS (
  SELECT 1 AS i, SPLIT(line, ":")[0] AS kind, CAST(REPLACE(SPLIT(line, ":")[1], ' ', '') AS INT64) AS n
  FROM aoc2023.d6
), records AS (
  SELECT a.i, a.n AS time, b.n AS record
  FROM input a
  JOIN input b ON a.Kind = 'Time' AND b.Kind = 'Distance' AND a.i = b.i
), distances AS (
  SELECT *, press * (time - press) dist
  FROM records, UNNEST(generate_large_array(time - 1)) press
)
SELECT ROUND(EXP(SUM(LN(c))))
FROM (
  SELECT i, COUNT(*) c
  FROM distances
  WHERE dist > record
  GROUP BY i
)
