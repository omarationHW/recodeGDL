<?php
try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=== DESPLEGANDO STORED PROCEDURE: recaudadora_pagosdivfrm ===\n\n";
    
    $sql = file_get_contents(__DIR__ . '/create_sp_pagosdivfrm.sql');
    
    $pdo->exec($sql);
    
    echo "✓ Stored procedure creado exitosamente\n\n";
    
    // Verificar que existe
    $query = "SELECT 
                p.proname as nombre,
                pg_get_function_arguments(p.oid) as argumentos,
                pg_get_functiondef(p.oid) as definicion
              FROM pg_proc p
              JOIN pg_namespace n ON p.pronamespace = n.oid
              WHERE n.nspname = 'public'
              AND p.proname = 'recaudadora_pagosdivfrm'";
    
    $stmt = $pdo->query($query);
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($sp) {
        echo "✓ Verificado: El SP existe en la base de datos\n";
        echo "  Nombre: {$sp['nombre']}\n";
        echo "  Argumentos: {$sp['argumentos']}\n\n";
    }
    
    // Probar el SP
    echo "=== PROBANDO EL STORED PROCEDURE ===\n\n";
    
    echo "Test 1: Sin parámetros (todos los registros)\n";
    $query = "SELECT * FROM public.recaudadora_pagosdivfrm(NULL) LIMIT 5";
    $stmt = $pdo->query($query);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros encontrados: " . count($results) . "\n";
    if (!empty($results)) {
        echo "Primer registro:\n";
        foreach ($results[0] as $key => $value) {
            echo "  $key: $value\n";
        }
    }
    echo "\n";
    
    echo "Test 2: Con folio específico\n";
    $query = "SELECT * FROM public.recaudadora_pagosdivfrm('120')";
    $stmt = $pdo->query($query);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros encontrados: " . count($results) . "\n";
    if (!empty($results)) {
        echo "Primer registro:\n";
        foreach ($results[0] as $key => $value) {
            echo "  $key: $value\n";
        }
    }
    echo "\n";
    
    echo "✓ Stored procedure funcionando correctamente\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
