--Visualize the amount of USDC swapped and 
--count of swaps in the USDC-WETH SushiSwap pool
--by day in the past 7 days using the fact_event_logs table.
--In order to complete this task using the event logs, we will need to explore a few concepts:

--1. Finding swap events for the relevant pool
--2. Finding token details for relevant tokens
--3. Working with JSON object columns
--4. Aggregating the data
--5. Visualizing our findings

--get details for relevant pool
WITH pools AS(
	SELECT 
		pool_name, 
		pool_address,
		token0,
		token1
	FROM ethereum.core.dim_dex_liquidity_pools
	WHERE pool_address = LOWER('0x397FF1542f962076d0BFE58eA045FfA2d347ACa0')
),
--get details for tokens in relevant pool
decimals AS(
	SELECT
		address, 
		symbol,
		decimals
	FROM 
  		ethereum.core.dim_contracts
	WHERE 
  		address= (
  			SELECT 
  				Lower(token1)
  			FROM pools
		)
		OR address=(
  			SELECT
  				Lower(token0)
  			FROM pools
    )
),
  --aggregate pool and token details
pool_token_details AS(
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

--find swaps for relevant pool in last 7days 


--Working with JSON DATA
-- We can work with data in this fromat usingthis generic formula
--<COLUMN_NAME>:<FIELD_NAME>::<FIELD_FORMAT> as <FIELD_NAME>
-- We would use this formula format to add some columns to our Swap Event
swaps AS(
  SELECT
		block_number,
		block_timestamp,
		tx_hash,
    	event_index,
    	contract_address,
    	event_name,
    	event_inputs,
    	event_inputs :amount0In :: INTEGER AS amount0In,
    	event_inputs :amount0Out :: INTEGER AS amount0Out,
    	event_inputs :amount1In :: INTEGER AS amount1In,
    	event_inputs :amount1Out :: INTEGER AS amount1Out,
    	event_inputs :sender :: STRING AS sender,
    	event_inputs :to :: STRING AS to_address
  FROM
	ethereum.core.fact_event_logs
  WHERE
    	block_timestamp >= CURRENT_DATE - 6
    	AND event_name = ('Swap')
    	AND contract_address= LOWER('0x397FF1542f962076d0BFE58eA045FfA2d347ACa0')
  ),
	
--Lets put all the information we have gotten together
--Note we have to adjust amount coluns by each token's respective decimals.
--Formula: <AMOUNT_COLUMN> / POW(10, DECIMALS)
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
  	amount1In / pow(10, token1decimals) AS  amount1In_ADJ,
  	amount1Out / pow(10, token1decimals) AS amount1Out_ADJ,
  	token0symbol,
  	token1symbol
  FROM
  	swaps_contract_details
)

SELECT 
	DATE_TRUNC('day', block_timestamp) AS DATE,
  	COUNT(tx_hash) AS swap_count,
  	SUM(amount0In_ADJ) + SUM(amount0Out_ADJ) AS usdc_volume
FROM
	final_details
GROUP BY 
	1
ORDER BY 
	1 DESC



