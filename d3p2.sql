CREATE TEMP FUNCTION match(line STRING) AS ((
  SELECT ARRAY_AGG(STRUCT(
    REGEXP_EXTRACT(line, r'\d+', 1, i) AS value,
    REGEXP_INSTR(line, r'\d+', 1, i) AS start
  ))
  FROM UNNEST(GENERATE_ARRAY(1, ARRAY_LENGTH(REGEXP_EXTRACT_ALL(line, r'\d+')))) i
));

-- This is one is horrible... don't do this :-)
SELECT SUM(prod)
FROM (
  SELECT ROUND(EXP(SUM(LN(CAST(value AS INT64))))) prod
  FROM (
    SELECT *, CONCAT(
      SUBSTR(line, IF(m.start = 1, 1, m.start - 1), LENGTH(m.value) + IF(start = 1, 1, 2)),
      SUBSTR(prev_line, IF(m.start = 1, 1, m.start - 1), LENGTH(m.value) + IF(start = 1, 1, 2)),
      SUBSTR(next_line, IF(m.start = 1, 1, m.start - 1), LENGTH(m.value) + IF(start = 1, 1, 2))
    ) AS neighbors
    FROM (
      SELECT *,
        COALESCE(LAG(line) OVER (ORDER BY i), '') AS prev_line,
        COALESCE(LEAD(line) OVER (ORDER BY i), '') AS next_line
      FROM (
        SELECT i, line
        FROM (
          -- Horrible hack where we replace * with unicode code points > 1024
          -- to act as single-char UUIDs.
          SELECT CODE_POINTS_TO_STRING(ARRAY_AGG(IF(c = 42, 1024 + i, c))) s
          FROM (
            SELECT ARRAY_TO_STRING(ARRAY_AGG(line ORDER BY i), '\n') s
            FROM aoc2023.d3p2
          ), UNNEST(TO_CODE_POINTS(s)) c WITH OFFSET i
        ), UNNEST(SPLIT(s, '\n')) line WITH OFFSET i
      )
    ), UNNEST(match(line)) m
  ), UNNEST(REGEXP_EXTRACT_ALL(neighbors, r'[\x{0400}-\x{FFFF}]')) star
  GROUP BY star
  HAVING COUNT(*) = 2
)
