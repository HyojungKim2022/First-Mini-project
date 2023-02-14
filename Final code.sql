-- won_price varchar로 입력하여 int로 수정하기 --
-- 쉼표와 '원' 제거 후 int로 변경 --
-- 하기는 duty_free 예시이나 표 마다 변경하면 가능 --

update duty_free
set won_price = replace(won_price, ',','');

update duty_free
set won_price = replace(won_price, '원','');

select cast(won_price as signed INTEGER) won_price
from duty_free;

-- 세 면세점 입력값을 한 테이블에 입력 -- 
-- 하기 코드는 예시로 다른 테이블 또한 duty_free로 넣으면 됨 --

insert into 
duty_free
select *
from shinsegae;

-- 각 면세점 별 100위안에 가장 많이 포함되어 있는 브랜드 --

CREATE OR REPLACE VIEW table_1 AS (
SELECT RANK() OVER (PARTITION BY dept_name ORDER BY count(*) desc) brand_rank, brand_name, dept_name, count(*) as total
FROM duty_free
WHERE ranks <= 100
GROUP BY brand_name, depty_name
ORDER BY count(*) desc
);
SELECT * FROM table_1
WHERE brand_rank = 1;

-- 면세점별 1~15위에 모두 포함되어 있는 브랜드 --

SELECT brand_name, item_name
FROM lotte_duty_free
WHERE ranks <= 15
AND brand_name in (
					SELECT brand_name
                    FROM shilla
                    WHERE ranks <= 15
                    )
AND brand_name in (
					SELECT brand_name
                    FROM shinsegae
                    WHERE ranks <= 15
                    );

-- 각 면세점별 100위 안 제품들 평균 가격 --

select a.dept_name, round(avg(a.won_price)) '평균값(원)', b.dept_name, round(avg(b.won_price)) '평균값(원)', c.dept_name, round(avg(c.won_price)) '평균값(원)'
from shilla a
inner join shinsegae b
on a.ranks = b.ranks
inner join lotte_duty_free c
on a.ranks = c.ranks
where a.ranks <= 100
and b.ranks <= 100
and c.ranks <= 100
group by 1,3,5;

-- 제품이 10만원 이상인 아이템 --

SELECT brand_name, item_name, cast(won_price as SIGNED INTEGER) won_price
FROM duty_free
WHERE won_price >= 100000
ORDER BY 3 desc;

-- 제품 이름이 가장 긴 아이템 / 짧은 아이템템 --

CREATE OR REPLACE VIEW len_test AS
(
SELECT ranks, dept_name, brand_name, item_name, char_length(item_name) item_len, length(item_name) byte_len
FROM duty_free
ORDER BY item_len DESC
);
SELECT dept_name, item_name, char_length(item_name) item_len
FROM len_test
WHERE byte_len = (select max(byte_len) from len_test) OR byte_len = (SELECT min(byte_len) FROM len_test);