SELECT 
  COUNT (tx_hash),
  COUNT(DISTINCT tx_hash)
FROM ethereum.core.fact_transactions
WHERE
	block_timestamp:: DATE BETWEEN '2022-10-01' AND '2022-10-31'

--How many NFT sales took place on Opensea in October 2022?
SELECT 
  COUNT(event_type) as n_sales
FROM ethereum.core.ez_nft_sales
WHERE
  	block_timestamp::DATE BETWEEN '2022-10-01' AND '2022-10-31'
 	AND platform_name = 'opensea'
	AND event_type = 'sale'

--What are the number of swap transactions that took place on Uniswap-v2 in October 2022?
SELECT 
  COUNT(event_name) as n_swaps
FROM ethereum.core.ez_dex_swaps
WHERE 
	block_timestamp BETWEEN '2022-10-01' AND '2022-10-31'
	AND platform = 'uniswap-v2'
	AND event_name = 'Swap'

--How many unique addresses does the "DIM_LABELS" table on Flipside contain?
SELECT 
  COUNT(DISTINCT address)
FROM ethereum.core.dim_labels
 