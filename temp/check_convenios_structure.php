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

$tables = ['ta_17_convenios', 'ta_17_devoluciones', 'ta_17_pagos', 'ta_17_paso_cont'];

foreach ($tables as $table) {
    echo "\n=== Estructura de {$table} ===\n";
    $query = "SELECT column_name, data_type, character_maximum_length
              FROM information_schema.columns
              WHERE table_name = ?
              ORDER BY ordinal_position";
    $stmt = $pdo->prepare($query);
    $stmt->execute([$table]);
    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $c) {
        echo "  {$c['column_name']}: {$c['data_type']}";
        if ($c['character_maximum_length']) echo "({$c['character_maximum_length']})";
        echo "\n";
    }

    // Ver algunos datos de ejemplo
    echo "\n  Ejemplo de datos:\n";
    try {
        $stmt = $pdo->query("SELECT * FROM {$table} LIMIT 2");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($rows) > 0) {
            print_r($rows[0]);
        } else {
            echo "  (sin datos)\n";
        }
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }
}
