-- Task4
-- Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом (поле special_features) равным “Behind the Scenes”.
SELECT * FROM film WHERE 'Behind the Scenes' = ALL (special_features);
-- Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, используя другие функции или операторы языка SQL для поиска значения в массиве.
SELECT * FROM film WHERE 'Behind the Scenes' = ANY (special_features);
SELECT * FROM film WHERE special_features && ARRAY['Behind the Scenes'];
-- Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
-- Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.
with films as (SELECT * FROM film WHERE 'Behind the Scenes' = ALL (special_features))
select rental.customer_id, count(films.film_id) from films, inventory, rental
where films.film_id = inventory.film_id and inventory.inventory_id = rental.inventory_id
group by rental.customer_id
order by rental.customer_id;
-- Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
-- Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в подзапрос, который необходимо использовать для решения задания.
select rental.customer_id, count(films.film_id) from 
(SELECT * FROM film WHERE 'Behind the Scenes' = ALL (special_features)) as films, inventory, rental
where films.film_id = inventory.film_id and inventory.inventory_id = rental.inventory_id
group by rental.customer_id
order by rental.customer_id;
-- Задание 5. Создайте материализованное представление с запросом из предыдущего задания и напишите запрос для обновления материализованного представления.
CREATE MATERIALIZED VIEW count_of_films
AS
select rental.customer_id, count(films.film_id) from 
(SELECT * FROM film WHERE 'Behind the Scenes' = ALL (special_features)) as films, inventory, rental
where films.film_id = inventory.film_id and inventory.inventory_id = rental.inventory_id
group by rental.customer_id
order by rental.customer_id
WITH DATA;

REFRESH MATERIALIZED VIEW count_of_films;

select * from count_of_films;

-- Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:
-- с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значения в массиве происходит быстрее;
-- какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.
explain analyze SELECT * FROM film WHERE 'Behind the Scenes' = ALL (special_features);
-- "Seq Scan on film  (cost=0.00..77.50 rows=69 width=386) (actual time=0.036..0.335 rows=70 loops=1)"
-- "  Filter: ('Behind the Scenes'::text = ALL (special_features))"
-- "  Rows Removed by Filter: 930"
-- "Planning Time: 0.127 ms"
-- "Execution Time: 0.361 ms"
explain analyze SELECT * FROM film WHERE 'Behind the Scenes' = ANY (special_features);
-- "Seq Scan on film  (cost=0.00..77.50 rows=538 width=386) (actual time=0.022..0.406 rows=538 loops=1)"
-- "  Filter: ('Behind the Scenes'::text = ANY (special_features))"
-- "  Rows Removed by Filter: 462"
-- "Planning Time: 0.145 ms"
-- "Execution Time: 0.445 ms"
explain analyze SELECT * FROM film WHERE special_features && ARRAY['Behind the Scenes'];
-- "Seq Scan on film  (cost=0.00..67.50 rows=538 width=386) (actual time=0.021..0.481 rows=538 loops=1)"
-- "  Filter: (special_features && '{""Behind the Scenes""}'::text[])"
-- "  Rows Removed by Filter: 462"
-- "Planning Time: 0.127 ms"
-- "Execution Time: 0.516 ms"

explain analyze with films as (SELECT * FROM film WHERE 'Behind the Scenes' = ALL (special_features))
select rental.customer_id, count(films.film_id) from films, inventory, rental
where films.film_id = inventory.film_id and inventory.inventory_id = rental.inventory_id
group by rental.customer_id
order by rental.customer_id;
-- "Sort  (cost=373.65..375.14 rows=599 width=10) (actual time=2.950..2.978 rows=514 loops=1)"
-- "  Sort Key: rental.customer_id"
-- "  Sort Method: quicksort  Memory: 53kB"
-- "  ->  HashAggregate  (cost=340.02..346.01 rows=599 width=10) (actual time=2.771..2.853 rows=514 loops=1)"
-- "        Group Key: rental.customer_id"
-- "        Batches: 1  Memory Usage: 105kB"
-- "        ->  Nested Loop  (cost=78.65..335.74 rows=857 width=6) (actual time=0.410..2.499 rows=1114 loops=1)"
-- "              ->  Hash Join  (cost=78.36..161.25 rows=316 width=8) (actual time=0.390..1.126 rows=319 loops=1)"
-- "                    Hash Cond: (inventory.film_id = film.film_id)"
-- "                    ->  Seq Scan on inventory  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.024..0.341 rows=4581 loops=1)"
-- "                    ->  Hash  (cost=77.50..77.50 rows=69 width=4) (actual time=0.329..0.330 rows=70 loops=1)"
-- "                          Buckets: 1024  Batches: 1  Memory Usage: 11kB"
-- "                          ->  Seq Scan on film  (cost=0.00..77.50 rows=69 width=4) (actual time=0.032..0.317 rows=70 loops=1)"
-- "                                Filter: ('Behind the Scenes'::text = ALL (special_features))"
-- "                                Rows Removed by Filter: 930"
-- "              ->  Index Scan using idx_fk_inventory_id on rental  (cost=0.29..0.51 rows=4 width=6) (actual time=0.002..0.004 rows=3 loops=319)"
-- "                    Index Cond: (inventory_id = inventory.inventory_id)"
-- "Planning Time: 0.640 ms"
-- "Execution Time: 3.043 ms"

