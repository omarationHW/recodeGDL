<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "Estructura de comun.licencias:\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun'
          AND table_name = 'licencias'
        ORDER BY ordinal_position
        LIMIT 30
    ");

    $columns = $stmt->fetchAll();

    foreach ($columns as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : '';
        echo "  {$col['column_name']} - {$col['data_type']}{$len}\n";
    }

    echo "\n\nEstructura de comun.adeudos:\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun'
          AND table_name = 'adeudos'
        ORDER BY ordinal_position
        LIMIT 20
    ");

    $columns = $stmt->fetchAll();

    foreach ($columns as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : '';
        echo "  {$col['column_name']} - {$col['data_type']}{$len}\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
