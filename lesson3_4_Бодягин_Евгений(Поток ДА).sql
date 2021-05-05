--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task13 (lesson3)
--Компьютерная фирма: Вывести список всех продуктов и производителя с указанием типа продукта (pc, printer, laptop). Вывести: model, maker, type
SELECT pr.model, maker, pr.type
from pc
join product pr
on pc.model = pr.model
union
SELECT pr.model, maker, pr.type
from printer pt
join product pr
on pt.model = pr.model
union
SELECT pr.model, maker, pr.type
from laptop lt
join product pr
on lt.model = pr.model
--task14 (lesson3)
--Компьютерная фирма: При выводе всех значений из таблицы printer дополнительно вывести для тех, у кого цена вышей средней PC - "1", у остальных - "0"
SELECT *, case
when price > (select avg(price) from pc)
then 1
else 0
end flag_price_more_avg
from printer
--task15 (lesson3)
--Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL)
SELECT ship
from outcomes
full join ships
on outcomes.ship = ships.name
where class is null
--task16 (lesson3)
--Корабли: Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду.
SELECT name
from battles
where extract(year from date) is not null and extract(year from date) not in (select launched from ships)
--task17 (lesson3)
--Корабли: Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.
SELECT battle 
from outcomes ot
join ships sh
on ot.ship = sh.name
where class = 'Kongo'
--task1  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_300) для всех товаров (pc, printer, laptop) с флагом, если стоимость больше > 300. Во view три колонки: model, price, flag
create or replace view all_products_flag_300 as 
	SELECT model, price, case when price > 300 then 1 else 0 end flag
	from pc
	union all
	SELECT model, price, case when price > 300 then 1 else 0 end flag
	from laptop
	union all
	SELECT model, price, case when price > 300 then 1 else 0 end flag
	from printer

--task2  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_avg_price) для всех товаров (pc, printer, laptop) с флагом, если стоимость больше cредней . Во view три колонки: model, price, flag
create view all_products_flag_avg_price as 
	SELECT model, price, case when price > (select avg(price) from pc) then 1 else 0 end flag
	from pc
	union all
	SELECT model, price, case when price > (select avg(price) from laptop) then 1 else 0 end flag
	from laptop
	union all
	SELECT model, price, case when price > (select avg(price) from printer) then 1 else 0 end flag
	from printer
--task3  (lesson4)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. Вывести model
SELECT printer.model 
from printer
join product
using(model)
where maker = 'A' and price > (select avg(price) from printer join product
using(model) where maker in ('D','C'))
--task4 (lesson4)
-- Компьютерная фирма: Вывести все товары производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. Вывести model
	SELECT model, product.type
	from printer
	join product
	using(model)
	where maker = 'A' and price > 
		(select avg(price) from printer join product
		using(model) where maker in ('D','C'))
union
	SELECT model, product.type 
	from pc
	join product
	using(model)
	where maker = 'A' and price > 
		(select avg(price) from printer join product
		using(model) where maker in ('D','C'))
union
	SELECT model, product.type 
	from laptop l 
	join product
	using(model)
	where maker = 'A' and price > 
		(select avg(price) from printer join product
		using(model) where maker in ('D','C'))
order by type
--task5 (lesson4)
-- Компьютерная фирма: Какая средняя цена среди уникальных продуктов производителя = 'A' (printer & laptop & pc)
select avg(price) from 

(select pc.price from pc
where model in
(select distinct model from product 
where maker='A')
union all
select printer.price from printer
where model in
(select distinct model from product 
where maker='A')
union all
select laptop.price from laptop
where model in
(select distinct model from product 
where maker='A')) as prrr
--task6 (lesson4)
-- Компьютерная фирма: Сделать view с количеством товаров (название count_products_by_makers) по каждому производителю. Во view: maker, count
create view count_products_by_makers as
		select maker, sum(count)
		from (SELECT maker, count(code)
		from pc 
		join product using(model)
		group by maker
	union 
		SELECT maker, count(code)
		from laptop 
		join product using(model)
		group by maker
	union
		SELECT maker, count(code)
		from printer 
		join product using(model)
		group by maker) as foo
		group by maker
--task7 (lesson4)
-- По предыдущему view (count_products_by_makers) сделать график в colab (X: maker, y: count)
"решение представлено в коллабе"
--task8 (lesson4)
-- Компьютерная фирма: Сделать копию таблицы printer (название printer_updated) и удалить из нее все принтеры производителя 'D'
create table printer_updated as
	SELECT *
	from printer
	where model not in (select model from product where maker = 'D')
--task9 (lesson4)
-- Компьютерная фирма: Сделать на базе таблицы (printer_updated) view с дополнительной колонкой производителя (название printer_updated_with_makers)
create or replace view printer_updated_with_makers as
	select printer_updated.*, maker
	from printer_updated
	join product
	using(model)
	
--task10 (lesson4)
-- Корабли: Сделать view c количеством потопленных кораблей и классом корабля (название sunk_ships_by_classes). Во view: count, class (если значения класса нет/IS NULL, то заменить на 0)
create view sunk_ships_by_classes as
	SELECT count(ship), coalesce(class, '0') AS class
	from outcomes
	full join ships
	on outcomes.ship = ships.name
	where result = 'sunk'
	group by class
--task11 (lesson4)
-- Корабли: По предыдущему view (sunk_ships_by_classes) сделать график в colab (X: class, Y: count)
"решение представлено в коллабе"
--task12 (lesson4)
-- Корабли: Сделать копию таблицы classes (название classes_with_flag) и добавить в нее flag: если количество орудий больше или равно 9 - то 1, иначе 0
create table classes_with_flag as
	select *, case when numguns >= 9 then 1 else 0 end flag
	from classes
--task13 (lesson4)
-- Корабли: Сделать график в colab по таблице classes с количеством классов по странам (X: country, Y: count)
"решение представлено в коллабе"
--task14 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название начинается с буквы "O" или "M".
select count(ship)
from outcomes
where ship like 'O%' or ship like 'M%'
--task15 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название состоит из двух слов.
select count(ship)
from outcomes
where (ship like '% %' or ship like '% %') and ship not like '% % %'
--task16 (lesson4)
-- Корабли: Построить график с количеством запущенных на воду кораблей и годом запуска (X: year, Y: count)
"решение представлено в коллабе"