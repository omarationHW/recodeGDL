<?php
try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=== BUSCANDO COLUMNAS 'clave_cuenta' O 'cuenta' ===\n\n";
    
    $schemas = ['public', 'comun', 'comunX', 'db_ingresos'];
    
    foreach ($schemas as $schema) {
        $query = "SELECT DISTINCT table_name, column_name
                  FROM information_schema.columns 
                  WHERE table_schema = :schema 
                  AND (column_name LIKE '%clave_cuenta%' OR column_name LIKE '%cuenta%')
                  AND table_name LIKE '%div%'
                  ORDER BY table_name, column_name";
        $stmt = $pdo->prepare($query);
        $stmt->execute(['schema' => $schema]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (!empty($results)) {
            echo "--- Schema: $schema ---\n";
            foreach ($results as $row) {
                echo "  {$row['table_name']}.{$row['column_name']}\n";
            }
            echo "\n";
        }
    }
    
    // Buscar en ta_17_conv_diverso
    echo "\n=== EXPLORANDO ta_17_conv_diverso ===\n\n";
    
    $query = "SELECT column_name, data_type 
              FROM information_schema.columns 
              WHERE table_schema = 'comun' 
              AND table_name = 'ta_17_conv_diverso'
              ORDER BY ordinal_position";
    $stmt = $pdo->query($query);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Columnas:\n";
    foreach ($columns as $col) {
        echo "  - {$col['column_name']} ({$col['data_type']})\n";
    }
    
    echo "\n=== DATOS DE EJEMPLO ===\n\n";
    $query = "SELECT * FROM comun.ta_17_conv_diverso LIMIT 5";
    $stmt = $pdo->query($query);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($rows as $idx => $row) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($row as $key => $value) {
            if (strlen($value) > 50) {
                $value = substr($value, 0, 50) . "...";
            }
            echo "  $key: $value\n";
        }
        echo "\n";
    }
    
    $query = "SELECT COUNT(*) as total FROM comun.ta_17_conv_diverso";
    $stmt = $pdo->query($query);
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de registros: {$total['total']}\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
