{{ config(materialized='source') }}

{% set source_name %}
    {{ mz_generate_name('raw_orders') }}
{% endset %}

CREATE SOURCE {{ source_name }}
FROM KAFKA BROKER 'redpanda:9092' TOPIC 'raw_orders'
  KEY FORMAT BYTES
  VALUE FORMAT BYTES
ENVELOPE UPSERT;
