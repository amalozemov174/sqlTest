-- Task2
-- Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.
select address.address, city.city, country.country from customer, address, city, country
where customer.address_id = address.address_id and address.city_id = city.city_id and city.country_id = country.country_id;
-- Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select store_id, count(customer) from customer group by store_id;
-- Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. 
select store_id, count(customer) from customer group by store_id having count(customer) > 300;
-- Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём.
select store.store_id, count(customer.customer_id), city.city, staff.last_name, staff.first_name from customer, address, store, city, staff 
where customer.store_id = store.store_id and store.address_id = address.address_id and address.city_id = city.city_id and store.manager_staff_id = staff.staff_id
group by store.store_id, city.city, staff.last_name, staff.first_name having count(customer.customer_id) > 300;
-- Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.
select customer_id, count(customer_id) from payment
group by customer_id
order by count(customer_id) desc
limit 5;
-- Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
-- количество взятых в аренду фильмов;
-- общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
-- минимальное значение платежа за аренду фильма;
-- максимальное значение платежа за аренду фильма.
select customer_id, count(rental_id), sum(amount), min(amount), max(amount) from payment
group by customer_id;
-- Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение.
select c.city, c1.city
from city c
cross join city c1
where c.city != c1.city;
-- Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.
select customer_id, round(avg(DATE_PART('day', return_date - rental_date))) as avg_return from rental 
group by customer_id;
-- Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
select inventory.film_id, count(rental.rental_id), sum(payment.amount) from inventory, rental, payment
where inventory.inventory_id = rental.inventory_id and rental.rental_id = payment.rental_id
group by inventory.film_id;
-- Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.
select inventory.film_id, inventory.inventory_id from inventory
left join rental on inventory.inventory_id = rental.inventory_id
where rental.inventory_id is null;
-- Задание 9. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».
select staff_id, count(payment_id),
case when count(payment_id) > 7300 THEN 'Да'
else 'Нет'
end "'Премия'"
from payment 
group by staff_id;
