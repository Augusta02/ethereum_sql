# ethereum_sql

## Metrics DAO 
This lesson we discussed the base tables fact_transaction, fact_events_logs, fact_traces table. 

Facts_transactions table shows the entire data in the overview of etherscan. 

facts_events_log tables shows the logs of a transaction, which is the same information in the Logs column on etherscan.  This table shows the number of transactions in ascending order.  
Note: Topics are global event, that is events like Approval, Transfer, Swap have the same contract address across the network. Topics are stored in an array in the table, so if you want to find data from a particular topic, you can access the topics array by:

##topics[0] 

Facts_traces tables shows the internal transaction that occurred across a transaction. We can get information such as eth_value in transaction that occurred internally, like royalties fees paid in NFTs or platform fees charged by Opensea

Check out the repository for exercises. 