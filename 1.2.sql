--1. Wykazać TOP 10 drużyn, które wygrywają jako underdog (kurs > 3.0)
Select count(WIN) AS 'Liczba meczy',
	IIF(WIN='Home', Home, Away) AS 'Zwyciesca'
		
		FROM full_data
WHERE League = 'pko-bp-ekstraklasa' AND H_BET IS NOT NULL AND WIN_BET > 3.0 AND WIN IS NOT 'Draw'
GROUP BY WINNER
ORDER BY count(WIN) DESC
LIMIT 10;
--2. Wykazać TOP 10 drużyn, które przegrywają jako faworyt (gdy przeciwnik miał kurs > 3.0)
Select count(WIN) AS 'Liczba meczy',
	IIF(WIN='Home', Away, Home) AS 'Przegrany'
		
		FROM full_data
WHERE League = 'pko-bp-ekstraklasa' AND H_BET IS NOT NULL AND WIN_BET > 3.0 AND WIN IS NOT 'Draw'
GROUP BY Przegrany
ORDER BY count(WIN) DESC
LIMIT 10;
--3. Tabela wszechczasów TOP 10 u siebie na wyjeździe i ogólnie.


SELECT druzyna,
    SUM(punkty_dom) AS suma_punktow_dom,
    SUM(punkty_gosc) AS suma_punktow_gosc,
	SUM(punkty_dom) + SUM (punkty_gosc) AS 'Punkty',
	
	
    ROUND(AVG(SredniKurs), 2) AS sredni_kurs
FROM (
    SELECT Home AS druzyna,
        SUM(CASE
            WHEN WIN = 'Home' THEN 3
            WHEN WIN = 'Draw' THEN 1
            ELSE 0
        END) AS punkty_dom,
        NULL AS punkty_gosc,
        Win_Bet AS SredniKurs
    FROM full_data
    WHERE League = 'pko-bp-ekstraklasa' AND WIN_BET IS NOT NULL
    GROUP BY Home

    UNION ALL

    SELECT Away AS druzyna,
        NULL AS punkty_dom,
        SUM(CASE
            WHEN WIN = 'Away' THEN 3
            WHEN WIN = 'Draw' THEN 1
            ELSE 0
        END) AS punkty_gosc,
        Win_Bet AS SredniKurs
    FROM full_data
    WHERE League = 'pko-bp-ekstraklasa' AND WIN_BET IS NOT NULL
    GROUP BY Away
) AS subquery
GROUP BY druzyna
ORDER BY Punkty DESC
LIMIT 10;
--4. Bramki strzelone, stracone, bilans top 10
SELECT Home,
Sum(H_score) as 'liczba goli w domu'
FROM full_data
WHERE League = 'pko-bp-ekstraklasa'
GROUP BY Home
ORDER BY Sum(H_score) DESC
LIMIT 10

SELECT Away,
Sum(A_score) as 'liczba goli w domu'
FROM full_data
WHERE League = 'pko-bp-ekstraklasa'
GROUP BY Away
ORDER BY Sum(A_score) DESC
LIMIT 10