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

--CREATE VIEW Tabela_wszechczasów as
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
WITH CTE1 AS(
SELECT Home,
Sum(H_score)as 'dom'
FROM full_data
WHERE League = 'pko-bp-ekstraklasa'
GROUP BY Home
ORDER BY Sum(H_score) DESC
),
CTE2 AS 
(SELECT Away,
Sum(A_score) as 'wyjazd'
FROM full_data
WHERE League = 'pko-bp-ekstraklasa'
GROUP BY Away
ORDER BY Sum(A_score) DESC)

SELECT Home, dom + wyjazd as 'gole'
FROM CTE1 JOIN CTE2 ON CTE1.HOME = CTE2.AWAY
Limit 10;



--CREATE VIEW Liczba_meczy1 as

--SELECT HOME, COUNT(Home) + COUNT(Away) AS 'Liczba' FLOAT
--FROM full_data
--WHERE League = 'pko-bp-ekstraklasa'
--GROUP BY Home;
-- 5.Top 10 średnia punktów na mecz
SELECT Home,  ROUND(Punkty * 1.0 / liczba * 1.0 ,2) AS 'srednia'
from Liczba_meczy1 JOIN Tabela_wszechczasów ON Liczba_meczy1.Home = Tabela_wszechczasów.druzyna
Order by Punkty * 1.0 / liczba * 1.0 DESC
LIMIT 10

--6. Obstawiając 100 zł, na którym zespole można było zarobić najwięcej (dla uproszczenia bez podatków i bez uwzględnienia meczów, które byśmy obstawili a drużyna przegrała, jest to duże uproszczenie, ale dalej infromacja ta wydaje sie dość istotna bo w jej wyszukaniach znajdują się niespodzianki)

SELECT Home, (sredni_kurs * 100 * liczba) as 'wygrana'
from Liczba_meczy1 JOIN Tabela_wszechczasów ON Liczba_meczy1.Home = Tabela_wszechczasów.druzyna
Order by wygrana DESC
Limit 10

-- lub z podatkiem i zrobione bardziej rzetelnie (podatek to 12% od zakładu dlatego mnożnik wynosi 88, zakładam, że obastawiamy 100 zł)

WITH CTE3 AS(
SELECT HOME, 
SUM( CASE
WHEN WIN = 'Home' THEN WIN_BET * 88
ELSE  -100
END) AS 'Potencjalna_wygranaH'
FROM full_data
WHERE League = 'pko-bp-ekstraklasa' AND WIN_BET IS NOT NULL
Group by Home
Order by Potencjalna_wygranaH DESC ),
CTE4 AS(
SELECT Away, 
SUM( CASE
WHEN WIN = 'Away' THEN WIN_BET * 88
ELSE  -100
END) AS 'Potencjalna_wygranaA'
FROM full_data
WHERE League = 'pko-bp-ekstraklasa' AND WIN_BET IS NOT NULL
Group by Away
Order by Potencjalna_wygranaA DESC )


SELECT Home, (Potencjalna_wygranaH + Potencjalna_wygranaA) AS 'Wygrana'
FROM CTE3 JOIN CTE4 ON CTE3.Home = CTE4.Away 
Order by Wygrana DESC

SELECT Home, date
FROM full_data
WHERE  (date LIKE '%2021' or date LIKE '%2022' or date LIKE '%2020') AND League = 'pko-bp-ekstraklasa' 
-- Sprawdzam to samo z ostatnich 3 dostępnych sezonów
WITH CTE3 AS(
SELECT HOME, 
SUM( CASE
WHEN WIN = 'Home' THEN WIN_BET * 88
ELSE  -100
END) AS 'Potencjalna_wygranaH'
FROM full_data
WHERE League = 'pko-bp-ekstraklasa' AND WIN_BET IS NOT NULL AND(date LIKE '%2021' or date LIKE '%2022' or date LIKE '%2020')
Group by Home
Order by Potencjalna_wygranaH DESC ),
CTE4 AS(
SELECT Away, 
SUM( CASE
WHEN WIN = 'Away' THEN WIN_BET * 88
ELSE  -100
END) AS 'Potencjalna_wygranaA'
FROM full_data
WHERE League = 'pko-bp-ekstraklasa' AND WIN_BET IS NOT NULL AND(date LIKE '%2021' or date LIKE '%2022' or date LIKE '%2020')
Group by Away
Order by Potencjalna_wygranaA DESC )


SELECT Home, (Potencjalna_wygranaH + Potencjalna_wygranaA) AS 'Wygrana'
FROM CTE3 JOIN CTE4 ON CTE3.Home = CTE4.Away 
Order by Wygrana DESC