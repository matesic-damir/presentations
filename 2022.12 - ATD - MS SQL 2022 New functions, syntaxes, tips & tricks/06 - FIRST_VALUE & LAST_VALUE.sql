/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* FIRST_VALUE, LAST_VALUE */

USE AdventureWorks2019;
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Dohvati zaposlenike po odjelima i platnim razredima, kada su zaposleni, najmanji i posljednji datum zaposlenja u tom odjelu

;WITH CTE AS (
		SELECT MAX(e1.HireDate) AS LastHireDate, MIN(e1.HireDate) AS FirstHireDate, edh1.Department, eph1.Rate
		FROM HumanResources.vEmployeeDepartmentHistory AS edh1 
		INNER JOIN HumanResources.EmployeePayHistory AS eph1   
		ON eph1.BusinessEntityID = edh1.BusinessEntityID  
		INNER JOIN HumanResources.Employee AS e1  
		ON e1.BusinessEntityID = edh1.BusinessEntityID
		GROUP BY
		edh1.Department, eph1.Rate
)
SELECT 
	edh.Department, edh.LastName, eph.Rate, e.HireDate
	, CTE.FirstHireDate, CTE.LastHireDate
FROM 
	HumanResources.vEmployeeDepartmentHistory AS edh  
	INNER JOIN HumanResources.EmployeePayHistory AS eph    
		ON eph.BusinessEntityID = edh.BusinessEntityID  
	INNER JOIN HumanResources.Employee AS e  
		ON e.BusinessEntityID = edh.BusinessEntityID
	LEFT JOIN CTE ON CTE.Department = edh.Department AND CTE.Rate = eph.Rate
ORDER BY edh.Department, eph.Rate;    

SELECT 
	edh.Department, edh.LastName, eph.Rate, e.HireDate
    , FIRST_VALUE(e.HireDate) OVER (PARTITION BY edh.Department ORDER BY eph.Rate) AS FirsttHireDate  
	, LAST_VALUE(e.HireDate) OVER (PARTITION BY edh.Department ORDER BY eph.Rate) AS LastHireDate  
FROM 
	HumanResources.vEmployeeDepartmentHistory AS edh  
	INNER JOIN HumanResources.EmployeePayHistory AS eph    
		ON eph.BusinessEntityID = edh.BusinessEntityID  
	INNER JOIN HumanResources.Employee AS e  
		ON e.BusinessEntityID = edh.BusinessEntityID
ORDER BY edh.Department, eph.Rate;  



-- Zaposlenik s namanje godišnjih odmora unutar jednog odjela
SELECT JobTitle, LastName, VacationHours,   
       FIRST_VALUE(LastName) OVER W AS FewestVacationHours  
FROM HumanResources.Employee AS e  
INNER JOIN Person.Person AS p   
    ON e.BusinessEntityID = p.BusinessEntityID  
WINDOW W AS (PARTITION BY JobTitle ORDER BY VacationHours ASC ROWS UNBOUNDED PRECEDING  )
ORDER BY JobTitle, LastName;  