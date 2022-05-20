with source as (

    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ source('jaffle_shop','raw_orders') }}

),

converted AS (

    SELECT cast(convert_from(data, 'utf8') as jsonb) AS data FROM source

),

renamed as (

    select
        (data->>'id')::int as order_id,
        (data->>'user_id')::int as customer_id,
        (data->>'order_date')::string as order_date,
        (data->>'status')::string as status

    from converted

)

select * from renamed
