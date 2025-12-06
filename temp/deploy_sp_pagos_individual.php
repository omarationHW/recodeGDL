<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO pagos_individual_get ===\n\n";

    $sql = file_get_contents(__DIR__ . '/../RefactorX/Base/mercados/database/database/PagosIndividual_pagos_individual_get.sql');

    if (!$sql) {
        die("Error: No se pudo leer el archivo SQL\n");
    }

    echo "Desplegando SP...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Verificar que hay datos de prueba
    echo "=== VERIFICANDO DATOS ===\n";
    $checkQuery = "SELECT * FROM public.ta_11_pago_local LIMIT 1";
    $stmt = $pdo->query($checkQuery);
    $pago = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($pago) {
        echo "✓ Hay datos en ta_11_pago_local\n";
        echo "  Probando con: id_local={$pago['id_local']}, axo={$pago['axo']}, periodo={$pago['periodo']}\n\n";
        
        // Probar el SP
        echo "=== PROBANDO SP ===\n";
        $testQuery = "SELECT * FROM pagos_individual_get({$pago['id_local']}, {$pago['axo']}, {$pago['periodo']})";
        $stmt = $pdo->query($testQuery);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result) {
            echo "✓ SP funciona correctamente\n";
            echo "  Datos obtenidos:\n";
            echo "    - Oficina: {$result['oficina']}\n";
            echo "    - Mercado: {$result['num_mercado']}\n";
            echo "    - Local: {$result['nombre']}\n";
            echo "    - Importe: {$result['importe_pago']}\n";
        } else {
            echo "✗ No se encontraron resultados\n";
        }
    } else {
        echo "⚠ No hay datos en ta_11_pago_local para probar\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
