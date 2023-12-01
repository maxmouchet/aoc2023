CREATE TEMP FUNCTION do(line STRING) AS ((
  SELECT ANY_VALUE(COALESCE(v, match) HAVING MIN(i)) || ANY_VALUE(COALESCE(v, match) HAVING MAX(i))
  FROM (
    SELECT i, REGEXP_EXTRACT(SUBSTR(line, i), r'\d|one|two|three|four|five|six|seven|eight|nine') match
    FROM UNNEST(GENERATE_ARRAY(1, LENGTH(line))) i
  )
  LEFT JOIN (
    SELECT k, CAST(i + 1 AS STRING) v
    FROM UNNEST(['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine']) k WITH OFFSET i
  ) ON match = k
  WHERE match IS NOT NULL
));

SELECT SUM(CAST(do(line) AS INT64))
FROM aoc2023.d1p2
