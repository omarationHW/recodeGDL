<?php
/**
 * Script para probar el SP recaudadora_pagos_espe
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== PROBANDO SP: recaudadora_pagos_espe ===\n\n";

    // Prueba 1: Con cuenta 281048
    echo "1. Prueba con cuenta '281048':\n";
    $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_pagos_espe(:cuenta, :ejercicio)");
    $stmt->execute([
        'cuenta' => '281048',
        'ejercicio' => null
    ]);
    $results1 = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Registros encontrados: " . count($results1) . "\n";

    if (count($results1) > 0 && count($results1) <= 3) {
        echo "   Primeros registros:\n";
        foreach ($results1 as $i => $row) {
            echo "   - Cuenta: {$row['cvecuenta']}, CVE Aut: {$row['cveaut']}, Estado: {$row['estado']}\n";
        }
    } elseif (count($results1) > 3) {
        echo "   ⚠ DEMASIADOS REGISTROS - mostrando primeros 3:\n";
        for ($i = 0; $i < 3; $i++) {
            $row = $results1[$i];
            echo "   - Cuenta: {$row['cvecuenta']}, CVE Aut: {$row['cveaut']}, Estado: {$row['estado']}\n";
        }
    }
    echo "\n";

    // Prueba 2: Sin cuenta (todos los registros)
    echo "2. Prueba sin cuenta (todos los registros):\n";
    $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_pagos_espe(:cuenta, :ejercicio)");
    $stmt->execute([
        'cuenta' => '',
        'ejercicio' => null
    ]);
    $results2 = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Total registros en la tabla: " . count($results2) . "\n\n";

    // Prueba 3: Verificar directamente en la tabla
    echo "3. Verificación directa en tabla autpagoesp:\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.autpagoesp WHERE cvecuenta = 281048");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Registros con cuenta 281048 en tabla: {$result['total']}\n\n";

    // Prueba 4: Ver el total de la tabla
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.autpagoesp");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total registros en tabla autpagoesp: {$result['total']}\n\n";

    echo "=== DIAGNÓSTICO ===\n";
    if (count($results1) == count($results2)) {
        echo "❌ PROBLEMA: El filtro por cuenta NO está funcionando\n";
        echo "   El SP retorna todos los registros sin importar la cuenta\n";
    } else {
        echo "✓ El filtro parece estar funcionando\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
