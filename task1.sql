-- Task1
-- Задание 1. Выведите уникальные названия городов из таблицы городов.
select distinct city from city;
-- Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города, названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.
select distinct city from city where city like 'L%a';
-- Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно и стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа.
select * from payment where payment_date between to_date('2005-06-17', 'YYYY-MM-DD') and to_date('2005-06-20', 'YYYY-MM-DD') and amount > 1.00 order by payment_date;
-- Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.
select * from payment order by payment_id desc limit 5;
-- Задание 5. Выведите следующую информацию по покупателям:
-- •	Фамилия и имя (в одной колонке через пробел)
-- •	Электронная почта
-- •	Длину значения поля email
-- •	Дату последнего обновления записи о покупателе (без времени)
--  Каждой колонке задайте наименование на русском языке.
select first_name || ' ' || last_name as "ФИО", email as "Почта", length(email) as "Длина почты", last_update as "Последнее обновление" from customer;
-- Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.
select customer_id, store_id, lower(first_name), lower(last_name), email, address_id, activebool, create_date, last_update, active from customer where active = 1 and first_name in ('KELLY', 'WILLIE');
-- Дополнительная часть:
-- Задание 7. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.
select * from film where rating = 'R' and rental_rate between 0.00 and 3.00 or rating = 'PG-13' and rental_rate >= 4.00;

-- Задание 8. Получите информацию о трёх фильмах с самым длинным описанием фильма.
select * from film order by length(description) desc limit 3;
-- Задание 9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
-- 	в первой колонке должно быть значение, указанное до @,
-- 	во второй колонке должно быть значение, указанное после @.
select  substring(email, 1, position('@' in email) - 1) as first, substring(email, position('@' in email) + 1, length(email)) as second from customer;
--Задание 10. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква должна быть заглавной, остальные строчными.
select  
upper(substring(lower(substring(email, 1, position('@' in email) - 1)), 1, 1)) || substring(lower(substring(email, 1, position('@' in email) - 1)), 2, length(substring(email, 1, position('@' in email) - 1))) as first, 
upper(substring(lower(substring(email, position('@' in email) + 1, length(email))), 1, 1)) || substring(lower(substring(email, position('@' in email) + 1, length(email))), 2, length(substring(email, position('@' in email) + 1, length(email)))) as second
from customer;