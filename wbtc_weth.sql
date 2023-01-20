--1. By using the ethereum.core tables, --create the same analysis for WBTC-WETH pool 
--on Sushiswap from **April 1 - April 15, 2022**
--the WBTC-WETH pool on Sushiswap’s contract address is 
--`0xceff51756c56ceffca006cd410b03ffc46dd3a58`
--Does this pool have more or less swap volume as compared to WETH-USDC?


--An overview of the data we are looking at
--SELECT 
	--*
--FROM 
	--ethereum.core.fact_event_logs
--WHERE
	--block_timestamp BETWEEN '2022-04-01' AND '2022-04-15'
	--AND contract_address = LOWER('0xceff51756c56ceffca006cd410b03ffc46dd3a58')
	--AND event_name IN ('Swap')



--get relevant pools details
WITH pools AS(
  SELECT
  	pool_name,
  	pool_address,
  	token0,
  	token1
  FROM
  	ethereum.core.dim_dex_liquidity_pools
  WHERE
  	pool_address = LOWER('0xceff51756c56ceffca006cd410b03ffc46dd3a58')
),
decimals AS(
  SELECT
  		address, 
  		symbol,
  		decimals
	FROM
  		ethereum.core.dim_contracts
	WHERE 
  		address = (
  			SELECT 
  				LOWER(token1)
  			FROM 
  				pools
  )
  		OR address= (
  			SELECT
  				LOWER(token0)
  			FROM 
  				pools
)),
  --aggregate pool and token details
pool_token_details AS (
  SELECT 
  	pool_name,
	pool_address,
	token0,
	token1,
	token0.symbol AS token0symbol,
	token1.symbol AS token1symbol,
	token0.decimals AS token0decimals,
	token1.decimals AS token1decimals
  FROM
	pools
  	LEFT JOIN decimals AS token0
  	ON token0.address = token0
  	LEFT JOIN decimals AS token1
  	ON token1.address = token1
  ),
--find swaps for relevant pool between April 1 and April 15th
swaps AS(
  SELECT 
	block_number,
	block_timestamp,
	tx_hash,
	event_index,
	contract_address,
	event_name,
	event_inputs,
	event_inputs : amount0In :: INTEGER AS amount0In,
	event_inputs : amount0Out :: INTEGER AS amount0Out,
	event_inputs : amount1In :: INTEGER AS amount1In,
	event_inputs : amount1Out :: INTEGER AS amount1Out,
	event_inputs : sender :: STRING AS sender,
	event_inputs : to :: STRING AS to_address
  FROM
	ethereum.core.fact_event_logs
  WHERE
	block_timestamp BETWEEN '2022-04-1' AND '2022-04-15'
	AND event_name = ('Swap')
	AND contract_address = LOWER('0xceff51756c56ceffca006cd410b03ffc46dd3a58')
),
--aggregate pool, token, and swap details
swaps_contract_details AS(
  SELECT
	block_number,
	block_timestamp,
	tx_hash,
	event_index,
	contract_address,
	amount0In,
	amount0Out,
	amount1In,
	amount1Out,
	sender,
	to_address,
	pool_name,
	pool_address,
	token0,
	token1,
	token0symbol,
	token1symbol,
	token0decimals,
	token1decimals
FROM
	swaps
	LEFT JOIN pool_token_details
	ON contract_address = pool_address
),
--transform amounts by respective token decimals
final_details AS(
  SELECT
  	pool_name,
  	pool_address,
  	block_number, 
  	block_timestamp,
  	tx_hash,
  	amount0In / pow(10, token0decimals) AS amount0In_ADJ,
  	amount0Out / pow(10, token0decimals) AS amount0Out_ADJ,
  	amount1In / pow(10, token1decimals) AS amount1In_ADJ,
  	amount1Out / pow(10, token1decimals) AS amount1Out_ADJ,
  	token0symbol,
  	token1symbol
  FROM
  	swaps_contract_details
)

SELECT
	DATE_TRUNC('day', block_timestamp) AS DATE,
  	COUNT(tx_hash) AS swap_count,
  	SUM(amount0In_ADJ) + SUM(amount0Out_ADJ) AS wbtc_volume
FROM
 	final_details
GROUP BY
	1
ORDER BY
 	1 DESC



  
 
	