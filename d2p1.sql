CREATE TEMP FUNCTION do(line STRING) AS ((
  SELECT COUNT(*) = 0
  FROM (
    SELECT SPLIT(m, ' ')[1] AS color, MAX(CAST(SPLIT(m, ' ')[0] AS INT64)) AS count
    FROM UNNEST(REGEXP_EXTRACT_ALL(line, r'\d+\s\w+')) m
    GROUP BY 1
  )
  JOIN (
    SELECT * FROM UNNEST([
      STRUCT('red' AS color, 12 AS max),
      STRUCT('green', 13),
      STRUCT('blue', 14)
    ])
  ) USING (color)
  WHERE count > max
));

SELECT SUM(id) FROM (
  SELECT
    CAST(REGEXP_EXTRACT(line, r'Game (\d+)') AS INT64) AS id,
    do(line) AS valid
  FROM aoc2023.d2p1
)
WHERE valid
