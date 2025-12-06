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

// Primero ver los tipos de datos exactos
echo "=== Tipos de ta_11_cuo_locales ===\n";
$query = "SELECT column_name, data_type, character_maximum_length
          FROM information_schema.columns
          WHERE table_name = 'ta_11_cuo_locales'
          ORDER BY ordinal_position";
$stmt = $pdo->query($query);
foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $c) {
    echo "  {$c['column_name']}: {$c['data_type']}";
    if ($c['character_maximum_length']) echo "({$c['character_maximum_length']})";
    echo "\n";
}

echo "\n=== Tipos de ta_11_cve_cuota ===\n";
$query = "SELECT column_name, data_type, character_maximum_length
          FROM information_schema.columns
          WHERE table_name = 'ta_11_cve_cuota'
          ORDER BY ordinal_position";
$stmt = $pdo->query($query);
foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $c) {
    echo "  {$c['column_name']}: {$c['data_type']}";
    if ($c['character_maximum_length']) echo "({$c['character_maximum_length']})";
    echo "\n";
}

echo "\n=== Tipos de usuarios ===\n";
$query = "SELECT column_name, data_type, character_maximum_length
          FROM information_schema.columns
          WHERE table_name = 'usuarios'
          ORDER BY ordinal_position";
$stmt = $pdo->query($query);
foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $c) {
    echo "  {$c['column_name']}: {$c['data_type']}";
    if ($c['character_maximum_length']) echo "({$c['character_maximum_length']})";
    echo "\n";
}
