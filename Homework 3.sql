USE Northwind
GO

--1. List all cities that have both Employees and Customers.
SELECT DISTINCT E.City
FROM Employees E
WHERE E.City in (
	SELECT C.City
	FROM Customers C)

--2. List all cities that have Customers but no Employee.
--a. Use sub-query
SELECT DISTINCT C.City
FROM Customers C
WHERE C.City NOT in (
	SELECT E.City
	FROM Employees E)
ORDER BY C.City

--2. List all cities that have Customers but no Employee.
--b. Do not use sub-query
SELECT DISTINCT C.City
FROM Customers C
LEFT JOIN Employees E ON C.City=E.City
WHERE E.EmployeeID is Null
ORDER BY C.City

--3. List all products and their total order quantities throughout all orders.
SELECT P.ProductName, SUM(O.Quantity)AS 'Order Quantities'
FROM Products P
LEFT JOIN [Order Details]O ON P.ProductID=O.ProductID
GROUP BY P.ProductName
ORDER BY P.ProductName

--4. List all Customer Cities and total products ordered by that city.
SELECT C.City AS 'Customer Cities',ISNULL(SUM(Q.Quantity),0) AS 'Total Products Ordered'
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID=O.CustomerID
LEFT JOIN [Order Details] Q ON O.OrderID=Q.OrderID
GROUP BY C.City
ORDER BY C.City

--5. List all Customer Cities that have at least two customers.
--a. Use union
SELECT C.City
FROM Customers C
GROUP BY C.City
HAVING COUNT(C.City)=2
UNION
SELECT C.City
FROM Customers C
GROUP BY C.City
HAVING COUNT(C.City)>2

--5. List all Customer Cities that have at least two customers.
--b. Use sub-query and no union
SELECT DISTINCT K.City
FROM Customers K
WHERE K.City NOT in (
	SELECT C.City
	FROM Customers C
	GROUP BY C.City
	HAVING COUNT(C.City)=1)
ORDER BY K.City

--6. List all Customer Cities that have ordered at least two different kinds of products.
SELECT C.City
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID=O.CustomerID
LEFT JOIN [Order Details] Q ON O.OrderID=Q.OrderID
WHERE Q.ProductID is NOT Null
GROUP BY C.City
HAVING COUNT(DISTINCT Q.ProductID)>1
ORDER BY C.City

--7. List all Customers who have ordered products, but have the ¡®ship city¡¯ on the order different from their own customer cities.
SELECT DISTINCT C.ContactName
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID=O.CustomerID
WHERE (C.City != O.ShipCity) AND (O.ShipCity is NOT Null)

--8. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
SELECT S.ProductName,S.City,S.[Average Price]
FROM(
	SELECT H.ProductName,E.City,AVG(G.UnitPrice)AS 'Average Price',Rank() over(PARTITION BY H.ProductName ORDER BY Sum(G.Quantity)DESC)[Rank]
	FROM Customers E
	LEFT JOIN Orders F ON E.CustomerID=F.CustomerID
	LEFT JOIN [Order Details] G ON F.OrderID=G.OrderID
	LEFT JOIN Products H ON G.ProductID=H.ProductID
	WHERE H.ProductName in (
		SELECT top 5 P.ProductName
		FROM Customers C
		LEFT JOIN Orders O ON C.CustomerID=O.CustomerID
		LEFT JOIN [Order Details] Q ON O.OrderID=Q.OrderID
		LEFT JOIN Products P ON Q.ProductID=P.ProductID
		WHERE P.ProductName is NOT Null
		GROUP BY P.ProductName
		ORDER BY Sum(Q.Quantity)DESC)
	GROUP BY H.ProductName,E.City)S
WHERE [Rank]=1
ORDER BY S.ProductName

--9. List all cities that have never ordered something but we have employees there.
--a. Use sub-query
SELECT E.City
FROM Employees E
WHERE E.City NOT in (
	SELECT C.City
	FROM Customers C
	LEFT JOIN Orders O ON C.CustomerID=O.CustomerID
	LEFT JOIN [Order Details] Q ON O.OrderID=Q.OrderID
	GROUP BY C.City
	HAVING SUM(Q.Quantity)>0 )

--9. List all cities that have never ordered something but we have employees there.
--b. Do not use sub-query
SELECT E.City
FROM Employees E
EXCEPT
SELECT C.City
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID=O.CustomerID
LEFT JOIN [Order Details] Q ON O.OrderID=Q.OrderID
GROUP BY C.City
HAVING SUM(Q.Quantity)>0

--10. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
SELECT S.Employee_Name,S.ShipCity
FROM(
	SELECT (E.FirstName+' '+E.LastName)AS 'Employee_Name',O.ShipCity,
		   Rank() over(PARTITION BY (E.FirstName+' '+E.LastName) ORDER BY COUNT(O.OrderID)DESC)[Rank1],
		   Rank() over(PARTITION BY (E.FirstName+' '+E.LastName) ORDER BY SUM(Q.Quantity)DESC)[Rank2]
	FROM Employees E
	LEFT JOIN Orders O ON E.EmployeeID=O.EmployeeID
	LEFT JOIN [Order Details] Q ON O.OrderID=Q.OrderID
	GROUP BY (E.FirstName+' '+E.LastName),O.ShipCity)S
WHERE S.Rank1=1 AND S.Rank2=1

--11. How do you remove the duplicates record of a table?

--I can use GROUP BY and HAVING COUNT()>1,or use RANK(),or use CTE.