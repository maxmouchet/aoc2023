CREATE TEMP FUNCTION match(line STRING) AS ((
  SELECT ARRAY_AGG(STRUCT(
    REGEXP_EXTRACT(line, r'\d+', 1, i) AS value,
    REGEXP_INSTR(line, r'\d+', 1, i) AS start
  ))
  FROM UNNEST(GENERATE_ARRAY(1, ARRAY_LENGTH(REGEXP_EXTRACT_ALL(line, r'\d+')))) i
));

SELECT SUM(CAST(value AS INT64))
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
    FROM aoc2023.d3p1
  ), UNNEST(match(line)) m
)
WHERE REGEXP_CONTAINS(neighbors, r'[^\w.]')
