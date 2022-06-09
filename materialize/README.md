## Jaffle Shop, but Streaming

`jaffle_shop` is a fictional ecommerce store that used across dbt labs docs as a playground. 
Here we try to maintain a fork of it using Materialize as the backend database. 

### Running the Materialize extension of jaffle_shop

Materialize is a streaming database. we accept data from relational databases like postgres, streaming sources like kafka, and file sources like s3. 
For this jaffle shop extension we've emulated a microservices architecture. 
We've kept the data the same as the jaffle_shop demo, but instead of seeding it from a CSV, we run a little python script to send it to redpanda.

* **Producer**

   The producer just loops through the jaffle shop CSV's, makes a kafka topic for each, and sends each row the corresponding topic [`producer` directory](./producer).

* **Redpanda**

  The producer produces JSON-formatted events with jaffle shop info to the `raw_customers`, `raw_orders`, and `raw_payments` Redpanda topics.

* **Materialize**

  Materialize is set up to consume streaming jaffle shop info from Redpanda.

* **dbt**

  You can define your data model using SQL and our dbt-adapter just as you would any other data warehouse - join over sources, aggregate, filter, and time window, and your data will be updated in real time.

## Docker

```bash
# Start the setup
docker-compose up -d

# Check if everything is up and running!
docker-compose ps
```

## dbt
To access the [dbt CLI](https://docs.getdbt.com/dbt-cli/cli-overview), run:

```bash
docker exec -it dbt bash
```

### Build and run the models and tests
To run the models:

```bash
dbt run
```

To run the tests: (this might fail, but that's ok! the data is populating from the kafka bus)

```bash
dbt test
```
## Materialize

To connect to the running Materialize service, you can use `mzcli`, which is included in the setup:

```bash
docker-compose run mzcli
```

TODO: take a look at how the views are changing in real time! 

## Redpanda

We've told Materialize to make materialized views for our test failures. Once everything has caught up, none of these views should have rows. 
Let's pretend the jaffle_shop billing team is working on our order tracking software, and somehow an order gets duplicated.

To fake this, we'll re-send our last order event to our orders topic:
```
docker-compose exec redpanda /bin/bash
echo "{\"id\": 99, \"user_id\": 85, \"order_date\": \"2018-04-09\", \"status\": \"placed\", \"event_ts\": 1653077715}" | rpk topic produce raw_orders --key "99"
```
Oh no! We've got rows! 
```
docker-compose run mzcli
materialize=> select * from public_etl_failure.unique_stg_orders_order_id;
unique_field | n_records
--------------+-----------
99 |         2

materialize=> select * from public_etl_failure.unique_orders_order_id;
 unique_field | n_records
--------------+-----------
           99 |         2
(1 row)
```

TODO: more event failure examples!