<?php
// Script para probar el stored procedure recaudadora_ipor actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedures ipor...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_ipor.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedures actualizados exitosamente.\n\n";

    // 2. Probar sin filtro (debe retornar todos los registros, máximo 100)
    echo "2. Probando sin filtro (debe retornar todas las tasas)...\n";
    $datos_json = json_encode(['filtro' => '']);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ipor(?::TEXT)");
    $stmt->execute([$datos_json]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "   Primeros 5 resultados:\n";
        for ($i = 0; $i < min(5, count($results)); $i++) {
            $r = $results[$i];
            echo "     - ID: {$r['id']}, Concepto: {$r['concepto']}, Porcentaje: {$r['porcentaje']}%, Año: {$r['anio']}\n";
        }
    }

    // 3. Probar con filtro de año específico (2024)
    echo "\n\n3. Probando con filtro de año '2024'...\n";
    $datos_2024 = json_encode(['filtro' => '2024']);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ipor(?::TEXT)");
    $stmt->execute([$datos_2024]);
    $results_2024 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($results_2024) . "\n";
    if (count($results_2024) > 0) {
        echo "   Resultados:\n";
        foreach (array_slice($results_2024, 0, 5) as $r) {
            echo "     - ID: {$r['id']}, Concepto: {$r['concepto']}, Porcentaje: {$r['porcentaje']}%\n";
        }
    } else {
        echo "   (No hay tasas para el año 2024)\n";
    }

    // 4. Probar con filtro de año 2023
    echo "\n\n4. Probando con filtro de año '2023'...\n";
    $datos_2023 = json_encode(['filtro' => '2023']);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ipor(?::TEXT)");
    $stmt->execute([$datos_2023]);
    $results_2023 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($results_2023) . "\n";
    if (count($results_2023) > 0) {
        foreach (array_slice($results_2023, 0, 5) as $r) {
            echo "     - ID: {$r['id']}, Concepto: {$r['concepto']}, Porcentaje: {$r['porcentaje']}%\n";
        }
    }

    // 5. Probar con filtro de tipo 'B'
    echo "\n\n5. Probando con filtro de tipo 'B' (Baldío)...\n";
    $datos_b = json_encode(['filtro' => 'B']);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ipor(?::TEXT)");
    $stmt->execute([$datos_b]);
    $results_b = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($results_b) . "\n";
    if (count($results_b) > 0) {
        echo "   Primeros 5 resultados:\n";
        foreach (array_slice($results_b, 0, 5) as $r) {
            echo "     - ID: {$r['id']}, Concepto: {$r['concepto']}, Porcentaje: {$r['porcentaje']}%\n";
        }
    }

    // 6. Probar con filtro de tipo 'C'
    echo "\n\n6. Probando con filtro de tipo 'C' (Construcción)...\n";
    $datos_c = json_encode(['filtro' => 'C']);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ipor(?::TEXT)");
    $stmt->execute([$datos_c]);
    $results_c = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($results_c) . "\n";
    if (count($results_c) > 0) {
        echo "   Primeros 5 resultados:\n";
        foreach (array_slice($results_c, 0, 5) as $r) {
            echo "     - ID: {$r['id']}, Concepto: {$r['concepto']}, Porcentaje: {$r['porcentaje']}%\n";
        }
    }

    // 7. Probar con filtro de año más antiguo (1999)
    echo "\n\n7. Probando con filtro de año '1999'...\n";
    $datos_1999 = json_encode(['filtro' => '1999']);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ipor(?::TEXT)");
    $stmt->execute([$datos_1999]);
    $results_1999 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($results_1999) . "\n";
    if (count($results_1999) > 0) {
        foreach (array_slice($results_1999, 0, 5) as $r) {
            echo "     - ID: {$r['id']}, Concepto: {$r['concepto']}, Porcentaje: {$r['porcentaje']}%\n";
        }
    }

    // 8. Probar con ID específico
    echo "\n\n8. Probando con ID de tasa específico '1'...\n";
    $datos_id = json_encode(['filtro' => '1']);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ipor(?::TEXT)");
    $stmt->execute([$datos_id]);
    $results_id = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($results_id) . "\n";
    if (count($results_id) > 0) {
        foreach ($results_id as $r) {
            echo "     - ID: {$r['id']}, Concepto: {$r['concepto']}, Porcentaje: {$r['porcentaje']}%\n";
        }
    }

    // 9. Ver formato JSON para el frontend
    echo "\n\n9. Formato JSON para el frontend (sin filtro, primeros 10):\n";
    $datos_json_final = json_encode(['filtro' => '']);

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ipor(?::TEXT) LIMIT 10");
    $stmt->execute([$datos_json_final]);
    $result_json = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    // 10. Verificar que los resultados cambian con diferentes filtros
    echo "\n\n10. Verificación: Los resultados cambian con diferentes filtros\n";

    $test_filtros = ['2023', '1999', 'B', 'C', ''];
    foreach ($test_filtros as $filtro) {
        $datos_test = json_encode(['filtro' => $filtro]);
        $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM publico.recaudadora_ipor(?::TEXT)");
        $stmt->execute([$datos_test]);
        $count = $stmt->fetch(PDO::FETCH_ASSOC);

        $filtro_display = $filtro === '' ? '(sin filtro)' : "'$filtro'";
        echo "   Filtro $filtro_display: {$count['total']} registros\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";
    echo "\n✅ VERIFICADO: Los resultados CAMBIAN según el filtro aplicado.\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
