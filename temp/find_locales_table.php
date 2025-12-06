<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host={$host};port={$port};dbname={$dbname}", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error: " . $e->getMessage() . "\n");
}

// Buscar tablas que contengan 'local' en su nombre
echo "=== Tablas con 'local' en el nombre ===\n";
$stmt = $pdo->query("SELECT table_schema, table_name FROM information_schema.tables
                     WHERE table_name LIKE '%local%'
                     AND table_schema NOT IN ('pg_catalog', 'information_schema')
                     ORDER BY table_schema, table_name");
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "{$t['table_schema']}.{$t['table_name']}\n";
}

// Buscar tablas que tengan columna id_local
echo "\n=== Tablas con columna 'id_local' ===\n";
$stmt = $pdo->query("SELECT c.table_schema, c.table_name
                     FROM information_schema.columns c
                     WHERE c.column_name = 'id_local'
                     AND c.table_schema NOT IN ('pg_catalog', 'information_schema')
                     GROUP BY c.table_schema, c.table_name
                     ORDER BY c.table_schema, c.table_name");
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "{$t['table_schema']}.{$t['table_name']}\n";
}

// Buscar tablas que tengan oficina y num_mercado
echo "\n=== Tablas con 'oficina' y 'num_mercado' ===\n";
$stmt = $pdo->query("SELECT c.table_schema, c.table_name
                     FROM information_schema.columns c
                     WHERE c.column_name IN ('oficina', 'num_mercado')
                     AND c.table_schema NOT IN ('pg_catalog', 'information_schema')
                     GROUP BY c.table_schema, c.table_name
                     HAVING COUNT(DISTINCT c.column_name) = 2
                     ORDER BY c.table_schema, c.table_name");
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "{$t['table_schema']}.{$t['table_name']}\n";

    // Mostrar estructura
    $stmt2 = $pdo->query("SELECT column_name FROM information_schema.columns
                          WHERE table_schema = '{$t['table_schema']}' AND table_name = '{$t['table_name']}'
                          ORDER BY ordinal_position LIMIT 15");
    $cols = $stmt2->fetchAll(PDO::FETCH_COLUMN);
    echo "  Cols: " . implode(", ", $cols) . "\n";
}

// Verificar si ta_11_movimientos ya tiene toda la info necesaria
echo "\n=== Revisando estructura completa de ta_11_movimientos ===\n";
$stmt = $pdo->query("SELECT column_name FROM information_schema.columns WHERE table_name = 'ta_11_movimientos' ORDER BY ordinal_position");
$cols = $stmt->fetchAll(PDO::FETCH_COLUMN);
echo "Columnas: " . implode(", ", $cols) . "\n";

// Ver datos de ejemplo
echo "\n=== Ejemplo de ta_11_movimientos ===\n";
$stmt = $pdo->query("SELECT * FROM ta_11_movimientos LIMIT 1");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
if ($row) {
    print_r($row);
}
