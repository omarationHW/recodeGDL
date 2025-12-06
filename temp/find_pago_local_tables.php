<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO TABLAS CON 'PAGO' Y 'LOCAL' ===\n\n";

    $query = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%pago%' AND table_name ILIKE '%local%')
        AND table_schema IN ('public', 'db_ingresos', 'comun', 'comunX', 'padron_licencias')
        ORDER BY table_schema, table_name
    ";
    
    $stmt = $pdo->query($query);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($tables)) {
        echo "No se encontraron tablas con 'pago' y 'local'\n\n";
        
        // Buscar solo con pago
        echo "=== TABLAS CON 'PAGO' ===\n";
        $query2 = "
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name ILIKE '%pago%'
            AND table_schema IN ('public', 'db_ingresos', 'comun', 'comunX', 'padron_licencias')
            ORDER BY table_schema, table_name
            LIMIT 20
        ";
        
        $stmt = $pdo->query($query2);
        $tables2 = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($tables2 as $t) {
            echo "{$t['table_schema']}.{$t['table_name']}\n";
        }
    } else {
        foreach ($tables as $t) {
            $fullName = "{$t['table_schema']}.{$t['table_name']}";
            echo "$fullName\n";
            
            // Ver columnas
            try {
                $colQuery = "
                    SELECT column_name, data_type, character_maximum_length
                    FROM information_schema.columns
                    WHERE table_schema = '{$t['table_schema']}'
                    AND table_name = '{$t['table_name']}'
                    ORDER BY ordinal_position
                    LIMIT 10
                ";
                $colStmt = $pdo->query($colQuery);
                $cols = $colStmt->fetchAll(PDO::FETCH_ASSOC);
                
                foreach ($cols as $col) {
                    $type = $col['data_type'];
                    if ($col['character_maximum_length']) {
                        $type .= "({$col['character_maximum_length']})";
                    }
                    echo "  - {$col['column_name']}: $type\n";
                }
                echo "\n";
            } catch (Exception $e) {
                echo "  Error: {$e->getMessage()}\n\n";
            }
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
