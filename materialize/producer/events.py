#!/usr/bin/env python
import pandas as pd
import time
import json
from kafka import KafkaProducer
from multiprocessing import Process
import sys


class Producer:
    def __init__(self, topic, key):
        self.topic = topic
        self.key = key

    def run(self, data, sleep=0):

        dt = int(time.time())
        producer = KafkaProducer(bootstrap_servers='redpanda:9092')

        try:
            for i in data:
                print(i)
                print(self.topic)
                i['event_ts'] = dt
                producer.send(topic=self.topic,
                              key=str(i[self.key]).encode('utf-8'),
                              value=json.dumps(i).encode('utf-8'))
                sys.stdout.flush()
                time.sleep(sleep)

            producer.close()

        except Exception as e:
            print("Exception: %s" % str(e), file=sys.stderr)
            sys.exit(1)


def main():

    print("TODO: JANK: we sleep here to make very sure everything is ready")
    time.sleep(10)

    customers = pd.read_csv('/dbt/seeds/raw_customers.csv').to_dict(orient='records')
    orders = pd.read_csv('/dbt/seeds/raw_orders.csv').to_dict(orient='records')
    payments = pd.read_csv('/dbt/seeds/raw_payments.csv').to_dict(orient='records')

    c = Producer('raw_customers', 'id')
    o = Producer('raw_orders', 'id')
    p = Producer('raw_payments', 'id')

    p1 = Process(target=c.run, args=(customers,))
    p2 = Process(target=o.run, args=(orders, 5))
    p3 = Process(target=p.run, args=(payments, 5))

    p1.start()
    p1.join()
    p2.start()
    p3.start()


if __name__ == "__main__":
    main()
