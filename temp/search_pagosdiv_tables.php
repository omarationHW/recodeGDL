<?php
try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=== BUSCANDO TABLAS RELACIONADAS CON PAGOS DIVERSOS ===\n\n";
    
    // Buscar tablas que contengan 'pago' en su nombre
    $schemas = ['public', 'comun', 'comunX', 'db_ingresos', 'multas_reglamentos'];
    
    foreach ($schemas as $schema) {
        echo "--- Schema: $schema ---\n";
        $query = "SELECT table_name FROM information_schema.tables 
                  WHERE table_schema = :schema 
                  AND table_name LIKE '%pago%'
                  ORDER BY table_name";
        $stmt = $pdo->prepare($query);
        $stmt->execute(['schema' => $schema]);
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        if (!empty($tables)) {
            foreach ($tables as $table) {
                echo "  - $table\n";
            }
        }
        echo "\n";
    }
    
    // Buscar tablas con 'div' o 'divers'
    echo "=== TABLAS CON 'DIV' O 'DIVERS' ===\n\n";
    foreach ($schemas as $schema) {
        echo "--- Schema: $schema ---\n";
        $query = "SELECT table_name FROM information_schema.tables 
                  WHERE table_schema = :schema 
                  AND (table_name LIKE '%div%' OR table_name LIKE '%divers%')
                  ORDER BY table_name";
        $stmt = $pdo->prepare($query);
        $stmt->execute(['schema' => $schema]);
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        if (!empty($tables)) {
            foreach ($tables as $table) {
                echo "  - $table\n";
            }
        }
        echo "\n";
    }
    
    // Buscar tablas con 'cuenta'
    echo "=== TABLAS CON 'CUENTA' ===\n\n";
    foreach ($schemas as $schema) {
        echo "--- Schema: $schema ---\n";
        $query = "SELECT table_name FROM information_schema.tables 
                  WHERE table_schema = :schema 
                  AND table_name LIKE '%cuenta%'
                  ORDER BY table_name
                  LIMIT 5";
        $stmt = $pdo->prepare($query);
        $stmt->execute(['schema' => $schema]);
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        if (!empty($tables)) {
            foreach ($tables as $table) {
                echo "  - $table\n";
            }
        }
        echo "\n";
    }
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
