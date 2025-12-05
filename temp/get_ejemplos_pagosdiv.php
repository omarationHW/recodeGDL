<?php
try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=== 3 EJEMPLOS DE DATOS REALES PARA PROBAR ===\n\n";
    
    // Obtener 3 ejemplos diferentes
    $query = "SELECT * FROM comun.linea_capturadiv 
              WHERE total > 0 
              ORDER BY fecha DESC 
              LIMIT 3";
    $stmt = $pdo->query($query);
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($ejemplos as $idx => $ejemplo) {
        echo "EJEMPLO " . ($idx + 1) . ":\n";
        echo "  Búsqueda por FOLIO: {$ejemplo['folio']}\n";
        echo "  Búsqueda por ID: {$ejemplo['id']}\n";
        echo "  Línea de captura: {$ejemplo['linea']}\n";
        echo "  Fecha: {$ejemplo['fecha']}\n";
        echo "  Total: \${$ejemplo['total']}\n";
        echo "  Módulo: {$ejemplo['modulo']}\n";
        echo "\n";
    }
    
    echo "\n=== INSTRUCCIONES PARA PROBAR ===\n\n";
    echo "En el campo 'Cuenta' del formulario, puedes ingresar:\n";
    foreach ($ejemplos as $idx => $ejemplo) {
        echo "\nEjemplo " . ($idx + 1) . ":\n";
        echo "  - Folio: {$ejemplo['folio']}\n";
        echo "  - ID: {$ejemplo['id']}\n";
    }
    echo "\nTambién puedes dejar el campo vacío para ver todos los registros.\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