explain analyze select rental.customer_id, count(films.film_id) from 
(SELECT * FROM film WHERE 'Behind the Scenes' = ALL (special_features)) as films, inventory, rental
where films.film_id = inventory.film_id and inventory.inventory_id = rental.inventory_id
group by rental.customer_id
order by rental.customer_id;
-- "Sort  (cost=373.65..375.14 rows=599 width=10) (actual time=3.523..3.558 rows=514 loops=1)"
-- "  Sort Key: rental.customer_id"
-- "  Sort Method: quicksort  Memory: 53kB"
-- "  ->  HashAggregate  (cost=340.02..346.01 rows=599 width=10) (actual time=3.339..3.417 rows=514 loops=1)"
-- "        Group Key: rental.customer_id"
-- "        Batches: 1  Memory Usage: 105kB"
-- "        ->  Nested Loop  (cost=78.65..335.74 rows=857 width=6) (actual time=0.478..3.001 rows=1114 loops=1)"
-- "              ->  Hash Join  (cost=78.36..161.25 rows=316 width=8) (actual time=0.445..1.301 rows=319 loops=1)"
-- "                    Hash Cond: (inventory.film_id = film.film_id)"
-- "                    ->  Seq Scan on inventory  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.016..0.363 rows=4581 loops=1)"
-- "                    ->  Hash  (cost=77.50..77.50 rows=69 width=4) (actual time=0.393..0.394 rows=70 loops=1)"
-- "                          Buckets: 1024  Batches: 1  Memory Usage: 11kB"
-- "                          ->  Seq Scan on film  (cost=0.00..77.50 rows=69 width=4) (actual time=0.025..0.376 rows=70 loops=1)"
-- "                                Filter: ('Behind the Scenes'::text = ALL (special_features))"
-- "                                Rows Removed by Filter: 930"
-- "              ->  Index Scan using idx_fk_inventory_id on rental  (cost=0.29..0.51 rows=4 width=6) (actual time=0.002..0.004 rows=3 loops=319)"
-- "                    Index Cond: (inventory_id = inventory.inventory_id)"
-- "Planning Time: 0.534 ms"
-- "Execution Time: 3.627 ms"

explain analyze select * from count_of_films;
-- "Seq Scan on count_of_films  (cost=0.00..8.14 rows=514 width=10) (actual time=0.017..0.053 rows=514 loops=1)"
-- "Planning Time: 0.180 ms"
-- "Execution Time: 0.082 ms"



-- Дополнительная часть
-- Задание 7. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
select distinct staff_id, min(payment_date) over(partition by staff_id) from payment;

-- Задание 8. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- •	день, в который арендовали больше всего фильмов (в формате год-месяц-день);
-- •	количество фильмов, взятых в аренду в этот день;
-- •	день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
-- •	сумму продажи в этот день.
select * from (
select distinct store.store_id, to_char(payment.payment_date, 'yyyy-mm-dd') as dates,  count(payment.payment_id) over (partition by to_char(payment.payment_date, 'dd.mm.yyyy'), store.store_id) as counts ,sum(amount) over (partition by to_char(payment.payment_date, 'dd.mm.yyyy'), store.store_id) as sums
from payment, staff, store
where payment.staff_id = staff.staff_id and staff.store_id = store.store_id
) as t1 where counts in (select distinct max(counts) from (
select distinct store.store_id, to_char(payment.payment_date, 'yyyy-mm-dd') as dates,  count(payment.payment_id) over (partition by to_char(payment.payment_date, 'dd.mm.yyyy'), store.store_id) as counts from payment, staff, store
where payment.staff_id = staff.staff_id and staff.store_id = store.store_id and store.store_id = 1) as t1
group by store_id
)  or sums in (
select distinct min(sums) from (
select distinct store.store_id, to_char(payment.payment_date, 'yyyy-mm-dd') as dates,  count(payment.payment_id) over (partition by to_char(payment.payment_date, 'dd.mm.yyyy'), store.store_id) as counts, 
sum(amount) over (partition by to_char(payment.payment_date, 'yyyy-mm-dd'), store.store_id) as sums
from payment, staff, store
where payment.staff_id = staff.staff_id and staff.store_id = store.store_id and store.store_id = 1) as mins
)
union all
select * from (
select distinct store.store_id, to_char(payment.payment_date, 'yyyy-mm-dd') as dates,  count(payment.payment_id) over (partition by to_char(payment.payment_date, 'dd.mm.yyyy'), store.store_id) as counts ,sum(amount) over (partition by to_char(payment.payment_date, 'dd.mm.yyyy'), store.store_id) as sums
from payment, staff, store
where payment.staff_id = staff.staff_id and staff.store_id = store.store_id
) as t1 where counts in (select distinct max(counts) from (
select distinct store.store_id, to_char(payment.payment_date, 'yyyy-mm-dd') as dates,  count(payment.payment_id) over (partition by to_char(payment.payment_date, 'dd.mm.yyyy'), store.store_id) as counts from payment, staff, store
where payment.staff_id = staff.staff_id and staff.store_id = store.store_id and store.store_id = 2) as t1
group by store_id
)  or sums in (
select distinct min(sums) from (
select distinct store.store_id, to_char(payment.payment_date, 'yyyy-mm-dd') as dates,  count(payment.payment_id) over (partition by to_char(payment.payment_date, 'dd.mm.yyyy'), store.store_id) as counts, 
sum(amount) over (partition by to_char(payment.payment_date, 'yyyy-mm-dd'), store.store_id) as sums
from payment, staff, store
where payment.staff_id = staff.staff_id and staff.store_id = store.store_id and store.store_id = 2) as mins
)