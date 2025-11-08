<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ESTRUCTURA DE comun.requisitos_doc ===\n\n";

    $query = "
    SELECT column_name, data_type, character_maximum_length, is_nullable
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'requisitos_doc'
    ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($query);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($columns) > 0) {
        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
            echo "{$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
        }
    } else {
        echo "Tabla 'requisitos' no encontrada. Buscando tablas similares...\n\n";

        $query2 = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE '%requisito%'
        ORDER BY table_schema, table_name
        ";

        $stmt2 = $pdo->query($query2);
        $tables = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        foreach ($tables as $table) {
            echo "{$table['table_schema']}.{$table['table_name']}\n";
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
