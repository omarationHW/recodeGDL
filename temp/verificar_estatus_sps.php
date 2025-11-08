<?php
/**
 * Verificar SPs de estatusfrm
 */

$conn = pg_connect("host=187.188.19.245 port=5432 dbname=guadalajara user=postgres password=FF)-BQk2");

if (!$conn) {
    die("Error de conexión\n");
}

echo "=== VERIFICANDO SPs DE ESTATUS ===\n\n";

// Buscar SPs relacionados con estatus
$query = "
SELECT
    n.nspname as schema,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname LIKE '%estatus%'
    AND n.nspname IN ('comun', 'public', 'guadalajara')
ORDER BY n.nspname, p.proname;
";

$result = pg_query($conn, $query);

if ($result) {
    echo "SPs encontrados relacionados con 'estatus':\n";
    echo str_repeat("=", 80) . "\n";

    $count = 0;
    while ($row = pg_fetch_assoc($result)) {
        $count++;
        echo "\n{$count}. {$row['schema']}.{$row['function_name']}\n";
        echo "   Parámetros: {$row['arguments']}\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "Total SPs encontrados: $count\n\n";
} else {
    echo "Error al buscar SPs: " . pg_last_error($conn) . "\n";
}

// Buscar tabla de estatus
echo "\n=== VERIFICANDO TABLA DE ESTATUS ===\n\n";

$schemas = ['comun', 'public', 'guadalajara'];
foreach ($schemas as $schema) {
    $query = "
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = '$schema'
        AND (table_name LIKE '%estatus%' OR table_name LIKE '%status%')
    ORDER BY table_name;
    ";

    $result = pg_query($conn, $query);
    if ($result && pg_num_rows($result) > 0) {
        echo "Tablas en esquema '$schema':\n";
        while ($row = pg_fetch_assoc($result)) {
            echo "  - {$schema}.{$row['table_name']}\n";
        }
    }
}

// Verificar tabla de revisiones o trámites
echo "\n\n=== VERIFICANDO TABLAS DE TRAMITES/REVISIONES ===\n\n";

$query = "
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname IN ('comun', 'public', 'guadalajara')
    AND (tablename LIKE '%tramite%' OR tablename LIKE '%revision%')
ORDER BY tablename;
";

$result = pg_query($conn, $query);
if ($result) {
    echo "Tablas encontradas:\n";
    echo str_repeat("-", 80) . "\n";
    while ($row = pg_fetch_assoc($result)) {
        echo sprintf("%-20s %-40s %s\n",
            $row['schemaname'],
            $row['tablename'],
            $row['size']
        );
    }
}

pg_close($conn);
echo "\n✓ Verificación completada\n";
