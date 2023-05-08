--1.Wybieram mecze ekstraklasy, intersujące mnie kolumny, które nie posiadają wartości null
--SELECT field1, Home, Away, round, date, time, H_Score as 'Home Goals', A_Score as 'Away Score',H_Score - A_Score as 'Różnica bramek', WIN, H_BET, X_BET, A_BET, WIN_BET FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' AND H_BET IS NOT NULL
--2.Porządkuje kursy malejąco, nie uwzględniam remisów, wypisuje kto był zwycięscą meczu)
--Select 	Home, 
		--Away, 
		--WIN_BET
		--WIN,
			--IIF(WIN='Home', Home, Away) AS 'Winner'
		
		--FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' AND H_BET IS NOT NULL AND WIN_BET > 3.0 AND WIN IS NOT 'Draw'
--ORDER by WIN_BET DESC
--3.Sprawdzam, który klub najczęściej sprawiał niespodziankę, (przyjmuję, że jest się underdogiem gdy ma się kurs większy niż 3.0)
--Select count(WIN),
	--IIF(WIN='Home', Home, Away) AS 'Winner'
		
		--FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' AND H_BET IS NOT NULL AND WIN_BET > 3.0 AND WIN IS NOT 'Draw'
--GROUP BY WINNER
--ORDER BY count(WIN) DESC
--4. Sprawdzam kto jako faworyt najczęsniej przegrywał, nie uwzględniam remisów, (przyjmuję, że jest się faworytem gdy przeciwnik ma kurs większy niż 3.0)
--Select count(WIN),
	--IIF(WIN='Home', Away, Home) AS 'Przegrany'
		
		--FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' AND H_BET IS NOT NULL AND WIN_BET > 3.0 AND WIN IS NOT 'Draw'
--GROUP BY Przegrany
--ORDER BY count(WIN) DESC
--5. Sprawdzam jakie drużyny najczęściej międzysobą remisowały gdy ich remis był mało prawdopodobny (do tego przyjąłem kurs na remis większy niż 3.5)
--Select
	--Home,
	--Away,
	--count(WIN)
	--FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' AND H_BET IS NOT NULL AND WIN_BET > 3.5 AND WIN IS 'Draw'
--GROUP BY Home, Away
--ORDER BY count(WIN) DESC
--6. Sprawdzam jaki był średni kurs zwycięscy meczu
--SELECT AVG(WIN_BET) AS 'SREDNI KURS' FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' AND WIN IS NOT 'Draw'
--7. Sprawdzam średni kurs remisu
--SELECT AVG(WIN_BET) AS 'SREDNI KURS' FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' AND WIN IS 'Draw'
--8. Sprawdzam na jakie zespoły kurs był największy w meczach domowych
--SELECT Home,AVG(H_BET) FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' and H_BET IS NOT NULL
--Group by Home
--ORDER BY AVG(H_BET) DESC
--9. Sprawdzam na jakie zespoły kurs był największy w meczach wyjazdowych
--SELECT Away,AVG(A_BET) FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' and A_BET IS NOT NULL
--Group by Away
--ORDER BY AVG(A_BET) DESC
--10. Tworzę tabele zespołów zliczając ich punkty zdobye w meczach domowych korelując z nimi ich średni kurs

--SELECT
   -- Home,
    --SUM(CASE
       -- WHEN WIN = 'Home' THEN 3
       -- WHEN WIN = 'Draw' THEN 1
       -- ELSE 0
   -- END) AS punkty_gospodarz,
	--round(AVG(Win_Bet),2) AS 'Sredni kurs'
--FROM full_data
--WHERE League = 'pko-bp-ekstraklasa'
--GROUP BY Home
--Order by punkty_gospodarz DESC
--10. Tworzę tabele zespołów zliczając ich punkty zdobye w meczach wyjazdowych korelując z nimi ich średni kurs
--SELECT Away,
    --SUM(CASE
        --WHEN WIN = 'Away' THEN 3
        --WHEN WIN = 'Draw' THEN 1
        --ELSE 0
   -- END) AS punkty_gosc,
	--round(AVG(Win_Bet),2) AS 'Srednikurs'
--FROM full_data
--WHERE League = 'pko-bp-ekstraklasa' and WIN_BET IS NOT NULL
--GROUP BY Away
--Order by punkty_gosc DESC
--11. Staram się stworzyć tabelę wszechczasów z korelacją średniego kursu

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






