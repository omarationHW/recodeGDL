<?php
try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=== EXPLORANDO TABLA: ta_17_adeudos_div (comun) ===\n\n";
    
    // Ver estructura
    $query = "SELECT column_name, data_type, character_maximum_length 
              FROM information_schema.columns 
              WHERE table_schema = 'comun' 
              AND table_name = 'ta_17_adeudos_div'
              ORDER BY ordinal_position";
    $stmt = $pdo->query($query);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Columnas:\n";
    foreach ($columns as $col) {
        echo "  - {$col['column_name']} ({$col['data_type']}";
        if ($col['character_maximum_length']) {
            echo ", max_length: {$col['character_maximum_length']}";
        }
        echo ")\n";
    }
    
    // Obtener datos de ejemplo
    echo "\n=== DATOS DE EJEMPLO (3 registros) ===\n\n";
    $query = "SELECT * FROM comun.ta_17_adeudos_div LIMIT 3";
    $stmt = $pdo->query($query);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($rows as $idx => $row) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: $value\n";
        }
        echo "\n";
    }
    
    // Contar registros
    $query = "SELECT COUNT(*) as total FROM comun.ta_17_adeudos_div";
    $stmt = $pdo->query($query);
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de registros: {$total['total']}\n\n";
    
    // Explorar también linea_capturadiv
    echo "\n=== EXPLORANDO TABLA: linea_capturadiv (comun) ===\n\n";
    
    $query = "SELECT column_name, data_type 
              FROM information_schema.columns 
              WHERE table_schema = 'comun' 
              AND table_name = 'linea_capturadiv'
              ORDER BY ordinal_position";
    $stmt = $pdo->query($query);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Columnas:\n";
    foreach ($columns as $col) {
        echo "  - {$col['column_name']} ({$col['data_type']})\n";
    }
    
    // Obtener datos de ejemplo
    echo "\n=== DATOS DE EJEMPLO (3 registros) ===\n\n";
    $query = "SELECT * FROM comun.linea_capturadiv LIMIT 3";
    $stmt = $pdo->query($query);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($rows as $idx => $row) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: $value\n";
        }
        echo "\n";
    }
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
