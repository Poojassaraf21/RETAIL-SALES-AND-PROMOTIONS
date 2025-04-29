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
      From Diwali_campaign_sale 

	 