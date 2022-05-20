with source as (

    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ source('jaffle_shop','raw_customers') }}

),

converted AS (

    SELECT cast(convert_from(data, 'utf8') as jsonb) AS data FROM source

),

renamed as (

    select
        (data->>'id')::int as customer_id,
        (data->>'first_name')::string as first_name,
        (data->>'last_name')::string as last_name

    from converted

)

select * from renamed
