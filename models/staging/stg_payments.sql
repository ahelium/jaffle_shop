with source as (
    
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ source('jaffle_shop','raw_payments') }}

),

converted AS (

    SELECT cast(convert_from(data, 'utf8') as jsonb) AS data FROM source

),

renamed as (

    select
        (data->>'id')::int as payment_id,
        (data->>'order_id')::int as order_id,
        (data->>'payment_method')::string as payment_method,
        -- `amount` is currently stored in cents, so we convert it to dollars
        (data->>'amount')::int / 100 as amount

    from converted

)

select * from renamed
