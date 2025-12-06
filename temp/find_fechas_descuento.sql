-- Buscar tabla de fechas de descuento
\echo '=== BÚSQUEDA DE TABLAS FECHAS DESCUENTO ==='
\echo ''

-- Buscar tablas similares
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE (
    table_name LIKE '%fecha%desc%'
    OR table_name LIKE 'ta_11_fecha%'
)
AND table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;

\echo ''
\echo '=== TODAS LAS TABLAS ta_11 ==='
\echo ''

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_name LIKE 'ta_11%'
AND table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;
