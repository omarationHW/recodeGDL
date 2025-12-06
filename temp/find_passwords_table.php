<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host={$host};port={$port};dbname={$dbname}", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Conexion OK\n\n";
} catch (PDOException $e) {
    die("Error: " . $e->getMessage() . "\n");
}

// Buscar tabla ta_12_passwords en todos los schemas
echo "=== Buscando ta_12_passwords ===\n";
$query = "SELECT table_schema, table_name
          FROM information_schema.tables
          WHERE table_name LIKE '%password%' OR table_name LIKE '%usuario%'
          ORDER BY table_schema, table_name";
$stmt = $pdo->query($query);
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables as $t) {
    echo "{$t['table_schema']}.{$t['table_name']}\n";
}

// Buscar también tablas ta_11 y ta_12
echo "\n=== Buscando tablas ta_11_* y ta_12_* ===\n";
$query = "SELECT table_schema, table_name
          FROM information_schema.tables
          WHERE table_name LIKE 'ta_11_%' OR table_name LIKE 'ta_12_%'
          ORDER BY table_schema, table_name
          LIMIT 50";
$stmt = $pdo->query($query);
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables as $t) {
    echo "{$t['table_schema']}.{$t['table_name']}\n";
}

// Buscar tablas específicas
echo "\n=== Buscando tablas específicas del SP ===\n";
$tablesNeeded = ['ta_11_cuo_locales', 'ta_12_passwords', 'ta_11_cve_cuota', 'ta_11_categoria', 'ta_11_secciones'];
foreach ($tablesNeeded as $tableName) {
    $query = "SELECT table_schema, table_name
              FROM information_schema.tables
              WHERE table_name = ?";
    $stmt = $pdo->prepare($query);
    $stmt->execute([$tableName]);
    $found = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($found) > 0) {
        foreach ($found as $t) {
            echo "[FOUND] {$t['table_schema']}.{$t['table_name']}\n";
        }
    } else {
        echo "[NOT FOUND] {$tableName}\n";
    }
}
