<?php
/**
 * Buscar las tablas necesarias para sp_get_pagos_loc_grl
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "📡 Conectado a la base de datos: $dbname @ $host\n\n";

    $tables = [
        'ta_11_locales',
        'ta_11_pagos_local',
        'ta_12_passwords',
        'ta_15_apremios',
        'ta_15_periodos'
    ];

    foreach ($tables as $table) {
        echo "🔍 Buscando tabla: $table\n";

        $query = "
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name = :table
            ORDER BY table_schema
        ";

        $stmt = $pdo->prepare($query);
        $stmt->execute(['table' => $table]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            foreach ($results as $row) {
                echo "   ✅ Encontrada en: {$row['table_schema']}.{$row['table_name']}\n";
            }
        } else {
            echo "   ❌ No encontrada\n";
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
