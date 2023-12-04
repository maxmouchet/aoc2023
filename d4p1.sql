CREATE TEMP FUNCTION intersection(a ANY TYPE, b ANY TYPE) AS ((
  SELECT ARRAY_AGG(i) FROM UNNEST(a) i JOIN UNNEST(b) j ON i = j
));

CREATE TEMP FUNCTION do(line STRING) AS ((
  SELECT intersection(winning, candidates)
  FROM (
    SELECT
      REGEXP_EXTRACT_ALL(SPLIT(line, '|')[0], r'\d+') AS winning,
      REGEXP_EXTRACT_ALL(SPLIT(line, '|')[1], r'\d+') AS candidates
    FROM (
      SELECT SPLIT(line, ':')[1] AS line
    )
  )
));

SELECT SUM(POW(2, ARRAY_LENGTH(inter) - 1))
FROM (
  SELECT do(line) AS inter
  FROM aoc2023.d4p1
)
WHERE ARRAY_LENGTH(inter) > 0
