<?php
// Buscar tablas relacionadas con multas y requerimientos
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    die("Error de conexión\n");
}

echo "=== BÚSQUEDA DE TABLAS RELACIONADAS ===\n\n";

// Buscar tablas multas
echo "--- Buscando tabla 'multas' ---\n";
$query1 = "
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name LIKE '%multa%'
    AND table_type = 'BASE TABLE'
ORDER BY table_schema, table_name";

$result1 = pg_query($conn, $query1);
if ($result1) {
    while ($row = pg_fetch_assoc($result1)) {
        echo "  " . $row['table_schema'] . "." . $row['table_name'] . "\n";
    }
}

// Buscar tablas requerimientos
echo "\n--- Buscando tabla 'reqmultas' o similar ---\n";
$query2 = "
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name LIKE '%req%'
    AND table_type = 'BASE TABLE'
ORDER BY table_schema, table_name";

$result2 = pg_query($conn, $query2);
if ($result2) {
    while ($row = pg_fetch_assoc($result2)) {
        echo "  " . $row['table_schema'] . "." . $row['table_name'] . "\n";
    }
}

pg_close($conn);
echo "\n✓ Búsqueda completada\n";
