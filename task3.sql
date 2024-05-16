-- Task3
-- Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
-- •	Пронумеруйте все платежи от 1 до N по дате
select *, row_number() over (order by payment_date asc) from payment;
-- •	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
select *, row_number() over (partition by customer_id order by payment_date asc) from payment;
-- •	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
select *, sum(amount) over (partition by customer_id order by date(payment_date), amount asc) from payment;
-- •	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
select *, dense_rank() over (partition by customer_id order by amount desc) from payment;
-- Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
select customer_id, payment_date, amount,  lag(amount,1,0.) OVER(PARTITION BY customer_id order by payment_date) AS  "lag" from payment;
-- Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select *, lead(amount) over(partition by customer_id) - amount AS  "lead" from payment;
-- Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select distinct customer_id, last_value(payment_date) over(partition by customer_id) as "last_date", last_value(amount) over(partition by customer_id) as "last_amount", last_value(payment_id) over(partition by customer_id) as "last_payment_id" from payment order by customer_id;
-- Дополнительная часть
-- Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.
select staff_id, date(payment_date), amount,  sum(amount) over (partition by staff_id order by payment_date asc) from payment where EXTRACT(MONTH FROM payment_date) = 8 and EXTRACT(year from payment_date) = 2005;
-- Задание 6. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
select * from 
(select *, row_number() over (order by payment_date asc) as "row_numbers"  from payment where to_char(payment_date, 'dd.mm.yyyy') = '20.08.2005') as t1
where row_numbers % 100 = 0;
-- Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- •	покупатель, арендовавший наибольшее количество фильмов;
-- •	покупатель, арендовавший фильмов на самую большую сумму;
-- •	покупатель, который последним арендовал фильм.
select distinct t1.country, t1.customer_id, t1.counts_of_renatl, t1.sum_of_rental, t1.last_rental from 
(select distinct country.country,  payment.customer_id, count(payment.rental_id) over (partition by payment.customer_id order by payment.customer_id) as counts_of_renatl, 
	sum(payment.amount) over (partition by payment.customer_id order by payment.customer_id) as sum_of_rental,
	max(payment.payment_date) over(partition by payment.customer_id order by payment.customer_id) as last_rental
from payment, customer, address, city, country
where payment.customer_id = customer.customer_id and customer.address_id = address.address_id and address.city_id = city.city_id and city.country_id = country.country_id
order by country.country, payment.customer_id) as t1
inner join
(select country, max(counts_of_renatl) counts_of_renatl, max(sum_of_rental) sum_of_rental, max(last_rental) last_rental from (
select distinct country.country,  payment.customer_id, count(payment.rental_id) over (partition by payment.customer_id order by payment.customer_id) as counts_of_renatl, 
sum(payment.amount) over (partition by payment.customer_id order by payment.customer_id) as sum_of_rental,
max(payment.payment_date) over(partition by payment.customer_id order by payment.customer_id) as last_rental
from payment, customer, address, city, country
where payment.customer_id = customer.customer_id and customer.address_id = address.address_id and address.city_id = city.city_id and city.country_id = country.country_id
order by country.country, payment.customer_id
) t1
group by country
order by country) as t2
on t1.country = t2.country and t1.counts_of_renatl = t2.counts_of_renatl or t1.sum_of_rental = t2.sum_of_rental or t1.last_rental = t2.last_rental