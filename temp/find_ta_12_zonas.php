<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO ta_12_zonas Y ta_11_mercados ===\n\n";

    $schemas = ['public', 'db_ingresos', 'comun', 'comunX', 'padron_licencias'];

    foreach ($schemas as $schema) {
        // Buscar ta_12_zonas
        try {
            $query = "SELECT COUNT(*) as total FROM $schema.ta_12_zonas";
            $stmt = $pdo->query($query);
            $count = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "✓ ta_12_zonas encontrada en $schema ({$count['total']} registros)\n";
        } catch (Exception $e) {
            // No existe en este schema
        }

        // Buscar ta_11_mercados
        try {
            $query = "SELECT COUNT(*) as total FROM $schema.ta_11_mercados";
            $stmt = $pdo->query($query);
            $count = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "✓ ta_11_mercados encontrada en $schema ({$count['total']} registros)\n";
        } catch (Exception $e) {
            // No existe en este schema
        }
    }

    // Buscar también tablas similares con "zona"
    echo "\n=== TABLAS CON 'zona' ===\n";
    $zonasQuery = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%zona%'
        AND table_schema IN ('public', 'db_ingresos', 'comun', 'comunX', 'padron_licencias')
        ORDER BY table_schema, table_name
    ";
    
    $stmt = $pdo->query($zonasQuery);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($tables as $t) {
        echo "{$t['table_schema']}.{$t['table_name']}\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
