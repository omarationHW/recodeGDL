<?php
// Verificar SPs de fechas_descuento

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== VERIFICANDO SPs DE FECHAS DESCUENTO ===\n\n";

// Buscar SPs
$sps_buscar = ['fechas_descuento_get_all', 'fechas_descuento_update', 'fechas_descuento_get_by_mes'];

foreach ($sps_buscar as $sp_nombre) {
    echo "Buscando: $sp_nombre\n";

    $query = "
        SELECT
            n.nspname as schema,
            p.proname as function_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = '$sp_nombre'
        ORDER BY n.nspname;
    ";

    $result = pg_query($conn, $query);

    if ($result && pg_num_rows($result) > 0) {
        while ($row = pg_fetch_assoc($result)) {
            echo "  ✅ {$row['schema']}.{$row['function_name']}({$row['arguments']})\n";
        }
    } else {
        echo "  ❌ NO ENCONTRADO\n";
    }
    echo "\n";
}

echo str_repeat("=", 80) . "\n\n";

// Verificar tabla ta_11_fecha_desc
echo "=== VERIFICANDO TABLA ta_11_fecha_desc ===\n\n";

$query_tabla = "
    SELECT
        schemaname,
        tablename
    FROM pg_tables
    WHERE tablename LIKE '%fecha%desc%'
    ORDER BY schemaname;
";

$result_tabla = pg_query($conn, $query_tabla);

if ($result_tabla && pg_num_rows($result_tabla) > 0) {
    echo "Tablas encontradas:\n";
    while ($row = pg_fetch_assoc($result_tabla)) {
        echo "  - {$row['schemaname']}.{$row['tablename']}\n";

        // Ver estructura
        if ($row['tablename'] === 'ta_11_fecha_desc') {
            echo "\n    Estructura de {$row['schemaname']}.ta_11_fecha_desc:\n";

            $query_cols = "
                SELECT column_name, data_type, udt_name
                FROM information_schema.columns
                WHERE table_schema = '{$row['schemaname']}'
                  AND table_name = 'ta_11_fecha_desc'
                ORDER BY ordinal_position;
            ";

            $result_cols = pg_query($conn, $query_cols);
            if ($result_cols) {
                while ($col = pg_fetch_assoc($result_cols)) {
                    echo "      - {$col['column_name']} ({$col['udt_name']})\n";
                }
            }
            echo "\n";
        }
    }
} else {
    echo "❌ No se encontró tabla ta_11_fecha_desc\n";
}

pg_close($conn);
