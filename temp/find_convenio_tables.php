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

// Buscar tablas ta_17
echo "=== Buscando tablas ta_17_* ===\n";
$query = "SELECT table_schema, table_name FROM information_schema.tables
          WHERE table_name LIKE 'ta_17%'
          ORDER BY table_schema, table_name";
$stmt = $pdo->query($query);
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
if (count($tables) > 0) {
    foreach ($tables as $t) {
        echo "{$t['table_schema']}.{$t['table_name']}\n";
    }
} else {
    echo "No se encontraron tablas ta_17_*\n";
}

// Buscar tablas con 'conv' en el nombre
echo "\n=== Buscando tablas con 'conv' ===\n";
$query = "SELECT table_schema, table_name FROM information_schema.tables
          WHERE table_name LIKE '%conv%'
          ORDER BY table_schema, table_name";
$stmt = $pdo->query($query);
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "{$t['table_schema']}.{$t['table_name']}\n";
}

// Buscar tablas con 'referencia' en el nombre
echo "\n=== Buscando tablas con 'referencia' ===\n";
$query = "SELECT table_schema, table_name FROM information_schema.tables
          WHERE table_name LIKE '%referencia%'
          ORDER BY table_schema, table_name";
$stmt = $pdo->query($query);
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "{$t['table_schema']}.{$t['table_name']}\n";
}

// Listar todos los schemas disponibles
echo "\n=== Schemas disponibles ===\n";
$query = "SELECT schema_name FROM information_schema.schemata ORDER BY schema_name";
$stmt = $pdo->query($query);
$schemas = $stmt->fetchAll(PDO::FETCH_COLUMN);
foreach ($schemas as $s) {
    echo "  {$s}\n";
}

// Buscar en schema comun
echo "\n=== Tablas en schema 'comun' con 'conv' o 'referencia' ===\n";
$query = "SELECT table_name FROM information_schema.tables
          WHERE table_schema = 'comun' AND (table_name LIKE '%conv%' OR table_name LIKE '%referencia%')
          ORDER BY table_name";
$stmt = $pdo->query($query);
$tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
foreach ($tables as $t) {
    echo "comun.{$t}\n";
}
