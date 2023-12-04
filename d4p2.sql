CREATE TEMP FUNCTION intersection(a ANY TYPE, b ANY TYPE) AS ((
  SELECT ARRAY_AGG(i) FROM UNNEST(a) i JOIN UNNEST(b) j ON i = j
));

CREATE TEMP FUNCTION parse(line STRING) AS (
  STRUCT(
    CAST(REGEXP_EXTRACT(line, r'Card\s+(\d+)') AS INT64) AS card,
    REGEXP_EXTRACT_ALL(SPLIT(SPLIT(line, ':')[1], '|')[0], r'\d+') AS winning,
    REGEXP_EXTRACT_ALL(SPLIT(SPLIT(line, ':')[1], '|')[1], r'\d+') AS candidates
  )
);

WITH RECURSIVE input AS (
  SELECT parse(line).*
  FROM aoc2023.d4p2
), cards AS (
  SELECT card, ARRAY_LENGTH(intersection(winning, candidates)) matches
  FROM input
), rec AS (
  SELECT 1 AS n, card, matches
  FROM cards

  UNION ALL

  SELECT n + 1, i.card, i.matches
  FROM rec r
  JOIN cards i ON i.card BETWEEN r.card + 1 AND r.card + r.matches
)
SELECT COUNT(*)
FROM rec
