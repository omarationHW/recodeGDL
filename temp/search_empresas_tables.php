<?php
// Buscar tablas relacionadas con empresas/ejecutores
$conn = pg_connect("host=localhost port=5432 dbname=recaudadora user=postgres password=postgres");

if (!$conn) {
    die("Error de conexión\n");
}

echo "=== BUSCANDO TABLAS RELACIONADAS CON EMPRESAS/EJECUTORES ===\n\n";

// Buscar tablas que contengan 'empresa' o 'ejecutor'
$query = "
SELECT
    table_schema,
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_schema = t.table_schema AND c.table_name = t.table_name) as num_columns
FROM information_schema.tables t
WHERE (table_name ILIKE '%empresa%' OR table_name ILIKE '%ejecutor%')
  AND table_type = 'BASE TABLE'
  AND table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;
";

$result = pg_query($conn, $query);

if ($result) {
    echo "Tablas encontradas:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo "- {$row['table_schema']}.{$row['table_name']} ({$row['num_columns']} columnas)\n";
    }
}

// Ahora buscar columnas en las tablas más comunes
echo "\n=== ANALIZANDO TABLA: comun.ejecutores ===\n";
$query = "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema='comun' AND table_name='ejecutores' ORDER BY ordinal_position;";
$result = pg_query($conn, $query);
if ($result && pg_num_rows($result) > 0) {
    while ($row = pg_fetch_assoc($result)) {
        echo "  {$row['column_name']} ({$row['data_type']})\n";
    }

    // Obtener ejemplos
    echo "\nEjemplos de datos:\n";
    $query = "SELECT * FROM comun.ejecutores LIMIT 5;";
    $result = pg_query($conn, $query);
    if ($result) {
        while ($row = pg_fetch_assoc($result)) {
            echo json_encode($row, JSON_PRETTY_PRINT) . "\n";
        }
    }
} else {
    echo "  Tabla no encontrada o sin columnas\n";
}

echo "\n=== ANALIZANDO TABLA: comunX.ejecutores ===\n";
$query = "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema='comunX' AND table_name='ejecutores' ORDER BY ordinal_position;";
$result = pg_query($conn, $query);
if ($result && pg_num_rows($result) > 0) {
    while ($row = pg_fetch_assoc($result)) {
        echo "  {$row['column_name']} ({$row['data_type']})\n";
    }

    // Obtener ejemplos
    echo "\nEjemplos de datos:\n";
    $query = "SELECT * FROM comunX.ejecutores LIMIT 5;";
    $result = pg_query($conn, $query);
    if ($result) {
        while ($row = pg_fetch_assoc($result)) {
            echo json_encode($row, JSON_PRETTY_PRINT) . "\n";
        }
    }
} else {
    echo "  Tabla no encontrada o sin columnas\n";
}

// Buscar en db_ingresos
echo "\n=== BUSCANDO EN db_ingresos ===\n";
$query = "
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'db_ingresos'
  AND (table_name ILIKE '%empresa%' OR table_name ILIKE '%ejecutor%')
ORDER BY table_name;
";
$result = pg_query($conn, $query);
if ($result && pg_num_rows($result) > 0) {
    while ($row = pg_fetch_assoc($result)) {
        echo "- db_ingresos.{$row['table_name']}\n";

        // Mostrar estructura
        $query2 = "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema='db_ingresos' AND table_name='{$row['table_name']}' ORDER BY ordinal_position;";
        $result2 = pg_query($conn, $query2);
        if ($result2) {
            while ($col = pg_fetch_assoc($result2)) {
                echo "    {$col['column_name']} ({$col['data_type']})\n";
            }
        }
    }
}

pg_close($conn);
?>
