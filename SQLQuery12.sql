SELECT * 
FROM Production.Product;


SELECT [Name], ProductNumber, ListPrice as Price
FROM Production.Product


SELECT *
FROM HumanResources.Employee
WHERE HireDate > PARSE('2009-01-01' as date) ;


SELECT *
FROM Production.Product
WHERE ProductLine = 'S' and DaysToManufacture < 5
ORDER BY ProductID


SELECT DISTINCT JobTitle 
FROM HumanResources.Employee


SELECT SalesOrderID, SUM(OrderQty) as totalQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID


SELECT ProductModelID
FROM Production.Product
WHERE ListPrice > 900
GROUP BY ProductModelID


SELECT AVG(OrderQty) as avgOrderQty
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING AVG(OrderQty) <= 4

GO  
IF OBJECT_ID('dbo.uspGetEmployeeManagersPerDepartment', 'P') IS NOT NULL  
   DROP PROCEDURE dbo.uspGetEmployeeManagersPerDepartment;
GO
CREATE PROCEDURE uspGetEmployeeManagersPerDepartment
	@BusinessEntityID INTEGER,
	@Department VARCHAR	
AS
SELECT employee.BusinessEntityID, employee.FirstName, employee.LastName, employee.JobTitle, 
	manager.Gender as ManagerGender, manager.FirstName as ManagerFirstName, manager.LastName as ManagerLastName
FROM
	(SELECT p.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle, d.DepartmentID
		FROM Person.Person p
			inner join HumanResources.EmployeeDepartmentHistory h ON p.BusinessEntityID = h.BusinessEntityID
			inner join HumanResources.Department d ON h.DepartmentID = d.DepartmentID
			inner join HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
		WHERE p.BusinessEntityID = @BusinessEntityID
		 and d.[Name] = @Department
		 ) employee
		right join
	(SELECT e.Gender, p.FirstName, p.LastName, d.DepartmentID
		FROM HumanResources.Department d
			inner join HumanResources.EmployeeDepartmentHistory h 
			ON d.DepartmentID = h.DepartmentID
			inner join HumanResources.Employee e
			ON h.BusinessEntityID = e.BusinessEntityID
			inner join Person.Person p
			ON p.BusinessEntityID = h.BusinessEntityID
		WHERE d.[Name] = @Department
		 and e.JobTitle like '%Manager%') manager
	ON employee.DepartmentID = manager.DepartmentID

RETURN
GO

GO
EXEC dbo.uspGetEmployeeManagersPerDepartment @BusinessEntityID = 2, @Department = 'Engineering';

select *
from 
(SELECT p.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle, d.DepartmentID
		FROM Person.Person p
			inner join HumanResources.EmployeeDepartmentHistory h ON p.BusinessEntityID = h.BusinessEntityID
			inner join HumanResources.Department d ON h.DepartmentID = d.DepartmentID
			inner join HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
		WHERE p.BusinessEntityID = 2 and d.[Name] = 'Engineering') employe
		right join
(SELECT e.Gender, p.FirstName, p.LastName, d.DepartmentID
		FROM HumanResources.Department d
			inner join HumanResources.EmployeeDepartmentHistory h 
			ON d.DepartmentID = h.DepartmentID
			inner join HumanResources.Employee e
			ON h.BusinessEntityID = e.BusinessEntityID
			inner join Person.Person p
			ON p.BusinessEntityID = h.BusinessEntityID
		WHERE d.[Name] = 'Engineering'
		 and e.JobTitle like '%Manager%') dep
		 on employe.DepartmentID = dep.DepartmentID
