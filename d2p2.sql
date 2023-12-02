CREATE TEMP FUNCTION do(line STRING) AS ((
  SELECT ROUND(EXP(SUM(LN(count))))
  FROM (
    SELECT SPLIT(m, ' ')[1] AS color, MAX(CAST(SPLIT(m, ' ')[0] AS INT64)) AS count
    FROM UNNEST(REGEXP_EXTRACT_ALL(line, r'\d+\s\w+')) m
    GROUP BY 1
  )
));

SELECT SUM(do(line))
FROM aoc2023.d2p2
