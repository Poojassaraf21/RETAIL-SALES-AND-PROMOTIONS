USE RETAIL_INSIGHTS
SELECT * FROM dim_campaigns
SELECT * FROM dim_products
SELECT * FROM dim_stores
SELECT promo_type,sum (quantity_sold_after_promo) as a,
sum(quantity_sold_before_promo) FROM fact_events  where promo_type='BOGOF' group by promo_type

WITH PromoData AS (
    SELECT 
        promo_type,
        SUM(quantity_sold_before_promo) AS total_before_promo,
        SUM(
            CASE 
                WHEN promo_type = 'BOGOF' THEN quantity_sold_after_promo * 2
                ELSE quantity_sold_after_promo
            END
        ) AS total_after_promo
    FROM fact_events
    GROUP BY promo_type
)
SELECT * FROM PromoData;

SELECT product_name,
base_price,
promo_type
FROM dim_products P join fact_events E on P.product_code=E.product_code
where promo_type='BOGOF' AND base_price>500

SELECT promo_type
FROM fact_events
WHERE TRY_CONVERT(money, promo_type) IS NULL

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products' AND COLUMN_NAME = 'base_price'

SELECT base_price
FROM fact_events
WHERE TRY_CONVERT(money, base_price) IS NULL


  SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_events' AND COLUMN_NAME = 'base_price'

SELECT *
FROM fact_events
WHERE promo_type = 'BOGOF'

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('dim_products', 'fact_events')
  AND COLUMN_NAME = 'product_code'

  SELECT product_name,
       base_price,
       promo_type
FROM dim_products P
JOIN fact_events E ON P.product_code = E.product_code 
WHERE promo_type = 'BOGOF' and base_price>500


SELECT city,
count(store_id) as store_count
from dim_stores
group by city
order by store_count desc

select 
campaign_name,
sum(base_price*quantity_sold_before_promo) AS before_promo,
sum (base_price*quantity_sold_after_promo) AS after_promo
FROM dim_campaigns C join fact_events E on C.campaign_id=E.campaign_id


 SELECT 
     campaign_name,
     ROUND(sum(base_price) *quantity_sold_before_promo,2) AS total_revenue_before_promotion,
	 
	ROUND(SUM(CASE
            WHEN promo_type = 'BOGOF' THEN (base_price * 0.5) * quantity_sold_after_promo * 2
            WHEN promo_type = '500 Cashback' THEN (base_price - 500) * quantity_sold_after_promo
            WHEN promo_type = '50% OFF' THEN (base_price * 0.5) * quantity_sold_after_promo
            WHEN promo_type = '33% OFF' THEN (base_price * 0.67) * quantity_sold_after_promo
            WHEN promo_type = '25% OFF' THEN (base_price * 0.75) * quantity_sold_after_promo END),2) AS total_revenue_after_promotion
     FROM
     fact_events E
     JOIN
     dim_campaigns C on E.campaign_id=C.campaign_id
     GROUP BY campaign_name


	 SELECT 
    campaign_name, 
    SUM(base_price * quantity_sold_before_promo) / 1000000 AS total_revenue_before_promo, 
    SUM(base_price * quantity_sold_after_promo) / 1000000 AS total_revenue_after_promo
FROM 
    dim_campaigns C 
JOIN 
    fact_events E 
ON 
    C.campaign_id = E.campaign_id
GROUP BY 
    campaign_name;
	

;



	;;

	
	
	With  Diwali_campaign_sale as 
	(Select category , 
     Round(Sum((
          Case 
          When promo_type = 'BOGOF' Then E.quantity_sold_after_promo*2
          Else E.quantity_sold_after_promo
          End)
      - quantity_sold_before_promo * 100)
      / Sum(quantity_sold_before_promo),2) AS ISU 
      From fact_events E
      Join 
      dim_products P on  E.product_code=P.product_code
      Join 
      dim_campaigns C on E.campaign_id=C.campaign_id
      Where campaign_name = 'Diwali'
      Group by category)

      Select 
      Category , 
      ISU,
      row_number() Over(order by ISU desc) as rank_order 
      From Diwali_campaign_sale; 

	 SELECT TOP 5
	 product_name,category,
	 ROUND((SUM(
	 case
	 when promo_type='BOGOF' then (base_price*0.5)*quantity_sold_after_promo*2
	  when promo_type='500 Cashback' then (base_price-500) *quantity_sold_after_promo
	   when promo_type='50% OFF' then (base_price*0.5)*quantity_sold_after_promo
	    when promo_type='33% OFF' then (base_price*0.67)*quantity_sold_after_promo
		when promo_type='25% OFF' then (base_price*0.75)*quantity_sold_after_promo else 0 end)-
		-sum(base_price*quantity_sold_before_promo))/sum(base_price*quantity_sold_before_promo)*100,2) as IR
		FROM dim_products P
		JOIN 
		fact_events E on P.product_code=E.product_code
		GROUP BY product_name,category
		order by IR DESC
	   

	    SELECT TOP 5
	 product_name,category,
	 (SUM(
	 case
	 when promo_type='BOGOF' then (base_price*0.5)*quantity_sold_after_promo*2
	  when promo_type='500 Cashback' then (base_price-500) *quantity_sold_after_promo
	   when promo_type='50% OFF' then (base_price*0.5)*quantity_sold_after_promo
	    when promo_type='33% OFF' then (base_price*0.67)*quantity_sold_after_promo
		when promo_type='25% OFF' then (base_price*0.75)*quantity_sold_after_promo else 0 end)) AS TOTAL_REVENUE,
		SUM(base_price*quantity_sold_before_promo) as before_promo
		FROM dim_products P JOIN fact_events E ON P.product_code=E.product_code GROUP BY product_name,category
