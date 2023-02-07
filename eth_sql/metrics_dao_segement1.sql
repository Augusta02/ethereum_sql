select * 
from ethereum.core.fact_transactions 
where block_timestamp >= '2023-01-01' 
and from_address = lower('0xe2c25d061d632b166f74f04fbdeba838966caea2')
order by block_timestamp 
limit 1;



--On which date did this a16z wallet 
--0x05E793cE0C6027323Ac150F6d45C2344d28B6019 conduct its last transaction of 2022 on Ethereum?

SELECT *
FROM ethereum.core.fact_transactions
WHERE from_address = LOWER('0x05E793cE0C6027323Ac150F6d45C2344d28B6019')
ORDER BY block_timestamp DESC 
LIMIT 10;

SELECT *
FROM ethereum.core.ez_nft_mints
WHERE block_number = '14666971'
LIMIT 100;

SELECT COUNT(DISTINCT label)
FROM ethereum.core.dim_labels
LIMIT 100;

--What is the address label for the following address -
--0x8484Ef722627bf18ca5Ae6BcF031c23E6e922B30 ?This question is required.
SELECT *
FROM ethereum.core.dim_labels
WHERE address = LOWER('0x8484Ef722627bf18ca5Ae6BcF031c23E6e922B30')
LIMIT 10;