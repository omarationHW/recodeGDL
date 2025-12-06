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

// Ver estructura de tabla usuarios
echo "=== Estructura de public.usuarios ===\n";
$query = "SELECT column_name, data_type FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = 'usuarios'
          ORDER BY ordinal_position";
$stmt = $pdo->query($query);
$cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $c) {
    echo "  {$c['column_name']} ({$c['data_type']})\n";
}

// Buscar tablas con 'secc' en el nombre
echo "\n=== Buscando tablas con 'secc' ===\n";
$query = "SELECT table_schema, table_name FROM information_schema.tables
          WHERE table_name LIKE '%secc%'
          ORDER BY table_schema, table_name";
$stmt = $pdo->query($query);
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "{$t['table_schema']}.{$t['table_name']}\n";
}

// Buscar en schema comun
echo "\n=== Buscando en schema 'comun' ===\n";
$query = "SELECT table_name FROM information_schema.tables
          WHERE table_schema = 'comun' AND (table_name LIKE '%password%' OR table_name LIKE '%usuario%' OR table_name LIKE '%secc%')
          ORDER BY table_name LIMIT 20";
$stmt = $pdo->query($query);
$tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
foreach ($tables as $t) {
    echo "comun.{$t}\n";
}

// Ver datos de ejemplo de usuarios
echo "\n=== Ejemplo de datos en usuarios ===\n";
$query = "SELECT * FROM usuarios LIMIT 3";
$stmt = $pdo->query($query);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($rows as $row) {
    print_r($row);
}

// Buscar ta_11_cuo_locales para ver id_usuario
echo "\n=== Ejemplo de ta_11_cuo_locales ===\n";
$query = "SELECT * FROM ta_11_cuo_locales LIMIT 3";
$stmt = $pdo->query($query);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($rows as $row) {
    print_r($row);
}
