create table if not exists basketsdata(
	user_id integer,
	basket_id integer PRIMARY KEY,
	event_time timestamp,
	abandoned boolean,
	discount numeric(1,1)
);

copy public.basketsdata (user_id, basket_id, event_time, abandoned, discount)
FROM '/Users/mac/Desktop/Learning_Materials/Projects/SQL/oracle_sql/basketsdata.csv' 
DELIMITER ',' 
CSV HEADER 
QUOTE '"' 
ESCAPE '''';

