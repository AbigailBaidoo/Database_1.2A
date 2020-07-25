CREATE DATABASE wave;

CREATE TABLE users (
u_id integer PRIMARY KEY,
name text NOT NULL,
mobile text NOT NULL,
wallet_id integer NOT NULL,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);

CREATE TABLE transfers (
transfer_id integer PRIMARY KEY,
u_id integer NOT NULL,
source_wallet_id integer NOT NULL,
dest_wallet_id integer NOT NULL,
send_amount_currency text NOT NULL,
send_amount_scalar numeric NOT NULL,
receive_amount_currency text NOT NULL,
receive_amount_scalar numeric NOT NULL,
kind text NOT NULL,
dest_mobile text,
dest_merchant_id integer,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);

CREATE TABLE agents(
agent_id integer PRIMARY KEY,
name text,
country text NOT NULL,
region text,
city text,
subcity text,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);

CREATE TABLE agent_transactions (
atx_id integer PRIMARY KEY,
u_id integer NOT NULL,
agent_id integer NOT NULL,
amount numeric NOT NULL,
fee_amount_scalar numeric NOT NULL,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);

CREATE TABLE wallets (
wallet_id integer PRIMARY KEY,
currency text NOT NULL,
ledger_location text NOT NULL,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);

--Question 1 : How many users does Wave have?
--We need to get the total number of users from the users table.
SELECT COUNT(*) FROM users;
--SELECT COUNT(u_id) FROM users;

--Question 2 : How many transfers have been sent in the currency CFA
--We need to get the total number of transfers sent in CFA from the transfers table.
SELECT COUNT(*) FROM transfers WHERE send_amount_currency = 'CFA';
--SELECT COUNT(u_id) FROM transfers WHERE send_amount_currency = 'CFA';

--Question 3 : How many different users have sent a transfer in CFA?
--We need to get the total number of different users who have sent a transfer
--in CFA from the transfers table.
SELECT COUNT(DISTINCT u_id) FROM transfers WHERE send_amount_currency = 'CFA';

--Question 4 : How many agent_transactions did we have in the months of 2018 
--(broken down by month)?
--We need to get the total number of agent transactions in the months of 2018.
SELECT COUNT(*) FROM agent_transactions WHERE when_created 
BETWEEN (TIMESTAMP '2018-01-01 00:00:01')
AND (TIMESTAMP '2018-12-31 23:59:59') GROUP BY when_created ;

--Question 5 : Over the course of the last week, how many 
--Wave agents were “net depositors” vs. “net withdrawers”?
--We need to get the total number of "net depositors" and "net withdrawers" over
--the course of the last week.

--Net withdrawers
SELECT COUNT(*) FROM agent_transactions WHERE amount > 0 
AND when_created BETWEEN CURRENT_DATE AND (CURRENT_DATE - INTERVAL '7 DAYS');

--Net depositors
SELECT COUNT(*) FROM agent_transactions WHERE amount < 0
AND when_created BETWEEN CURRENT_DATE AND (CURRENT_DATE - INTERVAL '7 DAYS');

/*Question 6 : Build an “atx volume city summary” table: find the volume of 
agent transactions created in the last week, grouped by city.*/
-- We need to find the volume of agent transactions created in last week grouped 
-- by city.

SELECT agents.city, COUNT (agent_transactions.atx_id) AS volume
FROM agents JOIN agent_transactions ON 
agent_transactions.agent_id = agents.agent_id 
WHERE agent_transactions.when_created BETWEEN CURRENT_DATE AND
(CURRENT_DATE - INTERVAL '7 DAYS')
GROUP BY agents.city ;

-- Question 7 : Now separate the atx volume by country as well
--(so your columns should be country, city, and volume) 
-- We need to build a table for the total number of agent transactions grouped into
--city and country in the past week.
SELECT agents.city, agents.country, COUNT (agent_transactions.atx_id) AS volume
FROM agents JOIN agent_transactions ON 
agent_transactions.agent_id = agents.agent_id 
WHERE agent_transactions.when_created BETWEEN CURRENT_DATE AND
(CURRENT_DATE - INTERVAL '7 DAYS')
GROUP BY agents.city, agents.country;

--Question 8 : Build a “send volume by country and kind” table: 
--find the total volume of transfers (bysend_amount_scalar) 
--sent in the past week, grouped by country and transfer kind. 
/* We need to find the total volume of transfers sent in the past week and group them
by country and transfer kind*/

SELECT COUNT (transfers.send_amount_scalar) AS volume, transfers.kind AS transfer_kind,
wallets.ledger_location AS country FROM transfers JOIN wallets ON 
transfers.source_wallet_id = wallets.wallet_id
WHERE transfers.when_created 
BETWEEN CURRENT_DATE AND (CURRENT_DATE - INTERVAL '7 DAYS')
GROUP BY transfers.kind, wallets.ledger_location ;

--Question 9 : Then add columns for transaction count and number of unique senders 
--(still broken down by country and transfer kind).
--We need to add two columns to the send volume by kind table.
SELECT COUNT (transfers.send_amount_scalar) AS volume, transfers.kind AS transfer_kind,
wallets.ledger_location AS country, COUNT (DISTINCT transfers.u_id) AS unique_sender, 
COUNT(transfers.transfer_id) AS transaction_count
FROM transfers JOIN wallets ON 
transfers.source_wallet_id = wallets.wallet_id WHERE transfers.when_created 
BETWEEN CURRENT_DATE AND (CURRENT_DATE - INTERVAL '7 DAYS')
GROUP BY transfers.kind, transfers.u_id, transfers.transfer_id,
wallets.ledger_location;

--Question 10 : Finally, which wallets have sent more than 10,000,000 CFA 
--in transfers in the last month (as identified by the source_wallet_id column
--on the transfers table),and how much did they send?
--We need to find wallets that have sent more than 10000000 CFA in transfers in the 
--last month and the total amount they sent from the transfers table.
SELECT source_wallet_id, send_amount_scalar
FROM transfers WHERE send_amount_currency = 'CFA' AND
send_amount_scalar > 10000000 AND when_created BETWEEN CURRENT_DATE AND
(CURRENT_DATE - INTERVAL '1 MONTH') ;


