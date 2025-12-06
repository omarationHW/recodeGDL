<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO TABLAS DE USUARIOS ===\n\n";

    $query = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (
            table_name ILIKE '%usuario%' 
            OR table_name ILIKE '%user%'
            OR table_name ILIKE '%password%'
        )
        AND table_schema IN ('public', 'db_ingresos', 'comun', 'comunX', 'padron_licencias')
        ORDER BY table_schema, table_name
    ";
    
    $stmt = $pdo->query($query);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Tablas encontradas:\n";
    foreach ($tables as $t) {
        $fullName = "{$t['table_schema']}.{$t['table_name']}";
        echo "  $fullName\n";
        
        // Ver estructura
        try {
            $countQuery = "SELECT COUNT(*) as total FROM $fullName";
            $countStmt = $pdo->query($countQuery);
            $count = $countStmt->fetch(PDO::FETCH_ASSOC);
            echo "    → {$count['total']} registros\n";
            
            // Ver columnas
            $colQuery = "
                SELECT column_name
                FROM information_schema.columns
                WHERE table_schema = '{$t['table_schema']}'
                AND table_name = '{$t['table_name']}'
                ORDER BY ordinal_position
            ";
            $colStmt = $pdo->query($colQuery);
            $cols = $colStmt->fetchAll(PDO::FETCH_COLUMN);
            echo "    Columnas: " . implode(', ', $cols) . "\n\n";
        } catch (Exception $e) {
            echo "    Error: {$e->getMessage()}\n\n";
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
