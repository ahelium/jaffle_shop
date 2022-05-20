{{ config(materialized='source') }}

{% set source_name %}
    {{ mz_generate_name('raw_payments') }}
{% endset %}

CREATE SOURCE {{ source_name }}
FROM KAFKA BROKER 'redpanda:9092' TOPIC 'raw_payments'
  KEY FORMAT BYTES
  VALUE FORMAT BYTES
ENVELOPE UPSERT;
