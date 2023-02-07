-- SELECT 
--   event_index,
--   contract_address,
--   data,
--   --this function converts hex values to integer value
--   ethereum.public.udf_hex_to_int(data) :: int as raw_amount,
--   --change raw amount to correct decimal place
--   --there are two ways to change to decimals
--   raw_amount / pow(10, 6) as pow_raw,
--   raw_amount / 1e6 as exp_raw
-- FROM ethereum.core.fact_event_logs
-- WHERE block_timestamp::date = '2022-08-24'
-- AND tx_hash = Lower('0x56cf02194da2afc277ab20852a4287890f7ea8d8c42691fe0b2e0f5a5aa273c3')
-- AND topics[0] = Lower('0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef')

-- What does the contract address column represent in this filtered row?

SELECT *
FROM ethereum.core.fact_event_logs
WHERE block_timestamp::date = '2022-08-24'
AND tx_hash = Lower('0x56cf02194da2afc277ab20852a4287890f7ea8d8c42691fe0b2e0f5a5aa273c3')
AND topics[0] =  Lower('0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef')

-- USDC Token


-- The amount of token transferred can be found in the data column in the fact_event_logs table on Flipside. 
-- Which of the options below can be used to decode the token amount correctly?
SELECT 
  event_index, 
  data,
  ethereum.public.udf_hex_to_int(data) as token_transferred
FROM ethereum.core.fact_event_logs
WHERE block_timestamp::date = '2022-08-24'
AND tx_hash = Lower('0x56cf02194da2afc277ab20852a4287890f7ea8d8c42691fe0b2e0f5a5aa273c3')
AND topics[0] =  Lower('0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef')




-- The token that is transferred / deposited has 6 decimal places. 
--   Assume the token amount variable is named ‘token_amount’. 
-- --   Which of the following options below DOES NOT convert the amount to its right decimal places?This question is required.
SELECT 
  block_number,
  event_index,
  contract_address,
  data,
  ethereum.public.udf_hex_to_int(data) as raw_amount,
  -- the right way to change to decimals
  raw_amount / 1e6 as token_amount, 
  raw_amount / pow(10, 6) as pow_token_amount
FROM ethereum.core.fact_event_logs
WHERE block_timestamp::date = '2022-08-24'
AND tx_hash = Lower('0x56cf02194da2afc277ab20852a4287890f7ea8d8c42691fe0b2e0f5a5aa273c3')
AND topics[0] =  Lower('0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef')



-- Using the fact_traces table on Flipside, find out how many rows there are with a non-zero eth transfer for this transaction, 
-- excluding the identifier = ‘call_origin’ row: https://etherscan.io/tx/0x81d4b35b512ee5239bc071d6270ef1245bb6e4d2c606ccc1f35a77bd303ff4a3
select 
  block_number, 
  identifier,
  eth_value
from ethereum.core.fact_traces
where tx_hash = lower('0x81d4b35b512ee5239bc071d6270ef1245bb6e4d2c606ccc1f35a77bd303ff4a3')
	and eth_value > 0
	and identifier != 'CALL_ORIGIN'

-- Three rows excluding call-origin



  
-- Use the fact_traces table on Flipside and filter for this transaction: https://etherscan.io/tx/0x81d4b35b512ee5239bc071d6270ef1245bb6e4d2c606ccc1f35a77bd303ff4a3 . 
-- What is the eth_value when to_address = ‘0x148ef557738b8bc51bd19ee1365d9d04bd46ab04’ ?This question is required.
select 
  	identifier,
  	eth_value
from ethereum.core.fact_traces
where tx_hash = lower('0x81d4b35b512ee5239bc071d6270ef1245bb6e4d2c606ccc1f35a77bd303ff4a3')
	--and eth_value > 0
	--and identifier != 'CALL_ORIGIN'
	and to_address = lower('0x148ef557738B8BC51bD19Ee1365d9D04BD46ab04')



