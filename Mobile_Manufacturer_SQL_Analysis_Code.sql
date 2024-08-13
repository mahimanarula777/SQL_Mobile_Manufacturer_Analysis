
--Q1. List all the states in which we have customers who have bought cellphones from 2005 till today. 

with State_list
as (
	select Y.IDCustomer,X.[State], Y.[Date], Sum(Quantity) as Quantity_count from Dim_Location as X
	inner join Fact_Transactions as Y
	on X.IDLocation = Y.IDLocation
	where year(Y.[Date]) > = '2005'
	group by Y.IDCustomer,X.[State], Y.[Date]
) 
select distinct State from State_list

--Q2. What state in the US is buying the most 'Samsung' cell phones? 

select Top 1 State, count(Manufacturer_Name) as Manufacturer_count from Dim_Location as A
inner join Fact_Transactions as B
on A.IDLocation = B.IDLocation
inner join DIM_MODEL as C
on B.IDModel = C.IDModel
inner join DIM_MANUFACTURER as D
on C.IDManufacturer = D.IDManufacturer
where Country = 'US'
and
Manufacturer_Name = 'Samsung'
group by A.State
order by Manufacturer_count desc

--Q3. Show the number of transactions for each model per zip code per state.    

select B.IDModel, A.ZipCode, A.State, count(IDCustomer) as Transaction_count
from Dim_Location as A
inner join Fact_Transactions as B
on A.IDLocation = B.IDLocation
inner join DIM_MODEL as C
on B.IDModel = C.IDModel
group by B.IDModel, A.ZipCode, A.State

--Q4. Show the cheapest cellphone (Output should contain the price also)

select Top 1 IDModel, Model_Name, min(Unit_price) as cheapest_price
from DIM_MODEL
group by IDModel, Model_Name
order by cheapest_price

--Q5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. 

select Manufacturer_Name, A.IDModel, avg(TotalPrice) as Avg_Price, sum(Quantity) as total_quantity
from Fact_Transactions as A
join DIM_MODEL as B on A.IDModel = B.IDModel
join DIM_MANUFACTURER as C on B.IDManufacturer = C.IDManufacturer
where Manufacturer_Name in (
							select top 5 Manufacturer_Name
							from Fact_Transactions as A
							join DIM_MODEL as B on A.IDModel = B.IDModel
							join DIM_MANUFACTURER as C on B.IDManufacturer = C.IDManufacturer
							group by Manufacturer_Name
							order by sum(TotalPrice) desc)
Group by A.IDModel, Manufacturer_Name
order by Avg_Price desc

--Q6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500 

select Customer_Name, avg(TotalPrice) as Avg_amount
from DIM_CUSTOMER as A
join FACT_TRANSACTIONS as B
on A.IDCustomer = B.IDCustomer
where year(Date) = '2009'
group by Customer_Name
having avg(TotalPrice) >500	

--7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010 

Select * 
from (
	Select Top 5 IDModel
	from FACT_TRANSACTIONS
	where year(date) = '2008'
	group by IDModel
	order by sum(Quantity) desc
) as A
Intersect
Select * 
from (
	Select top 5 IDModel
	from FACT_TRANSACTIONS
	where year(date) = '2009'
	group by IDModel
	order by sum(Quantity) desc
) as B
Intersect
Select *
from (
	Select Top 5 IDModel
	from FACT_TRANSACTIONS
	where year(date) = '2010'
	group by IDModel
	order by sum(Quantity) desc
) as C

--Q8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010. 

with top2sales
as (
	select *, dense_rank() over (partition by years order by sales desc) as ranks1
	from (
		select Manufacturer_Name, sum(TotalPrice) as Sales, year(Date) as years
		from Fact_Transactions as A
		join DIM_MODEL as B on A.IDModel = B.IDModel
		join DIM_MANUFACTURER as C on B.IDManufacturer = C.IDManufacturer
		where year(Date) in ('2009', '2010')
		group by Manufacturer_Name, year(Date)
	) as X
) 
select * from top2sales
where ranks1 = 2

--Q9. Show the manufacturers that sold cellphones in 2010 but did not in 2009. 

select Manufacturer_Name
from Fact_Transactions as A
join DIM_MODEL as B on A.IDModel = B.IDModel
join DIM_MANUFACTURER as C on B.IDManufacturer = C.IDManufacturer
where year(date) = '2010'
Except
select Manufacturer_Name
from Fact_Transactions as A
join DIM_MODEL as B on A.IDModel = B.IDModel
join DIM_MANUFACTURER as C on B.IDManufacturer = C.IDManufacturer
where year(date) = '2009'

----------------------------------------------------------------Thank You-------------------------------------------------------------