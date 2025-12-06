<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO ta_11_kilowhatts ===\n\n";

    // Buscar en todos los schemas
    $schemas = ['public', 'db_ingresos', 'comun', 'comunX', 'padron_licencias'];

    foreach ($schemas as $schema) {
        try {
            $query = "SELECT COUNT(*) as total FROM $schema.ta_11_kilowhatts";
            $stmt = $pdo->query($query);
            $count = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "✓ ta_11_kilowhatts encontrada en $schema ({$count['total']} registros)\n";
            
            // Ver estructura
            $structQuery = "
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = 'ta_11_kilowhatts'
                ORDER BY ordinal_position
            ";
            $stmt = $pdo->query($structQuery);
            $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo "  Columnas:\n";
            foreach ($cols as $col) {
                echo "    - {$col['column_name']} ({$col['data_type']})\n";
            }
            
            // Ver datos
            $dataQuery = "SELECT * FROM $schema.ta_11_kilowhatts LIMIT 3";
            $stmt = $pdo->query($dataQuery);
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo "\n  Primeros registros:\n";
            foreach ($data as $row) {
                echo "    " . json_encode($row) . "\n";
            }
            echo "\n";
            
        } catch (Exception $e) {
            // No existe en este schema
        }
    }

    // Buscar tablas similares con "kilowatt" o "energia"
    echo "=== TABLAS SIMILARES ===\n";
    $similarQuery = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%kilowatt%' OR table_name ILIKE '%energia%' OR table_name ILIKE '%kwh%')
        AND table_schema IN ('public', 'db_ingresos', 'comun', 'comunX', 'padron_licencias')
        ORDER BY table_schema, table_name
    ";
    
    $stmt = $pdo->query($similarQuery);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($tables as $t) {
        echo "{$t['table_schema']}.{$t['table_name']}\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
